"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import glob
import json
import logging 
from lxml import etree
import os
import sys
import shutil
# local
import config

"""Split an XML/TEI/Epidoc/cts file in HTML+json chapters

"""

# compile xsl here, one time is enough
xsl_file = os.path.join(config.home, 'cts_chapters.xsl')
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
# the default dir where to output files, set by a json conf
dst_dir = None

def corpus(json_file: str):
    """Load a json config file to get list of files, and process them"""
    global dst_dir
    json_dir = os.path.dirname(json_file)
    if not os.path.isabs(json_dir):
        json_dir = os.path.abspath(json_dir)
    logging.debug("json_dir="+json_dir)
    with open(json_file) as json_handle:
        data = json.load(json_handle)
    if not 'dst_dir' in data:
        logging.fatal("\"" + json_file + "\" (json key required)" 
            +"\n\"dst_dir\" = \"destination/directory/\"" 
            + "\nDirectory where to split your XML files, absolute or relative to json file")
        exit()
    dst_dir = data['dst_dir']
    if not os.path.isabs(dst_dir):
        dst_dir =  os.path.join(json_dir, dst_dir)
    # libxml do not like windows filepath
    dst_dir = dst_dir.replace('\\', '/').rstrip('/') + '/'
    logging.info(dst_dir + " (Destination directory)")
    # after logging, try to delete dst_dir and recreate it
    shutil.rmtree(dst_dir, ignore_errors=True)
    os.makedirs(dst_dir, exist_ok=True)
    if not 'src_glob' in data:
        logging.fatal("\"" + json_file + "\" (json key required)" 
        + "\n\"src_glob\" = ["
        + "\n  \"../../First1KGreek/data/tlg0057/*/*.xml\","
        + "\n  \"../../First1KGreek/data/tlg0022/*/*.xml\""
        + "\n]"
        + "\nFile paths or globs, absolute or relative to json file")
        exit()
    for src_glob in data['src_glob']:
        src_glob = src_glob.replace('\\', '/').rstrip('/')
        if not os.path.isabs(src_glob):
            src_glob = os.path.join(json_dir, src_glob)
        src_glob = os.path.normpath(src_glob)
        src_list = glob.glob(src_glob)
        if len(src_list) < 1:
            logging.warning("No file found for pattern "+src_glob)
            continue
        logging.info(src_glob + " (crawl)")
        for src_file in src_list:
            split(src_file)

def split(src_file: str):
    global dst_dir
    src_name_ext = os.path.basename(src_file)
    src_name = os.path.splitext(src_name_ext)[0]
    # xslt needs a dir for file such: dst_dir/src_name/src_name.chapter.html
    os.makedirs(os.path.join(dst_dir, src_name), exist_ok=True)    
    logging.info(src_name + " {:.0f} kb".format(os.path.getsize(src_file) / 1024))
    src_dom = etree.parse(src_file)
    dst_dom = xslt(
        src_dom,
        # libxml do not like windows paths
        dst_dir = etree.XSLT.strparam( 
           (dst_dir, "file:///"+dst_dir)[os.path.sep == '\\']
        ),
        src_name = etree.XSLT.strparam(src_name)
    )
    """
    logging.debug("xslt")
    print(etree.tounicode(dst_dom, pretty_print=True))
    """

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process an XML greek corpus ')
    parser.add_argument('json', type=str, nargs=1,
                    help='a json file with parameters')
    args = parser.parse_args()
    corpus(args.json[0])