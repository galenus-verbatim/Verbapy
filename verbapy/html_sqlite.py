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

"""Lemmatize and ingest a folder of html greek text in an sqlite db"""


# shared pie-extended objects, import as late as possible (takes time)
tagger = iterator = processor = None
# shared sqlite3 objects
con = cur = None
# dictionnaries of form ids
orth_dic = lem_dic = {} 

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
        doc_id = cur.lastrowid
        parse(html, doc_id)


def parse(text: str, doc_id: int):
    """Parse tokens"""
    toks, starts, ends = verbatoks.listing(text)
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
        tok_sql = """
        INSERT INTO tok 
            (doc, orth, offset, length, cat, lem) 
        VALUES 
            (?, ?, ?, ?, ?, ?)
        """
        offset = starts[i]
        length = ends[i] - starts[i]

        """ json.dumps(word, ensure_ascii=False)
        {"form": "πλήθει", "case": "-", "degree": "-", "gend": "-", "lemma": "πλῆθος", "mood": "-", "num": "s", "pers": "-", "pos": "n", "tense": "-", "voice": "-", "treated": "πλήθει"}
        """
        # here it could be possible to concat a better string for category
        cat = word['pos']
        orth = toks[i].lower()
        lem = word['lemma']
        # get lem_id
        if not lem:
            lem_id = 0
        elif lem not in lem_dic:
            cur.execute(
                "INSERT INTO lem (form, cat) VALUES (?, ?)",
                (lem, cat)
            )
            lem_id = cur.lastrowid
            lem_dic[lem] = lem_id
        else:
            lem_id = lem_dic[lem]
        # get orth_id
        if not orth:
            orth_id = 0
        elif orth not in orth_dic:
            cur.execute(
                "INSERT INTO orth (form, cat, lem) VALUES (?, ?, ?)",
                (orth, cat, lem_id)
            )
            orth_id = cur.lastrowid
            orth_dic[orth] = orth_id
        else:
            orth_id = orth_dic[orth]

        cur.execute(tok_sql,
            (doc_id, orth_id, offset, length, cat, lem_id)
        )

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