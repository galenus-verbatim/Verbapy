"""
Part of verbapie https://github.com/galenus-verbatim/verbapie
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import argparse
import glob
import os
import re
import sys
# local
import verbapie



"""Tokenizer for languages with roman alphabet punctuation

Output a verticalize list of tokens, with offsets
"""
LINE = 'LINE'
NOTE = 'NOTE'
NUM = 'NUM'
PAGE = 'PAGE'
SENT = 'SENT'
WORD = 'WORD'
XML = 'XML'
XMLENT = 'XMLENT'
token_specification = [
    (NOTE,      r'<(note|teiHeader)[^>]*>.*?</\2>'),  # pass notes, headers, and things like that, be careful of \2, keep 2
    (WORD,      r'[^\W\d_]+'),         # letters
    (PAGE,      r'<[^>]+ data-page="[^"]+"[^>]*>'),  # html specific, element with a page number
    (LINE,      r'<[^>]+ data-line="[^"]+"[^>]*>'),  # html specific, element with a line number
    (NUM,       r'\d+'),         # numbers, ex: page
    (XMLENT,    r'&\w+;'),       # xml entiy &amp;
    (XML,       r'<[^>]+>'),     # <xml tag="blah">
    (SENT,      r'[\.?!]'),      # should break on sentence
]
dre = '|'.join('(?P<%s>%s)' % pair for pair in token_specification)
tokenizer = re.compile(dre, re.MULTILINE | re.UNICODE | re.DOTALL)
page_re = re.compile(r'data-page="([^"]+)"')
line_re = re.compile(r'data-line="([^"]+)"')

stopwords = verbapie.word_list(
    os.path.join(os.path.dirname(__file__), 'grc1k_stopwords.tsv')
)

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
        # filter notes (??)
        if (match.lastgroup == NOTE):
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

def freqlist(paths, size=2000, nostops=False, nolatin=False):
    """Buid a list of most frequent forms from a set of XML files"""
    lat = re.compile("[a-zA-Z]+")
    counts = dict()
    for path in paths:
        path = os.path.abspath(path)
        print(path, file=sys.stderr)
        no = 1
        for file in glob.iglob(path, recursive=True):
            basename = os.path.basename(file)
            if (basename[0] == '_'):
                continue
            with open(file, mode="r", encoding="utf-8") as f:
                xml = f.read()
                toks, *_ = listing(xml)
                count = len(toks)
                for i in range(0, count):
                    word = toks[i].strip()
                    if nostops and word in stopwords:
                        continue
                    if nolatin and lat.fullmatch(word):
                        continue
                    if word in counts:
                        counts[word] += 1
                    else:
                        counts[word] = 1
            print(str(no) + ". " + file + " (" + str(count) + ")", file=sys.stderr)
            no = no + 1
    counts_sorted = sorted(counts.items(), key=lambda x: x[1], reverse=True)
    for item in counts_sorted:
        print(item[0] + "\t" + str(item[1]))
        size = size -1
        if size <= 0:
            break


def vert(files):
    for ml_file in files:
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



def main() -> int:
    parser = argparse.ArgumentParser(
        description='Process an ML file (with <tag>), show tokenized words between tags, for search or linguistic',
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument('files', nargs='+', type=str,
        help="""One or mor *.ml file"""
    )
    args = parser.parse_args()
    freqlist(args.files)


if __name__ == '__main__':
    sys.exit(main())




