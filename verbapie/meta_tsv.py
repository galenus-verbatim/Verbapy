"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
from typing import List
from lxml import etree
import os
import sys
# local
import verbapie

"""
Detail metadata of cts files
"""

# compile xsl here, one time is enough
xsl_file = os.path.join(os.path.dirname(__file__), 'cts_meta.xsl')
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

def json(paths_file: str):
    """Load a file with a list of paths, get a json record of some things"""
    tei_list = verbapie.tei_list(paths_file)
    sys.stdout.buffer.write("{\n".encode('utf8'))
    xsl_file = os.path.join(os.path.dirname(__file__), 'cts_json.xsl')
    xsl_dom = etree.parse(xsl_file)
    transfo = etree.XSLT(xsl_dom)
    for tei_file in tei_list:
        tei_name = os.path.splitext(os.path.basename(tei_file))[0]
        with open(tei_file, 'r', encoding="utf-8") as f:
            xml = f.read()
        tei_dom = etree.XML(bytes(xml, encoding='utf-8'), base_url=tei_file)
        dst_dom = transfo(
            tei_dom,
            src_name = etree.XSLT.strparam(tei_name)
        )
        line = etree.tounicode(dst_dom, method='text', pretty_print=True)
        # ensure output in utf8, even on windows
        sys.stdout.buffer.write(line.encode('utf8') + b'\n')
    sys.stdout.buffer.write("}\n".encode('utf8'))

def corpus(paths_file: str, force=True):
    """Load a file with a list of paths, and process them"""
    cts_list = verbapie.cts_list(paths_file)
    sys.stdout.buffer.write("iter\tauctor\ttitulus\tannuspub\teditor\tvolumen\tpagde\tpagad\n".encode('utf8'))
    for cts_file in cts_list:
        with open(cts_file, 'r', encoding="utf-8") as f:
            xml = f.read()
        cts_name = os.path.splitext(os.path.basename(cts_file))[0]
        # do not forget base_url, to resolve xslt document() for __cts__.xml
        cts_dom = etree.XML(bytes(xml, encoding='utf-8'), base_url=cts_file)
        if os.path.isfile(os.path.join(os.path.dirname(cts_file), '__cts__.xml')):
            __cts__ = 'true'
        else:
            __cts__ = ''
        dst_dom = xslt(
            cts_dom,
            __cts__ = etree.XSLT.strparam(__cts__),
            iter = etree.XSLT.strparam(cts_file)
        )
        line = etree.tounicode(dst_dom, method='text', pretty_print=True)
        # ensure output in utf8, even on windows
        sys.stdout.buffer.write( line.encode('utf8') + b'\n')

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Process an XML/cts greek corpus to produce a tsv file of meta',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('paths_file', nargs=1, type=str,
        help="""ex: ../tests/galenus.txt"""
    )
    args = parser.parse_args()
    json(args.paths_file[0])


if __name__ == '__main__':
    sys.exit(main())
