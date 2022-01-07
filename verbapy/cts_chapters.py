"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import glob
import io
import json
import logging
from typing import List 
from lxml import etree
import os
import re
import shutil
import sys
# local
import config

"""Split an XML/TEI/Epidoc/cts file in HTML+json chapters

"""

# compile xsl here, one time is enough
xsl_file = os.path.join(os.path.dirname(__file__), 'cts_chapters.xsl')
xsl_dom = etree.parse(xsl_file)
xslt = etree.XSLT(xsl_dom)
# libxml options for dom document load
etree.set_default_parser(
    etree.XMLParser(
        dtd_validation=False,
        no_network=True,
        ns_clean=True,
        huge_tree=True,
    )
)
# the default dir where to output files
html_dir = None

def corpus(paths_file: str, todo_dir=None, force=True):
    """Load a file with a list of paths, and process them"""
    global html_dir
    # will cry if not a file
    paths = open(paths_file, 'r').readlines()
    paths_dir = os.path.dirname(paths_file)
    if not os.path.isabs(paths_dir):
        paths_dir = os.path.abspath(paths_dir)
    logging.debug("paths_dir="+paths_dir)
    paths_name = os.path.splitext(os.path.basename(paths_file))[0]

    # prepare html destination directory
    if todo_dir is None:
        todo_dir = os.path.join(paths_dir, paths_name)
    elif todo_dir is List:
        todo_dir = todo_dir[0]
    if not os.path.isabs(todo_dir):
        todo_dir = os.path.abspath(todo_dir)
    # libxml do not like windows filepath
    html_dir = todo_dir.replace('\\', '/').rstrip('/') + '/'
    logging.info(html_dir + " (html destination directory)")
    # do not delete html_dir, let user, keep lemma
    if force:
        shutil.rmtree(html_dir, ignore_errors=True)
    os.makedirs(html_dir, exist_ok=True)

    # TODO, parse the path config for exclude files
    for cts_glob in paths:
        cts_glob = cts_glob.strip()
        if not cts_glob:
            continue
        if cts_glob[0] == '#':
            continue
        cts_glob = cts_glob.replace('\\', '/').rstrip('/')
        if not os.path.isabs(cts_glob):
            cts_glob = os.path.join(paths_dir, cts_glob)
        cts_glob = os.path.normpath(cts_glob)
        cts_list = glob.glob(cts_glob)
        if len(cts_list) < 1:
            logging.warning("No file found for pattern "+cts_glob)
            continue
        for cts_file in cts_list:
            split(cts_file)

def split(cts_file: str):
    global html_dir
    cts_name = os.path.splitext(os.path.basename(cts_file))[0]
    # xslt needs a dir for file such: dst_dir/src_name/src_name.chapter.html
    os.makedirs(os.path.join(html_dir, cts_name), exist_ok=True)    
    logging.info(cts_name + " {:.0f} kb".format(os.path.getsize(cts_file) / 1024))
    with open(cts_file, 'r', encoding="utf-8") as f:
        xml = f.read()
    xml = re.sub(r"\s+", ' ', xml)

    """
    debug = os.path.join(html_dir, cts_name + ".xml")
    with open(debug, 'w', encoding="utf-8") as f:
        f.write(xml)
    """

    cts_dom = etree.XML(bytes(xml, encoding='utf-8'))
    dst_dom = xslt(
        cts_dom,
        # libxml do not like windows paths starting C:
        dst_dir = etree.XSLT.strparam( 
           (html_dir, "file:///"+html_dir)[os.path.sep == '\\']
        ),
        src_name = etree.XSLT.strparam(cts_name)
    )
    infile = etree.tounicode(dst_dom, method='text', pretty_print=True)
    outfile = open(os.path.join(html_dir, cts_name, cts_name+".json"), 'a', encoding="utf-8")
    outfile.write(infile)

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Process an XML/cts greek corpus to produce a folder of displayable HTML files',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('paths_file', nargs=1, type=str,
        help="""ex: ../tests/galenus.txt
a file with a list of file/glob path of xml files to process, one per line:
../../First1KGreek/data/tlg0052/*/tlg*.xml
../../First1KGreek/data/tlg0057/*/tlg*.xml
(relative paths resolved from the file they come from)
"""
    )
    parser.add_argument('html_dir', nargs='?', type=str,
        help="""ex: ../work/galenus/
A folder where to project generated html files.
Default is a folder with the name of the file with paths.
"""
    )
    parser.add_argument('-f', '--force', action='store_true',
        help='force deletion of html_dir')
    args = parser.parse_args()
    corpus(args.paths_file[0], args.html_dir, args.force)


if __name__ == '__main__':
    sys.exit(main())
