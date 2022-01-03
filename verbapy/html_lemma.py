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
import sqlite3
import shutil
import sys
# local
import config
import verbatoks

"""Crawl a folder of html, ad a csv rail of lemma and offsets"""


# shared pie-extended objects, import as late as possible (takes time)
tagger = iterator = processor = None

def crawl(html_dir: str):
    """Recursive crawl of an html folder of greek texts"""

    # the global variables to set here
    global tagger, iterator, processor, con, cur
    html_dir = os.path.abspath(html_dir).replace('\\', '/').rstrip('/') + '/'

    # pie stuff
    # load that now, can take time
    from pie_extended.cli.utils import get_tagger, get_model, download
    from pie_extended.models.grc.imports import get_iterator_and_processor
    model_name = "grc"
    tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
    iterator, processor = get_iterator_and_processor()

    for root, dirs, files in os.walk(html_dir):
        for f in files:
            if not f.endswith(".html"):
                continue
            lemmatize(os.path.join(root, f))


def lemmatize(html_file: str):
    """Parse tokens"""
    html_name = os.path.splitext(os.path.basename(html_file))[0]
    logging.debug(html_name)
    with open(html_file, mode="r", encoding="utf-8") as f:
        html = f.read()
    fout = open(os.path.join(os.path.dirname(html_file), html_name+'.csv'), 'w', encoding="utf-8")
    fout.write("orth\toffset\tlength\tcat\tlem\n")


    toks, starts, ends = verbatoks.listing(html)
    vert = "\n".join(toks)
    i = -1
    count = len(toks)
    for word in tagger.tag_str(
        vert, 
        iterator=iterator, 
        processor=processor, 
        no_tokenizer=True
    ):
        i = i + 1
        offset = starts[i]
        length = ends[i] - starts[i]

        """ json.dumps(word, ensure_ascii=False)
        {"form": "πλήθει", "case": "-", "degree": "-", "gend": "-", "lemma": "πλῆθος", "mood": "-", "num": "s", "pers": "-", "pos": "n", "tense": "-", "voice": "-", "treated": "πλήθει"}
        """
        # here it could be possible to concat a better string for category
        cat = word['pos']
        orth = toks[i].lower()
        lem = word['lemma']
        fout.write(orth.strip() + "\t" + str(offset) + "\t" + str(length) + "\t" + cat + "\t" + lem.strip() + "\n")
    fout.close()

def main() -> int:
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Lemmatize and ingest an html folder of greek texts in an sqlite base'
    )
    parser.add_argument('html_dir', nargs=1,
        help='a directory of html files of structure corpus/book/chapter.html ')
    args = parser.parse_args()
    crawl(args.html_dir[0])
    return 0

if __name__ == '__main__':
    sys.exit(main())