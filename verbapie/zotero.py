"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import csv
from typing import List
from lxml import etree
import os
import re
import sys
# local
import verbapie

"""
Detail metadata of cts files
"""

# compile xsl here, one time is enough
xsl_file = os.path.join(os.path.dirname(__file__), 'cts_zotero.xsl')
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

def galeno_meta(tsv_file):
    tsv_dic = {}

    with open(tsv_file, 'r', encoding="utf-8") as f:
        tsv_reader = csv.reader(f, delimiter="\t")
        th = next(tsv_reader)
        for row in tsv_reader:
            if len(row) < 1:
                continue
            row[0] = row[0].strip()
            if not row[0]:
                continue
            if row[0] == '#':
                continue
            if row[0] in tsv_dic:
                continue
            tsv_dic[row[0]] = dict(zip(th, row))
    return tsv_dic


def corpus(paths_file: str, force=True):
    """Load a file with a list of paths, and process them"""
    tei_list = verbapie.tei_list(paths_file)
    """ Galeno-specific """
    corpus_name = os.path.splitext(os.path.basename(paths_file))[0]
    tsv_dic = galeno_meta(os.path.join(os.path.dirname(paths_file), corpus_name + "_bib.tsv"))

    done = {}
    rdf_file = os.path.join(os.path.dirname(paths_file), corpus_name + ".rdf")
    with open(rdf_file, 'w', encoding="utf-8") as out:
        out.write("""<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:z="http://www.zotero.org/namespaces/export#"
 xmlns:bib="http://purl.org/net/biblio#"
 xmlns:foaf="http://xmlns.com/foaf/0.1/"
 xmlns:dcterms="http://purl.org/dc/terms/"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:prism="http://prismstandard.org/namespaces/1.2/basic/">
""")
        for tei_file in tei_list:
            cts_dir = os.path.dirname(tei_file)
            cts_file = os.path.join(cts_dir, '__cts__.xml')
            if cts_file in done:
                continue
            done[cts_file] = True
            cts_name = os.path.basename(os.path.dirname(cts_dir)) + '.' + os.path.basename(cts_dir)
            pars = tsv_dic[cts_name]
            cts_dom = etree.parse(cts_file)
            try:
                dst_dom = xslt(
                    cts_dom,
                    CMGla = etree.XSLT.strparam(pars['CMGla']),
                    CMGabbr = etree.XSLT.strparam(pars['CMGabbr']),
                    CMGgrc = etree.XSLT.strparam(pars['CMGgrc']),
                    BMfr = etree.XSLT.strparam(pars['BMfr']),
                    CGTen = etree.XSLT.strparam(pars['CGTen']),
                    CGTabbr = etree.XSLT.strparam(pars['CGTabbr']),
                    fichtner = etree.XSLT.strparam(pars['fichtner']),
                    no = etree.XSLT.strparam(pars['no']),
                    rem = etree.XSLT.strparam(pars['rem']),
                    biburl = etree.XSLT.strparam(pars['biburl']),
                )
            except:
                for error in xslt.error_log:
                    print(error.message + " l. " + str(error.line))
            xml = etree.tounicode(dst_dom, method='xml', pretty_print=True)
            xml = re.sub(r'</?rdf:RDF[^>]*>', '', xml)
            out.write(xml)
        out.write('</rdf:RDF>')

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Process an XML/cts greek corpus to produce a zotero rdf file ready to import within links betweem works and editions',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('paths_file', nargs=1, type=str,
        help="""ex: ../tests/galenus.tsv"""
    )
    args = parser.parse_args()
    corpus(args.paths_file[0])


if __name__ == '__main__':
    sys.exit(main())
