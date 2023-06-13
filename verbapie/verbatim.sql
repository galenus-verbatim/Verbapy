-- Part of verbapie https://github.com/galenus-verbatim/verbapie
PRAGMA encoding = 'UTF-8'; -- W. encoding used for output
PRAGMA page_size = 32768; -- W. said as best for perfs
PRAGMA mmap_size = 1073741824; -- W/R. should be more efficient
-- to be executed before write
PRAGMA foreign_keys = 0; -- W. for efficiency
-- PRAGMA journal_mode = OFF; -- W. Dangerous, no roll back, maybe efficient
-- PRAGMA synchronous = OFF; -- W. Dangerous, but no parallel write check

DROP TABLE IF EXISTS opus;
CREATE table opus (
-- Opus when more than one edition of same text
    id                   INTEGER, -- rowid auto
    cts     TEXT UNIQUE NOT NULL, -- ! cts identifier for url
    bibl                    BLOB, -- ! html bibl record
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX opus_cts ON opus(cts);

DROP TABLE IF EXISTS edition;
CREATE table edition (
-- Source XML file
    id                   INTEGER, -- rowid auto
    -- must, file infos and content
    cts     TEXT UNIQUE NOT NULL, -- ! cts identifier for url
    file    TEXT UNIQUE NOT NULL, -- ! source xml filename without extension
    epoch       INTEGER NOT NULL, -- ! file modified time
    bytes       INTEGER NOT NULL, -- ! filesize
    nav                     BLOB, -- ? html table of contents
    bibl                    BLOB, -- ! html text ready to display
    -- bibliographic info as zotero codes for html meta
    -- https://www.zotero.org/support/dev/exposing_metadata
    title                   TEXT, -- 
    date                    TEXT, -- 
    authors                 TEXT, -- Surname, Given Name; Smith, Jane
    editors                 TEXT, -- Surname, Given Name; Smith, Jane
    language                TEXT, --
    book_title              TEXT, --
    volume                  TEXT,
    series                  TEXT,
    page_start              TEXT, -- 
    page_end                TEXT, -- 
    publisher               TEXT, -- 


    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS edition_cts ON edition(cts);


-- Schema to store lemmatized texts
DROP TABLE IF EXISTS doc;
CREATE table doc (
-- an indexed HTML document
    id                   INTEGER, -- rowid auto
    -- must, file infos and content
    cts     TEXT UNIQUE NOT NULL, -- ! cts identifier for url
    html           BLOB NOT NULL, -- ! html text ready to display
    edition     INTEGER NOT NULL, -- ! link to the edition
    prev                    TEXT, -- ? cts of previous document
    next                    TEXT, -- ? cts of next document

    -- should, bibliographic info
    editors                 TEXT, -- ? replicated from editio, for efficiency
    title                   TEXT, -- ? title of the document if relevant
    
    volume                  TEXT, -- ? analytic, for edition on more than one
    page_start              TEXT, -- ? page from
    line_start           INTEGER, -- ? first line of first page
    page_end             INTEGER, -- ? page to
    line_end             INTEGER, -- ? last line of last page

    liber                   TEXT, -- ? analytic,
    capitulum               TEXT, -- ? analytic,
    sectio                  TEXT, -- ? analytic,
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS doc_cts ON doc(cts);
CREATE INDEX IF NOT EXISTS doc_redir ON doc(editors, volume, page_start, page_end);


DROP TABLE IF EXISTS tok;
CREATE TABLE tok (
-- compiled table of occurrences
    id                   INTEGER, -- rowid auto
    doc         INTEGER NOT NULL, -- ! doc id
    orth        INTEGER NOT NULL, -- ! normalized orthographic form id
    offset      INTEGER NOT NULL, -- ! start offset in source file, utf8 chars
    len         INTEGER NOT NULL, -- ! size of token, utf8 chars
    cat            TEXT NOT NULL, -- ! word category id
    lem         INTEGER NOT NULL, -- ! lemma form id
    page                    TEXT, -- ? page number, maybe not int, ex: 8.410 
    line                 INTEGER, -- ? line number
    PRIMARY KEY(id ASC)
);
 -- search an orthographic form in all or some documents
CREATE INDEX IF NOT EXISTS tok_orth ON tok(orth, doc);
 -- search a lemma in all or some documents
CREATE INDEX IF NOT EXISTS tok_lem ON tok(lem, doc);
-- list pos
CREATE INDEX IF NOT EXISTS tok_cat ON tok(cat);


DROP TABLE IF EXISTS orth;
CREATE TABLE orth (
-- Index of orthographic forms
    id                   INTEGER, -- rowid auto
    form           TEXT NOT NULL, -- ! the letters
    deform         TEXT NOT NULL, -- ! letters without accents
    lem                  INTEGER, -- ! (form, cat) -> lemma
    cat                     TEXT, -- ! word category from leammatizer
    flag                 INTEGER, -- ? local flag
    PRIMARY KEY(id ASC)
);
CREATE INDEX IF NOT EXISTS orth_deform ON orth(deform);
CREATE UNIQUE INDEX IF NOT EXISTS orth_form ON orth(form, lem);
CREATE INDEX IF NOT EXISTS orth_lem ON orth(lem);
CREATE INDEX IF NOT EXISTS orth_flag ON orth(flag);

DROP TABLE IF EXISTS lem;
CREATE TABLE lem (
-- Index of lemma
    id                   INTEGER, -- rowid auto
    form           TEXT NOT NULL, -- ! the letters
    deform         TEXT NOT NULL, -- ! letters without accents
    cat                     TEXT, -- ! word category id
    flag                 INTEGER, -- ? local flag
    PRIMARY KEY(id ASC)
);
CREATE INDEX IF NOT EXISTS lem_deform ON lem(deform);
CREATE UNIQUE INDEX IF NOT EXISTS lem_form ON lem(form);
CREATE INDEX IF NOT EXISTS lem_flag ON lem(flag);
