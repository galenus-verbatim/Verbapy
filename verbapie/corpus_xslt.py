"""
Part of verbapie https://github.com/galenus-verbatim/verbapie
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import logging
from lxml import etree
from typing import List
# import moduleName
import os
import re
import shutil
import sys
# local
import config
import verbapie

"""Specific Galenus, write normalize Gipper line number in TEI
"""


# libxml options for dom document load
xml_parser = etree.XMLParser(
    dtd_validation=False,
    no_network=True,
    ns_clean=True,
    huge_tree=True,
)



def corpus(paths_file: str, xslt_file: str):
    """Load a file with a list of paths, and process them"""
    tei_list = verbapie.tei_list(paths_file)
    # compile xsl here, one time is enough
    xslt_transfo = etree.XSLT(
        etree.parse(xslt_file)
    )

    for tei_file in tei_list:
        print(tei_file)
        # load a tei file as a dom
        tei_dom = etree.parse(
            tei_file,
            parser=xml_parser, 
            base_url=tei_file
        )
        # apply xslt (and do not forget to output errors)
        tei_dom = xslt_transfo(tei_dom)
        for error in xslt_transfo.error_log:
            print(error.message + " l. " + str(error.line))
        # do not indent
        # etree.indent(tei_dom, space="  ")
        fin = etree.tounicode(tei_dom) # , method='html', pretty_print=True
        fout = open(tei_file, 'w', encoding="utf-8")
        fout.write(fin)


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Transform a corpus in place with an xslt',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('tei_list', nargs=1, type=str,
        help=verbapie.tei_list_help()
    )
    parser.add_argument('xslt_file', nargs=1, type=str,
        help="""An xslt file to apply"""
    )
    args = parser.parse_args()
    corpus(args.tei_list[0], args.xslt_file[0])


if __name__ == '__main__':
    sys.exit(main())
