PRAGMA encoding = 'UTF-8'; -- W. encoding used for output
PRAGMA page_size = 32768; -- W. said as best for perfs
PRAGMA mmap_size = 1073741824; -- W/R. should be more efficient
-- to be executed before write
PRAGMA foreign_keys = 0; -- W. for efficiency
-- PRAGMA journal_mode = OFF; -- W. Dangerous, no roll back, maybe efficient
-- PRAGMA synchronous = OFF; -- W. Dangerous, but no parallel write check

DROP TABLE IF EXISTS opus;
CREATE table opus (
-- Source XML file
    id          INTEGER, -- rowid auto
    -- must, file infos and content
    identifier  TEXT UNIQUE NOT NULL, -- ! source filename without extension, unique for base
    filemtime   INTEGER NOT NULL,     -- ! modified time
    filesize    INTEGER NOT NULL,     -- ! filesize
    title       TEXT NOT NULL,        -- ! title of Opus
    toc         BLOB,                 -- ? html toc if more than one chapter
    -- should, bibliographic info
    author      TEXT,    -- ? name of an editor
    editor      TEXT,    -- ? name of an editor
    volume      TEXT,    -- ? volume
    issued      INTEGER, -- ? publication year of the text
    pagefrom    INTEGER, -- ? page from
    pageto      INTEGER, -- ? page to
    edition     TEXT,    -- ? code for an edittion
    titleshort  TEXT,    -- ? title abbreviated
    created     INTEGER, -- ? creation year of the text
    PRIMARY KEY(id ASC)
);


-- Schema to store lemmatized texts
DROP TABLE IF EXISTS doc;
CREATE table doc (
-- an indexed HTML document
    id          INTEGER, -- rowid auto
    -- must, file infos and content
    identifier  TEXT UNIQUE NOT NULL, -- ! source filename without extension, unique for base
    html        BLOB NOT NULL,        -- ! html text ready to display
    opus        INTEGER NOT NULL,     -- ! link to the opus
    prev        INTEGER, -- ? page to
    next        INTEGER, -- ? page to
    -- should, bibliographic info
    pagefrom    INTEGER, -- ? page from
    pageto      INTEGER, -- ? page to
    book        TEXT,    -- ? analytic,
    chapter     TEXT,    -- ? analytic,
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS doc_identifier ON doc(identifier);


DROP TABLE IF EXISTS tok;
CREATE TABLE tok (
-- compiled table of occurrences
    id          INTEGER, -- rowid auto
    doc         INTEGER NOT NULL,  -- ! doc id
    orth        INTEGER NOT NULL,  -- ! normalized orthographic form id
    cat         TEXT    NOT NULL,  -- ! word category id
    lem         INTEGER NOT NULL,  -- ! lemma form id
    offset      INTEGER NOT NULL,  -- ! start offset in source file, utf8 chars
    length      INTEGER NOT NULL,  -- ! size of token, utf8 chars
    page        INTEGER,           -- ? page number
    line        INTEGER,           -- ? line number
    PRIMARY KEY(id ASC)
);
 -- search an orthographic form in all or some documents
CREATE INDEX IF NOT EXISTS tok_orth ON tok(orth, doc);
 -- search a lemma in all or some documents
CREATE INDEX IF NOT EXISTS tok_lem ON tok(lem, doc);


DROP TABLE IF EXISTS orth;
CREATE TABLE orth (
-- Index of orthographic forms
    id          INTEGER, -- rowid auto
    form        TEXT NOT NULL,     -- ! letters of orthographic form
    cat         INTEGER,           -- ! word category id
    lem         INTEGER,           -- ! (form, cat) -> lemma
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS orth_form ON orth(form, cat);
CREATE INDEX IF NOT EXISTS orth_lem ON orth(lem);

DROP TABLE IF EXISTS lem;
CREATE TABLE lem (
-- Index of lemma
    id          INTEGER, -- rowid auto
    form        TEXT NOT NULL,     -- ! letters of orthographic form
    cat         INTEGER,           -- ! word category id
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS lem_form ON lem(form, cat);
