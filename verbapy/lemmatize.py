"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import json
from typing import List
import logging
import os
import sys
# local
import config
import verbatoks

"""Crawl a folder of html, ad a csv rail of lemma and offsets"""


# shared pie-extended objects, import as late as possible (takes time)
tagger = iterator = processor = None

def crawl(html_dir: str, torch: bool=False):
    """Recursive crawl of an html folder of greek texts"""

    # the global variables to set here
    global tagger, iterator, processor, con, cur
    html_dir = os.path.abspath(html_dir).replace('\\', '/').rstrip('/') + '/'

    # pie stuff
    # load that now, can take time
    from pie_extended.cli.utils import get_tagger, get_model, download
    from pie_extended.models.grc.imports import get_iterator_and_processor
    model_name = "grc"
    if torch:
        device = 'cuda'
        batch_size = 64
    else:
        device = 'cpu'
        batch_size = 64
        
    tagger = get_tagger(model_name, batch_size=batch_size, device=device, model_path=None)
    iterator, processor = get_iterator_and_processor()

    for root, dirs, files in os.walk(html_dir):
        for f in files:
            if not f.endswith(".html"):
                continue
            if os.path.basename(f) == 'toc.html':
                continue
            lemmatize(os.path.join(root, f))


def lemmatize(html_file: str):
    """Parse tokens"""
    html_name = os.path.splitext(os.path.basename(html_file))[0]
    csv_file = os.path.join(os.path.dirname(html_file), html_name+'.csv');
    if os.path.exists(csv_file) and os.path.getmtime(html_file) < os.path.getmtime(csv_file):
        return
    logging.debug(html_name)
    with open(html_file, mode="r", encoding="utf-8") as f:
        html = f.read()


    toks, starts, ends, pages, lines = verbatoks.listing(html)
    count = len(toks)
    vert = "\n".join(toks)
    i = -1
    csv = "orth\toffset\tlength\tcat\tlem\tpage\tline\n"
    
    # here we should handle better exceptions for torch
    for word in tagger.tag_str(
        vert,
        iterator=iterator,
        processor=processor,
        no_tokenizer=True
    ):
        i = i + 1
        offset = starts[i]
        length = ends[i] - starts[i]
        page = pages[i]
        line = lines[i]

        """ json.dumps(word, ensure_ascii=False)
        {"form": "πλήθει", "case": "-", "degree": "-", "gend": "-", "lemma": "πλῆθος", "mood": "-", "num": "s", "pers": "-", "pos": "n", "tense": "-", "voice": "-", "treated": "πλήθει"}
        """
        # here it could be possible to concat a better string for category
        cat = word['pos']
        orth = toks[i].lower()
        lem = word['lemma']
        csv += (
            orth.strip()
            + "\t" + str(offset)
            + "\t" + str(length)
            + "\t" + cat
            + "\t" + lem.strip()
            + "\t" + str(page)
            + "\t" + str(line)
        + "\n")
    # write at the end, to be sure to not produce incomplete file
    with open(csv_file, 'w', encoding="utf-8") as f:
        f.write(csv)

def main() -> int:
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Crawl a forlder of html fildes produced by split.py'
    )
    parser.add_argument('html_dir', nargs=1,
        help='a directory of html files of structure corpus/book/chapter.html')
    parser.add_argument('-t', '--torch', action='store_true',
        help='use GPU for tagging, much more efficient')
    parser.add_argument('-f', '--force', action='store_true',
        help='force deletion of identifier.csv file of lemma, even newer that identifier.html')

    args = parser.parse_args()
    crawl(args.html_dir[0], args.torch)
    return 0

if __name__ == '__main__':
    sys.exit(main())
