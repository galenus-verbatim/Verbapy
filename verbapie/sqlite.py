"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import csv
import glob
import importlib.resources as pkg_resources
import json
from typing import List
import logging
import os
import sqlite3
import sys
import zlib
# local
import config
import verbapie
import res  # relative-import the *package* containing resources

"""Ingest a prepared folder of texts with vertical tsv lemma in sqlite"""


# shared sqlite3 objects
con = cur = None
# dictionnaries of form ids
orth_dic = lem_dic = {}


def trans(path):
    data = pkg_resources.read_text(res, path)
    dic = json.loads(data)
    trans = "".maketrans(dic)
    return trans
# build the greek transliterator to get a form with no accents
tr_deform = trans('tr_grc_deform.json')
tr_nat = trans('tr_grc_nat.json')


def crawl(corpus_conf: str, sqlite_file=None):
    """Recursive crawl of a file list to pilot ingestion of greek texts"""
    # test immediately parameters before deleting or create something
    tei_list = verbapie.tei_list(corpus_conf)
    html_dir = verbapie.html_dir(corpus_conf)
    json_list = []
    for tei_file in tei_list:
        tei_name = os.path.splitext(os.path.basename(tei_file))[0]
        json_file = os.path.join(html_dir, tei_name, tei_name + ".json")
        if not os.path.isfile(json_file):
            raise Exception("Json file not found:\"" + json_file + "\"\nRun cts.py and lemmatize.py before")
        json_list.append(json_file)

    # the global variables to set here
    global con, cur
    # the sqlite base
    if not sqlite_file:
        sqlite_file = html_dir.rstrip('/') + ".db"
    else:
        sqlite_file = os.path.abspath(sqlite_file).replace('\\', '/')
    # for now, no incremental insert, delete sqlite base
    if os.path.isfile(sqlite_file):
        os.remove(sqlite_file)

    logging.info(html_dir + " => " + sqlite_file)
    con = sqlite3.connect(sqlite_file)
    cur = con.cursor()

    # create tables
    sql_file = os.path.join(os.path.dirname(__file__), 'verbatim.sql')
    with open(sql_file, 'r', encoding="utf-8") as f:
        sql = f.read()
    cur.executescript(sql)
    con.commit()

    for json_file in json_list:
        docs(json_file)
    con.commit()
    con.close()


def docs(json_file: str):
    """Insert a record for a file"""
    logging.info(json_file)
    edition_sql = """
INSERT INTO edition(

    clavis,
    epoch,
    octets,
    titulus,
    nav,

    auctor,
    editor,
    annuspub,
    volumen,
    pagde,
    pagad

) VALUES
(?, ?, ?, ?, ?,    ?, ?, ?, ?, ?, ?)
    """
    json_dir = os.path.dirname(json_file)
    with open(json_file, 'r', encoding="utf-8") as fread:
        data = json.load(fread)
    edition_json = data[0]
    toc_file = os.path.join(json_dir, "toc.html")
    nav = None
    if os.path.isfile(toc_file):
        with open(toc_file, mode="r", encoding="utf-8") as f:
            nav = f.read()
    editor = edition_json.get('editor')
    cur.execute(edition_sql, (
        edition_json['clavis'],
        os.path.getmtime(json_file),
        os.path.getsize(json_file),
        edition_json['titulus'],
        nav,

        edition_json.get('auctor'),
        editor,
        edition_json.get('annuspub'),
        edition_json.get('volumen'),
        edition_json.get('pagde'),
        edition_json.get('pagad'),
    ))
    edition_id = cur.lastrowid


    doc_sql = """
INSERT INTO doc(
    clavis,
    html,
    edition,
    editor,

    ante,
    post,

    volumen,
    pagde,
    linde,
    pagad,
    linad,

    liber,
    capitulum,
    sectio
) VALUES
(?, ?, ?, ?,   ?, ?,   ?, ?, ?, ?, ?,   ?, ?, ?)
    """
    for i in range(1, len(data)):
        doc_json = data[i]
        clavis = doc_json['clavis']
        html_file = os.path.join(json_dir, clavis + ".html")
        with open(html_file, mode="r", encoding="utf-8") as f:
            html = f.read()
            # works with php php:gzuncompress($html), but is not a real economy
            # html = zlib.compress(bytes(html, 'utf-8'), level=9)

        ante = None
        if i > 1:
            ante = data[i-1]['clavis']
        post = None
        if i < len(data)-1:
            post = data[i+1]['clavis']

        cur.execute(doc_sql, (
            clavis,
            html,
            edition_id,
            editor,

            ante,
            post,

            doc_json.get('volumen'),
            doc_json.get('pagde'),
            doc_json.get('linde'),
            doc_json.get('pagad'),
            doc_json.get('linad'),

            doc_json.get('liber'),
            doc_json.get('capitulum'),
            doc_json.get('sectio')
        ))
        doc_id = cur.lastrowid
        toks( os.path.join(json_dir, clavis + ".csv"), doc_id)


