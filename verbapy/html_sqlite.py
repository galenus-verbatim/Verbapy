"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import json
import logging 
import os
import sys
# local
import config
import verbatoks

"""Lemmatize and ingest a folder of html greek text 

"""


# using pie-extended to generate a list of lemma and words
tagger = iterator = processor = None

def crawl(html_dir: str, sqlite_file=None):
    """Recursive crawl of an html folder of greek texts"""
    # load that now, can take time
    from pie_extended.cli.utils import get_tagger, get_model, download
    from pie_extended.models.grc.imports import get_iterator_and_processor
    global tagger, iterator, processor
    model_name = "grc"
    # 5 s.
    tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
    iterator, processor = get_iterator_and_processor()
    for root, dirs, files in os.walk(html_dir):
        for file in files:
            if not file.endswith(".html"):
                continue
            print(os.path.join(root, file))

def file(html_file: str):
    """Insert record for a file"""

def parse(text: str):
    """Parse tokens"""
    toks, starts, ends = verbatoks.listing(text)
    vert = "\n".join(toks)
    i = 0
    count = len(toks)
    for form in tagger.tag_str(
        vert, 
        iterator=iterator, 
        processor=processor, 
        no_tokenizer=True
    ):
        # TODo sqlite insert
        print(
            str(i)
            +"\t"+str(starts[i])
            +"\t"+str(ends[i])
            +"\t"+str(toks[i])
            +"\t"+json.dumps(form, ensure_ascii=False)
        )
        i = i + 1

def main() -> int:
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Lemmatize and ingest an html folder of greek texts in an sqlite base'
    )
    parser.add_argument('html_dir', nargs=1,
        help='a directory of html files to crawl')
    parser.add_argument('sqlite_file', nargs='?',
        help='an sqlite file destination to write in')
    args = parser.parse_args()
    crawl(args.html_dir[0], args.sqlite_file)
    return 0

if __name__ == '__main__':
    sys.exit(main())