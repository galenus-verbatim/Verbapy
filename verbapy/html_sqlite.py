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

"""Lemmatize and ingest a folder of html greek text 

"""


# shared pie-extended objects, import as late as possible (takes time)
tagger = iterator = processor = None
# shared sqlite3 objects
con = cur = None

def crawl(html_dir: str, sqlite_file=None):
    """Recursive crawl of an html folder of greek texts"""

    # the global variables to set here
    global tagger, iterator, processor, con, cur
    html_dir = os.path.abspath(html_dir).replace('\\', '/').rstrip('/') + '/'
    # the sqlite base
    if not sqlite_file:
        sqlite_file = html_dir.rstrip('/') + ".db"
    else:
        sqlite_file = os.path.abspath(sqlite_file).replace('\\', '/')

    logging.info(html_dir + " => " + sqlite_file)
    shutil.copyfile(
        os.path.join(os.path.dirname(__file__), 'verbatim.db'), 
        sqlite_file
    )
    con = sqlite3.connect(sqlite_file)
    cur = con.cursor()
    # execute options to have best performances on INSERT
    cur.executescript("""
PRAGMA foreign_keys = 0;
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;
    """)
    con.commit()

    """
    # pie stuff
    # load that now, can take time
    from pie_extended.cli.utils import get_tagger, get_model, download
    from pie_extended.models.grc.imports import get_iterator_and_processor
    model_name = "grc"
    tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
    iterator, processor = get_iterator_and_processor()
    """

    for root, dirs, files in os.walk(html_dir):
        for f in files:
            if not f.endswith(".html"):
                continue
            doc(os.path.join(root, f))
    con.commit()
    con.close()


def doc(html_file: str):
    """Insert a record for a file"""
    logging.debug(html_file)
    sql = """
INSERT INTO doc
    (code, filemtime, filesize, title, html)
    VALUES
    (?, ?, ?, ?, ?)
    """
    code = os.path.splitext(os.path.basename(html_file))[0]
    filemtime = os.path.getmtime(html_file)
    filesize = os.path.getsize(html_file)
    title = code # TODO
    with open(html_file, mode="r", encoding="utf-8") as f:
        html = f.read()
        cur.execute(sql, 
            (code, filemtime, filesize, title, html)
        )
        # parse(text)


def parse(text: str):
    """Parse tokens"""
    toks, starts, ends = verbatoks.listing(text)
    logging.debug("tokenized")
    vert = "\n".join(toks)
    i = 0
    count = len(toks)
    for form in tagger.tag_str(
        vert, 
        iterator=iterator, 
        processor=processor, 
        no_tokenizer=True
    ):
        # TODO sqlite insert
        """
        print(
            str(i)
            +"\t"+str(starts[i])
            +"\t"+str(ends[i])
            +"\t"+str(toks[i])
            +"\t"+json.dumps(form, ensure_ascii=False)
        )
        """
        i = i + 1
    logging.debug("lematized")

def main() -> int:
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Lemmatize and ingest an html folder of greek texts in an sqlite base'
    )
    parser.add_argument('html_dir', nargs=1,
        help='a directory of html files of structure corpus/book/chapter.html ')
    parser.add_argument('sqlite_file', nargs='?',
        help='an sqlite file destination to write in')
    args = parser.parse_args()
    crawl(args.html_dir[0], args.sqlite_file)
    return 0

if __name__ == '__main__':
    sys.exit(main())