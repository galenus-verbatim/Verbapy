"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import csv
import glob
import json
from typing import List
import logging
import os
import sqlite3
import sys
import zlib
# local
import config

"""Ingest a prepared folder of texts with vertical tsv lemma in sqlite"""


# shared sqlite3 objects
con = cur = None
# dictionnaries of form ids
orth_dic = lem_dic = {}

def crawl(html_dir: str, sqlite_file=None):
    """Recursive crawl of folder of greek texts"""

    # the global variables to set here
    global con, cur
    html_dir = os.path.abspath(html_dir).replace('\\', '/').rstrip('/') + '/'
    # the sqlite base
    if not sqlite_file:
        sqlite_file = html_dir.rstrip('/') + ".db"
    else:
        sqlite_file = os.path.abspath(sqlite_file).replace('\\', '/')
    # for now, no incremental insert
    try:
        os.remove(sqlite_file)
    except OSError:
        pass

    logging.info(html_dir + " => " + sqlite_file)
    con = sqlite3.connect(sqlite_file)
    cur = con.cursor()

    # create tables
    sql_file = os.path.join(os.path.dirname(__file__), 'verbatim.sql')
    with open(sql_file, 'r', encoding="utf-8") as f:
        sql = f.read()
    cur.executescript(sql)
    con.commit()
    # for each TEI/CTS file, a json file has been generated to keep the order of chapters to ingest
    json_list = sorted(glob.glob(html_dir + '*/*.json'))
    if len(json_list) < 1:
        raise Exception("No json file found in directory:\n\"" + html_dir + "\"")
    for json_file in json_list:
        docs(json_file)
    con.commit()
    con.close()


def docs(json_file: str):
    """Insert a record for a file"""
    logging.info(json_file)
    opus_sql = """
INSERT INTO opus(

    identifier,
    filemtime,
    filesize,
    title,
    toc,

    author,
    issued,
    editor,
    volume,
    pagefrom,
    pageto

) VALUES
(?, ?, ?, ?, ?,    ?, ?, ?, ?, ?, ?)
    """
    json_dir = os.path.dirname(json_file)
    with open(json_file, 'r', encoding="utf-8") as fread:
        data = json.load(fread)
    opus_json = data[0]
    toc_file = os.path.join(json_dir, "toc.html")
    toc = None
    if os.path.isfile(toc_file):
        with open(toc_file, mode="r", encoding="utf-8") as f:
            toc = f.read()
    cur.execute(opus_sql, (
        opus_json['identifier'],
        os.path.getmtime(json_file),
        os.path.getsize(json_file),
        opus_json['title'],
        toc,

        opus_json.get('author'),
        opus_json.get('issued'),
        opus_json.get('editor'),
        opus_json.get('volume'),
        opus_json.get('pagefrom'),
        opus_json.get('pageto'),
    ))
    opus_id = cur.lastrowid


    doc_sql = """
INSERT INTO doc(
    identifier,
    html,
    opus,

    prev,
    next,
    pagefrom,
    pageto,
    book,
    chapter

) VALUES
(?, ?, ?,  ?, ?, ?, ?, ?, ?)
    """
    for i in range(1, len(data)):
        doc_json = data[i]
        identifier = doc_json['identifier']
        html_file = os.path.join(json_dir, identifier + ".html")
        with open(html_file, mode="r", encoding="utf-8") as f:
            html = f.read()
            # works with php php:gzuncompress($html), but is not a real economy
            # html = zlib.compress(bytes(html, 'utf-8'), level=9)

        prev = None
        if i > 1:
            prev = data[i-1]['identifier']
        next = None
        if i < len(data)-2:
            next = data[i+1]['identifier']

        cur.execute(doc_sql, (
            identifier,
            html,
            opus_id,
            prev,
            next,
            doc_json.get('pagefrom'),
            doc_json.get('pageto'),
            doc_json.get('book'),
            doc_json.get('chapter')
        ))
        doc_id = cur.lastrowid
        toks( os.path.join(json_dir, identifier + ".csv"), doc_id)


def toks(tsv_path: str, doc_id: int):
    """Parse a verticalized tsv list of tokens with positions"""
    with open(tsv_path, 'r', encoding="utf-8") as f:
        tsv_reader = csv.reader(f, delimiter="\t")
        # orth	offset	length	cat	lem
        # ὧν	178 	2   	p	ὅς
        for line in tsv_reader:
            tok_sql = """
            INSERT INTO tok
                (doc, orth, offset, length, cat, lem)
            VALUES
                (?, ?, ?, ?, ?, ?)
            """
            orth = line[0]
            if orth.isdigit(): # page numbers have been tokenized
                continue
            offset = line[1]
            length = line[2]
            cat = line[3]
            lem = line[4]
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