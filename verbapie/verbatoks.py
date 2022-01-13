"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import re
import sys


"""Tokenizer for languages with roman alphabet punctuation

Output a verticalize list of tokens, with offsets
"""
LINE = 'LINE'
NUM = 'NUM'
PAGE = 'PAGE'
SENT = 'SENT'
WORD = 'WORD'
XML = 'XML'
XMLENT = 'XMLENT'
token_specification = [
    (WORD,      r'\w+'),         # letters
    (PAGE,      r'<[^>]+ data-page="[^"]+"[^>]*>'),  # html specific, element with a page number
    (LINE,      r'<[^>]+ data-line="[^"]+"[^>]*>'),  # html specific, element with a line number
    (NUM,       r'\d+'),         # numbers, ex: page
    (XMLENT,    r'&\w+;'),       # xml entiy &amp;
    (XML,       r'<[^>]+>'),     # <xml tag="blah">
    (SENT,      r'[\.?!]'),      # should break on sentence
]
dre = '|'.join('(?P<%s>%s)' % pair for pair in token_specification)
tokenizer = re.compile(dre)
page_re = re.compile(r'data-page="([^"]+)"')
line_re = re.compile(r'data-line="([^"]+)"')

def listing(text) :
    tokenizer.finditer(text)
    toks = []
    starts = []
    ends = []
    pages = []
    lines = []

    page = -1
    line = -1
    for match in tokenizer.finditer(text):

        # a tag with a page number
        if (match.lastgroup == PAGE):
            page_match = page_re.search(match.group(0))
            page = page_match.group(1)
            line_match = line_re.search(match.group(0))
            if line_match is None:
                line = 1
            else:
                line = line_match.group(1)
            continue
        # get line
        if (match.lastgroup == LINE):
            line_match = line_re.search(match.group(0))
            line = line_match.group(1)
            continue
        # filter XML tags
        if (match.lastgroup == XML):
            continue
        if (match.lastgroup == XMLENT):
            continue
        # filter numbers
        if (match.lastgroup == NUM):
            continue

        # break sentences for pie
        if (match.lastgroup == SENT):
            toks.append(match.group(0) + "\n")
        else:
            toks.append(match.group(0))
        starts.append(match.start(0))
        ends.append(match.end(0))
        pages.append(page)
        lines.append(line)
    # trim last token  to avoid empty sentence creation
    toks[-1] = toks[-1].strip()
    return toks, starts, ends, pages, lines

def main() -> int:
    parser = argparse.ArgumentParser(
        description='Process an ML file (with <tag>), show tokenized words between tags, for search or linguistic',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('ml_file', nargs='+', type=str,
        help="""One or mor *.ml file"""
    )
    args = parser.parse_args()
    for ml_file in args.ml_file:
        print(ml_file)
        with open(ml_file, mode="r", encoding="utf-8") as f:
            ml = f.read()
            toks, starts, ends, pages, lines = listing(ml)
            count = len(toks)
            for i in range(0, count):
                line = (toks[i].strip()
                  + "\t" + str(starts[i])
                  + "\t" + str(ends[i])
                  + "\t" + str(pages[i])
                  + "\t" + str(lines[i])
                )
                print(line)


if __name__ == '__main__':
    sys.exit(main())




