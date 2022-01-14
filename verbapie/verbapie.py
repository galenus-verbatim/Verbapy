"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""
import csv
import os
from typing import List


"""Shared functions between scripts, especially to ensure same file paths"""

def html_dir(corpus_conf: str) -> str:
    """Get the path of an html dir build from a list of cts paths"""
    if not os.path.isfile(corpus_conf):
        raise Exception("File not found for a cts list:\"" + corpus_conf + "\"")
    paths_name = os.path.splitext(os.path.basename(corpus_conf))[0]
    dir = norm_dir(corpus_conf)
    html_dir = os.path.join(dir, paths_name) + '/'
    return html_dir

def cts_list(tsv_file: str) -> List:
    """List file inside the conf"""
    if not os.path.isfile(tsv_file):
        raise Exception("File not found for a cts list:\"" + tsv_file + "\"")
    tsv_dir = norm_dir(tsv_file)
    cts_list = []
    with open(tsv_file, 'r', encoding="utf-8") as f:
        tsv_reader = csv.reader(f, delimiter="\t")
        next(tsv_reader)
        for row in tsv_reader:
            if len(row) < 1:
                continue
            cts_file = row[0].strip()
            if not cts_file:
                continue
            if cts_file[0] == '#':
                continue
            if not os.path.isabs(cts_file):
                cts_file = os.path.join(tsv_dir, cts_file)
            cts_file = os.path.normpath(cts_file)
            cts_file = cts_file.replace('\\', '/')
            if not os.path.isfile(cts_file):
                raise Exception("Cts file not found:\"" + cts_file + "\"\n in cts list:\"" + tsv_file + "\"")
            cts_list.append(cts_file)
    return cts_list

def norm_dir(file: str) -> str:
    """Normalize a path of directory"""
    dir = os.path.dirname(file)
    if not os.path.isabs(dir):
        dir = os.path.abspath(dir)
    dir = dir.replace('\\', '/').rstrip('/') + '/'
    return dir

if __name__ == '__main__':
    print(cts_list('tests/galenus.txt'))
