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
    clavis      TEXT UNIQUE NOT NULL, -- ! source filename without extension, unique for base
    epoch       INTEGER NOT NULL,     -- ! file modified time
    octets      INTEGER NOT NULL,     -- ! filesize
    titulus     TEXT NOT NULL,        -- ! title of Opus
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
CREATE UNIQUE INDEX IF NOT EXISTS opus_code ON opus(clavis);


-- Schema to store lemmatized texts
DROP TABLE IF EXISTS doc;
CREATE table doc (
-- an indexed HTML document
    id          INTEGER, -- rowid auto
    -- must, file infos and content
    clavis      TEXT UNIQUE NOT NULL, -- ! source filename without extension, unique for base
    html        BLOB NOT NULL,        -- ! html text ready to display
    opus        INTEGER NOT NULL,     -- ! link to the opus
    ante        INTEGER, -- ? previous document
    post        INTEGER, -- ? next document
    -- should, bibliographic info
    titulus     TEXT,    -- ? title of the document if relevant
    pagde       INTEGER, -- ? page from
    pagad       INTEGER, -- ? page to
    volumen     TEXT,    -- ? analytic, for opus on more than one
    liber       TEXT,    -- ? analytic,
    capitulum   TEXT,    -- ? analytic,
    sectio      TEXT,    -- ? analytic,
    PRIMARY KEY(id ASC)
);
CREATE UNIQUE INDEX IF NOT EXISTS doc_code ON doc(clavis);


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
