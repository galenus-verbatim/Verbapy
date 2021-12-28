import re


class Verbatoks:
    """Tokenizer for languages with roman alphabet punctuation
    
    Output a verticalize list of tokens, with offsets
    """
    WORD = 'WORD'
    XML = 'XML'
    SENT = 'SENT'
    token_specification = [
        (WORD,      r'\w+'),         # letters
        (XML,       r'<[^>]+>'),     # <xml tag="blah">
        (SENT,      r'[\.?!]'),      # should break on sentence
    ]
    dre = '|'.join('(?P<%s>%s)' % pair for pair in token_specification)
    pattern = re.compile(dre)

    @staticmethod
    def listing(text) :
        Verbatoks.it = Verbatoks.pattern.finditer(text)
        toks = []
        starts = []
        ends = []
        group = 0
        for match in Verbatoks.pattern.finditer(text):
            # filter XML tags
            if (match.lastgroup == Verbatoks.XML):
                continue
            # break sentences for pie
            if (match.lastgroup == Verbatoks.SENT):
                toks.append(match.group(group) + "\n")
            else:
                toks.append(match.group(group))
            starts.append(match.start(group))
            ends.append(match.end(group))
        # trim last token  to avoid empty sentence creation
        toks[-1] = toks[-1].strip()
        return toks, starts, ends




 