def toks(tsv_path: str, doc_id: int):
    """Parse a verticalized tsv list of tokens with positions"""
    with open(tsv_path, 'r', encoding="utf-8") as f:
        tsv_reader = csv.reader(f, delimiter="\t")
        next(tsv_reader)
        # quoting=csv.QUOTE_NONE
        # orth	offset	length	cat	lem
        # ὧν	178 	2   	p	ὅς
        i = 0
        for row in tsv_reader:
            i = i + 1
            tok_sql = """
            INSERT INTO tok
                (doc, orth, charde, charad, cat, lem, pag, linea)
            VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
            """
            try:
                orth = row[0]
                if orth.isdigit(): # page numbers may have been tokenized
                    continue
                charde = row[1]
                charad = row[2]
                cat = row[3]
                lem = row[4]
                pag = row[5]
                linea = row[6]
            except IndexError:
                print("Column not found in \"" + tsv_path + "\" l." + str(i))
                print(row)
                raise
            # get lem_id
            # lem_key = lem + '_' + str(cat) # too much noise on cat 
            lem_key = lem # seems better for pie_extended
            if not lem:
                lem_id = 0
            elif (lem_key) not in lem_dic:
                flag = 0
                if lem[0].isupper():
                    flag = 64
                deform = lem.translate(tr_deform)
                empty = deform.translate(tr_nat)
                if empty:
                    print(lem + " " + deform + " " 
                    + str(empty.encode("unicode_escape")))
                cur.execute(
                    "INSERT INTO lem (form, deform, cat, flag) VALUES (?, ?, ?, ?)",
                    (lem, deform, cat, flag)
                )
                lem_id = cur.lastrowid
                lem_dic[lem_key] = lem_id
            else:
                lem_id = lem_dic[lem_key]
            # get orth_id
            orth_key = orth + '_' + str(lem_id)
            if (orth_key) not in orth_dic:
                flag = 0
                if orth[0].isupper():
                    flag = 64
                deform = orth.translate(tr_deform)
                cur.execute(
                    "INSERT INTO orth (form, deform, lem, cat, flag) VALUES (?, ?, ?, ?, ?)",
                    (orth, deform, lem_id, cat, flag)
                )
                orth_id = cur.lastrowid
                orth_dic[orth_key] = orth_id
            else:
                orth_id = orth_dic[orth_key]

            cur.execute(tok_sql,
                (doc_id, orth_id, charde, charad, cat, lem_id, pag, linea)
            )

def main() -> int:
    parser = argparse.ArgumentParser(
        fromfile_prefix_chars='@',
        description='Lemmatize and ingest an html folder of greek texts in an sqlite base'
    )
    parser.add_argument('corpus_conf', nargs=1, type=str,
        help='a file listing of cts file to pilot order of ingestion and of bibliography')
    parser.add_argument('sqlite_file', nargs='?',
        help='an sqlite file destination to write in')
    args = parser.parse_args()
    crawl(args.corpus_conf[0], args.sqlite_file)
    return 0

if __name__ == '__main__':
    sys.exit(main())
