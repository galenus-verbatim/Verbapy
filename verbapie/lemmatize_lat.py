"""
Part of verbapie https://github.com/galenus-verbatim/verbapie
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
import unicodedata
# local
import config
import verbatoks

"""Crawl a folder of html, ad a csv rail of lemma and offsets"""


# shared pie-extended objects, import as late as possible (takes time)
tagger = iterator = processor = None
tsv_esc = str.maketrans({
    "\t": r" ",
    "\n": r" ",
    "\"": r"\"",
    "\\": r"\\"
})

def crawl(html_dir: str, torch: bool=False, force: bool=False):
    """Recursive crawl of an html folder of greek texts"""
    # the global variables to set here
    global tagger, iterator, processor, con, cur
    html_dir = os.path.abspath(html_dir).replace('\\', '/').rstrip('/') + '/'

    # delete old lemma files if force
    if force:
        for root, dirs, files in os.walk(html_dir):
            for f in files:
                if f.endswith(".csv"):
                    os.remove(os.path.join(root,f)) 

    # pie stuff
    # load that now, can take time
    from pie_extended.cli.utils import get_tagger, get_model, download
    from pie_extended.models.lasla.imports import get_iterator_and_processor
    model_name = "lasla"
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
            html_file = os.path.join(root, f)
            html_name = os.path.splitext(os.path.basename(html_file))[0]
            csv_file = os.path.join(root, html_name+'.csv')
            if force: # always do
                pass
            elif not os.path.exists(csv_file): # not exists, do
                pass
            else: # no date test, just continue
                continue
            # elif os.path.getmtime(html_file) < os.path.getmtime(csv_file):
            logging.debug(html_name)
            lemmatize(html_file, csv_file)

def lem_num(orth: str):
    """Return a nice lemma for a thing supposed to be a number"""
    return "NUM"

def lemmatize(html_file: str, csv_file:str):
    """Parse tokens"""
    with open(html_file, mode="r", encoding="utf-8") as f:
        html = f.read()


    toks, starts, ends, pages, lines = verbatoks.listing(html)
    count = len(toks)
    vert = "\n".join(toks)
    i = -1
    csv = "orth\tcharde\tcharad\tcat\tlem\tpag\tlinea\n"

    # here we should handle better exceptions for torch
    for word in tagger.tag_str(
        vert,
        iterator=iterator,
        processor=processor,
        no_tokenizer=True
    ):
        i = i + 1

        """ json.dumps(word, ensure_ascii=False)
        {"form": "πλήθει", "case": "-", "degree": "-", "gend": "-", "lemma": "πλῆθος", "mood": "-", "num": "s", "pers": "-", "pos": "n", "tense": "-", "voice": "-", "treated": "πλήθει"}
        """
        # take orginal form, lower case it (titles)
        orth = word['treated'].lower().strip().translate(tsv_esc)
        lem = "?"
        if toks[i][-1] == '΄':
            orth = toks[i].strip().translate(tsv_esc)
            # should be a number, do not normalize
            # "treated" will decompose and add a space before accent  α ΄
            # get a lemma from a hook
            lem = lem_num(orth)
        else:
            orth = unicodedata.normalize('NFKC', orth)
            lem = unicodedata.normalize(
                'NFKC',
                word['lemma'].strip().translate(tsv_esc)
            )
            # normalize proper names
            if len(lem) > 0 and lem[0].isupper():
                orth = orth.capitalize()
        # maybe better could be found for pos
        cat = word['pos']

        csv += (
            orth
            + "\t" + str(starts[i])
            + "\t" + str(ends[i])
            + "\t" + cat
            + "\t" + lem
            + "\t" + str(pages[i])
            + "\t" + str(lines[i])
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
        help='force generation identifier.csv even if exists')

    args = parser.parse_args()
    crawl(args.html_dir[0], torch=args.torch, force=args.force)
    return 0

if __name__ == '__main__':
    sys.exit(main())
