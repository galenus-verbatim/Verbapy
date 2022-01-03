"""
Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php
Code policy PEP8 https://www.python.org/dev/peps/pep-0008/
"""

import re


"""Tokenizer for languages with roman alphabet punctuation

Output a verticalize list of tokens, with offsets
"""
NUM = 'NUM'
SENT = 'SENT'
WORD = 'WORD'
XML = 'XML'
XMLENT = 'XMLENT'
token_specification = [
    (WORD,      r'\w+'),         # letters
    (NUM,       r'\d+'),         # numbers, ex: page
    (XMLENT,    r'&\w+;'),       # xml entiy &amp;
    (XML,       r'<[^>]+>'),     # <xml tag="blah">
    (SENT,      r'[\.?!]'),      # should break on sentence
]
dre = '|'.join('(?P<%s>%s)' % pair for pair in token_specification)
pattern = re.compile(dre)

def listing(text) :
    pattern.finditer(text)
    toks = []
    starts = []
    ends = []
    group = 0
    for match in pattern.finditer(text):
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
            toks.append(match.group(group) + "\n")
        else:
            toks.append(match.group(group))
        starts.append(match.start(group))
        ends.append(match.end(group))
    # trim last token  to avoid empty sentence creation
    toks[-1] = toks[-1].strip()
    return toks, starts, ends




 
