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
    id          INTEGER, -- rowid auto
    clavis      TEXT UNIQUE NOT NULL, -- ! identifier
    bibl        BLOB,                 -- ! html bibl record
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX opus_clavis ON opus(clavis);

DROP TABLE IF EXISTS editio;
CREATE table editio (
-- Source XML file
    id          INTEGER, -- rowid auto
    -- must, file infos and content
    clavis      TEXT UNIQUE NOT NULL, -- ! source filename without extension, unique for base
    bibl        BLOB,                 -- ! html text ready to display
    epoch       INTEGER NOT NULL,     -- ! file modified time
    octets      INTEGER NOT NULL,     -- ! filesize
    titulus     TEXT NOT NULL,        -- ! title of an edition
    nav         BLOB,                 -- ? html table of contents if more than one chapter
    -- should, bibliographic info
    auctor      TEXT,    -- ? name of an author
    editor      TEXT,    -- ? name of an editor
    editio      TEXT,    -- ? code for an edittion
    volumen     TEXT,    -- ? volume
    annuspub    INTEGER, -- ? publication year of the edition
    pagde       INTEGER, -- ? page from
    pagad       INTEGER, -- ? page to
    titulbrev   TEXT,    -- ? title abbreviated
    annuscrea   INTEGER, -- ? creation year
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS editio_clavis ON editio(clavis);


-- Schema to store lemmatized texts
DROP TABLE IF EXISTS doc;
CREATE table doc (
-- an indexed HTML document
    id          INTEGER, -- rowid auto
    -- must, file infos and content
    clavis      TEXT UNIQUE NOT NULL, -- ! identifier for section
    html        BLOB NOT NULL,        -- ! html text ready to display
    editio      INTEGER NOT NULL,     -- ! link to the edition
    ante        INTEGER, -- ? previous document
    post        INTEGER, -- ? next document

    -- should, bibliographic info
    editor      TEXT,    -- ? replicated from edition, for efficient filtering
    titulus     TEXT,    -- ? title of the document if relevant
    
    volumen     TEXT,    -- ? analytic, for edition on more than one
    pagde       INTEGER, -- ? page from
    linde       INTEGER, -- ? first line of first page
    pagad       INTEGER, -- ? page to
    linad       INTEGER, -- ? last line of last page

    liber       TEXT,    -- ? analytic,
    capitulum   TEXT,    -- ? analytic,
    sectio      TEXT,    -- ? analytic,
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS doc_code ON doc(clavis);
CREATE INDEX IF NOT EXISTS doc_redir ON doc(editor, volumen, pagde, pagad);


DROP TABLE IF EXISTS tok;
CREATE TABLE tok (
-- compiled table of occurrences
    id          INTEGER, -- rowid auto
    doc         INTEGER NOT NULL,  -- ! doc id
    orth        INTEGER NOT NULL,  -- ! normalized orthographic form id
    charde      INTEGER NOT NULL,  -- ! start offset in source file, utf8 chars
    charad      INTEGER NOT NULL,  -- ! size of token, utf8 chars
    cat         TEXT    NOT NULL,  -- ! word category id
    lem         INTEGER NOT NULL,  -- ! lemma form id
    pag         INTEGER,           -- ? page number
    linea       INTEGER,           -- ? line number
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
    id          INTEGER, -- rowid auto
    form        TEXT NOT NULL,     -- ! the letters
    deform      TEXT NOT NULL,     -- ! letters without accents
    lem         INTEGER,           -- ! (form, cat) -> lemma
    cat         TEXT,              -- ! word category from leammatizer
    flag        INTEGER,           -- ? local flag
    PRIMARY KEY(id ASC)
);
CREATE INDEX IF NOT EXISTS orth_deform ON orth(deform);
CREATE UNIQUE INDEX IF NOT EXISTS orth_form ON orth(form, lem);
CREATE INDEX IF NOT EXISTS orth_lem ON orth(lem);
CREATE INDEX IF NOT EXISTS orth_flag ON orth(flag);

DROP TABLE IF EXISTS lem;
CREATE TABLE lem (
-- Index of lemma
    id          INTEGER, -- rowid auto
    form        TEXT NOT NULL,     -- ! the letters
    deform      TEXT NOT NULL,     -- ! letters without accents
    cat         TEXT,              -- ! word category id
    flag        INTEGER,           -- ? local flag
    PRIMARY KEY(id ASC)
);
CREATE INDEX IF NOT EXISTS lem_deform ON lem(deform);
CREATE UNIQUE INDEX IF NOT EXISTS lem_form ON lem(form);
CREATE INDEX IF NOT EXISTS lem_flag ON lem(flag);
