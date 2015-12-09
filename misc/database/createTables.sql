USE dop;

-- Drop tables
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS EstCoreTaxonMapping;
DROP TABLE IF EXISTS WaramuTaxonMapping;
DROP TABLE IF EXISTS Chapter_Material;
DROP TABLE IF EXISTS Chapter;
DROP TABLE IF EXISTS Portfolio_KeyCompetence;
DROP TABLE IF EXISTS Portfolio_CrossCurricularTheme;
DROP TABLE IF EXISTS Portfolio_TargetGroup;
DROP TABLE IF EXISTS Portfolio_Tag;
DROP TABLE IF EXISTS Portfolio;
DROP TABLE IF EXISTS Page;
DROP TABLE IF EXISTS Translation;
DROP TABLE IF EXISTS TranslationGroup;
DROP TABLE IF EXISTS Material_TargetGroup;
DROP TABLE IF EXISTS Material_KeyCompetence;
DROP TABLE IF EXISTS Material_CrossCurricularTheme;
DROP TABLE IF EXISTS Material_Tag;
DROP TABLE IF EXISTS Material_Taxon;
DROP TABLE IF EXISTS Material_ResourceType;
DROP TABLE IF EXISTS Material_Description;
DROP TABLE IF EXISTS Material_Title;
DROP TABLE IF EXISTS Material_Publisher;
DROP TABLE IF EXISTS Material_Author;
DROP TABLE IF EXISTS LanguageString;
DROP TABLE IF EXISTS LanguageKeyCodes;
DROP TABLE IF EXISTS Material;
DROP TABLE IF EXISTS AuthenticationState;
DROP TABLE IF EXISTS AuthenticatedUser;
DROP TABLE IF EXISTS User;
DROP TABLE IF EXISTS Repository;
DROP TABLE IF EXISTS LicenseType;
DROP TABLE IF EXISTS LanguageTable;
DROP TABLE IF EXISTS IssueDate;
DROP TABLE IF EXISTS Publisher;
DROP TABLE IF EXISTS Tag;
DROP TABLE IF EXISTS KeyCompetence;
DROP TABLE IF EXISTS CrossCurricularTheme;
DROP TABLE IF EXISTS Subtopic;
DROP TABLE IF EXISTS Topic;
DROP TABLE IF EXISTS Module;
DROP TABLE IF EXISTS Specialization;
DROP TABLE IF EXISTS Subject;
DROP TABLE IF EXISTS Domain;
DROP TABLE IF EXISTS EducationalContext;
DROP TABLE IF EXISTS Taxon;
DROP TABLE IF EXISTS ResourceType;
DROP TABLE IF EXISTS Author;

-- Create tables

CREATE TABLE Author (
  id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  name    VARCHAR(255) NOT NULL,
  surname VARCHAR(255) NOT NULL,

  UNIQUE KEY (name, surname)
);

CREATE TABLE ResourceType (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Tag (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE Publisher (
  id      BIGINT AUTO_INCREMENT PRIMARY KEY,
  name    VARCHAR(255) NOT NULL UNIQUE,
  website VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IssueDate (
  id    BIGINT AUTO_INCREMENT PRIMARY KEY,
  day   SMALLINT,
  month SMALLINT,
  year  INTEGER
);

CREATE TABLE LanguageTable (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(255) NOT NULL
);

CREATE TABLE LicenseType (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Taxon (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  level       VARCHAR(255) NOT NULL
);

CREATE TABLE EducationalContext (
  id BIGINT PRIMARY KEY,

  FOREIGN KEY (id)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT
);

CREATE TABLE Domain (
  id                 BIGINT PRIMARY KEY,
  educationalContext BIGINT NOT NULL,

  FOREIGN KEY (id)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (educationalContext)
  REFERENCES EducationalContext (id)
    ON DELETE RESTRICT
);

CREATE TABLE Subject (
  id     BIGINT PRIMARY KEY,
  domain BIGINT NOT NULL,

  FOREIGN KEY (id)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (domain)
  REFERENCES Domain (id)
    ON DELETE RESTRICT
);

CREATE TABLE Specialization (
  id     BIGINT PRIMARY KEY,
  domain BIGINT NOT NULL,

  FOREIGN KEY (id)
            REFERENCES Taxon(id)
            ON DELETE RESTRICT,

  FOREIGN KEY (domain)
            REFERENCES Domain(id)
            ON DELETE RESTRICT
);

CREATE TABLE Module (
  id             BIGINT PRIMARY KEY,
  specialization BIGINT NOT NULL,
  
  FOREIGN KEY (id)
            REFERENCES Taxon(id)
            ON DELETE RESTRICT,
  
  FOREIGN KEY (specialization)
            REFERENCES Specialization(id)
            ON DELETE RESTRICT
);

CREATE TABLE Topic (
  id      BIGINT PRIMARY KEY,
  subject BIGINT,
  domain  BIGINT,

  module  BIGINT,
  
  FOREIGN KEY (id)
            REFERENCES Taxon(id)
            ON DELETE RESTRICT,

  FOREIGN KEY (subject)
            REFERENCES Subject(id)
            ON DELETE RESTRICT,

  FOREIGN KEY (domain)
            REFERENCES Domain(id)
            ON DELETE RESTRICT,
  
  FOREIGN KEY (module)
            REFERENCES Module(id)
            ON DELETE RESTRICT
);

CREATE TABLE Subtopic (
  id      BIGINT PRIMARY KEY,
  topic BIGINT NOT NULL,

  FOREIGN KEY (id)
            REFERENCES Taxon(id)
            ON DELETE RESTRICT,

  FOREIGN KEY (topic)
            REFERENCES Topic(id)
            ON DELETE RESTRICT
);

CREATE TABLE CrossCurricularTheme (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE KeyCompetence (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE Repository (
  id                  BIGINT                   AUTO_INCREMENT PRIMARY KEY,
  baseURL             VARCHAR(255) UNIQUE NOT NULL,
  lastSynchronization TIMESTAMP           NULL DEFAULT NULL,
  schemaName          VARCHAR(255) UNIQUE NOT NULL,
  isEstonianPublisher BOOLEAN
);

CREATE TABLE User (
  id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  userName VARCHAR(255) UNIQUE NOT NULL,
  name     VARCHAR(255)        NOT NULL,
  surName  VARCHAR(255)        NOT NULL,
  idCode   VARCHAR(11) UNIQUE  NOT NULL,
  role     VARCHAR(255)        NOT NULL
);

CREATE TABLE AuthenticatedUser (
  id                 BIGINT  AUTO_INCREMENT PRIMARY KEY,
  user_id            BIGINT              NOT NULL,
  token              VARCHAR(255) UNIQUE NOT NULL,
  firstLogin         BOOLEAN DEFAULT FALSE,
  homeOrganization   VARCHAR(255),
  mails              VARCHAR(255),
  affiliations       VARCHAR(255),
  scopedAffiliations VARCHAR(255),

  FOREIGN KEY (user_id)
  REFERENCES User (id)
    ON DELETE RESTRICT
);

CREATE TABLE AuthenticationState (
  id          BIGINT    AUTO_INCREMENT PRIMARY KEY,
  token       VARCHAR(255) UNIQUE NOT NULL,
  created     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  name        VARCHAR(255),
  surname     VARCHAR(255),
  idCode      VARCHAR(11),
  sessionCode VARCHAR(255)
);

CREATE TABLE Material (
  id                   BIGINT             AUTO_INCREMENT PRIMARY KEY,
  lang                 BIGINT,
  issueDate            BIGINT,
  licenseType          BIGINT,
  source               TEXT      NOT NULL,
  added                TIMESTAMP          DEFAULT CURRENT_TIMESTAMP,
  updated              TIMESTAMP NULL     DEFAULT NULL,
  views                BIGINT    NOT NULL DEFAULT 0,
  picture              LONGBLOB           DEFAULT NULL,
  repositoryIdentifier VARCHAR(255),
  repository           BIGINT,
  creator              BIGINT,
  deleted              BOOLEAN,
  paid                 BOOLEAN            DEFAULT FALSE,
  isSpecialEducation   BOOLEAN            DEFAULT FALSE,

  UNIQUE KEY (repositoryIdentifier, repository),

  FOREIGN KEY (lang)
  REFERENCES LanguageTable (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (issueDate)
  REFERENCES IssueDate (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (repository)
  REFERENCES Repository (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (creator)
  REFERENCES User (id)
    ON DELETE RESTRICT
);

CREATE TABLE LanguageKeyCodes (
  lang BIGINT       NOT NULL,
  code VARCHAR(255) NOT NULL,

  FOREIGN KEY (lang)
  REFERENCES LanguageTable (id)
    ON DELETE RESTRICT
);

CREATE TABLE LanguageString (
  id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  lang      BIGINT,
  textValue TEXT NOT NULL,

  FOREIGN KEY (lang)
  REFERENCES LanguageTable (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Author (
  material BIGINT NOT NULL,
  author   BIGINT NOT NULL,

  PRIMARY KEY (material, author),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (author)
  REFERENCES Author (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Publisher (
  material  BIGINT NOT NULL,
  publisher BIGINT NOT NULL,

  PRIMARY KEY (material, publisher),

  FOREIGN KEY (publisher)
  REFERENCES Publisher (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Title (
  material BIGINT NOT NULL,
  title    BIGINT NOT NULL,

  PRIMARY KEY (material, title),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (title)
  REFERENCES LanguageString (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Description (
  material    BIGINT NOT NULL,
  description BIGINT NOT NULL,

  PRIMARY KEY (material, description),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (description)
  REFERENCES LanguageString (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_ResourceType (
  material     BIGINT NOT NULL,
  resourceType BIGINT NOT NULL,

  PRIMARY KEY (material, resourceType),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (resourceType)
  REFERENCES ResourceType (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Taxon (
  material BIGINT NOT NULL,
  taxon    BIGINT NOT NULL,

  PRIMARY KEY (material, taxon),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (taxon)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_Tag (
  material BIGINT NOT NULL,
  tag      BIGINT NOT NULL,

  PRIMARY KEY (material, tag),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (tag)
  REFERENCES Tag (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_CrossCurricularTheme (
  material             BIGINT NOT NULL,
  crossCurricularTheme BIGINT NOT NULL,

  PRIMARY KEY (material, crossCurricularTheme),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (crossCurricularTheme)
  REFERENCES CrossCurricularTheme (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_KeyCompetence (
  material             BIGINT NOT NULL,
  keyCompetence        BIGINT NOT NULL,

  PRIMARY KEY (material, keyCompetence),

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (keyCompetence)
  REFERENCES KeyCompetence (id)
    ON DELETE RESTRICT
);

CREATE TABLE Material_TargetGroup (
  material BIGINT NOT NULL, 
  targetGroup VARCHAR(255),

  PRIMARY KEY (material, targetGroup),

  FOREIGN KEY (material)
    REFERENCES Material (id)
    ON DELETE RESTRICT
);

CREATE TABLE TranslationGroup (
  id   BIGINT AUTO_INCREMENT PRIMARY KEY,
  lang BIGINT NOT NULL,

  FOREIGN KEY (lang)
  REFERENCES LanguageTable (id)
    ON DELETE RESTRICT
);

CREATE TABLE Translation (
  translationGroup BIGINT,
  translationKey   VARCHAR(255),
  translation      TEXT NOT NULL,

  PRIMARY KEY (translationGroup, translationKey),

  FOREIGN KEY (translationGroup)
  REFERENCES TranslationGroup (id)
    ON DELETE RESTRICT
);

CREATE TABLE Page (
  id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(255) NOT NULL,
  content  TEXT         NOT NULL,
  language BIGINT       NOT NULL,

  UNIQUE KEY (name, language),

  FOREIGN KEY (language)
  REFERENCES LanguageTable (id)
    ON DELETE RESTRICT
);

CREATE TABLE Portfolio (
  id          BIGINT                AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(255) NOT NULL,
  taxon       BIGINT,
  creator     BIGINT       NOT NULL,
  summary     TEXT,
  views       BIGINT       NOT NULL DEFAULT 0,
  created     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated     TIMESTAMP    NULL     DEFAULT NULL,
  picture     LONGBLOB              DEFAULT NULL,
  targetGroup VARCHAR(255),

  FOREIGN KEY (creator)
  REFERENCES User (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (taxon)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT
);

CREATE TABLE Chapter (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  title         VARCHAR(255) NOT NULL,
  textValue     TEXT,
  parentChapter BIGINT,
  portfolio     BIGINT,
  chapterOrder  INTEGER,

  FOREIGN KEY (portfolio)
  REFERENCES Portfolio (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (parentChapter)
  REFERENCES Chapter (id)
    ON DELETE RESTRICT
);

CREATE TABLE Portfolio_Tag (
  portfolio BIGINT NOT NULL,
  tag       BIGINT NOT NULL,

  PRIMARY KEY (portfolio, tag),

  FOREIGN KEY (portfolio)
  REFERENCES Portfolio (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (tag)
  REFERENCES Tag (id)
    ON DELETE RESTRICT
);

CREATE TABLE Portfolio_TargetGroup (
  portfolio   BIGINT NOT NULL, 
  targetGroup VARCHAR(255),

  PRIMARY KEY (portfolio, targetGroup),

  FOREIGN KEY (portfolio)
    REFERENCES Portfolio (id)
    ON DELETE RESTRICT
);

CREATE TABLE Portfolio_CrossCurricularTheme (
  portfolio             BIGINT NOT NULL,
  crossCurricularTheme  BIGINT NOT NULL,

  PRIMARY KEY (portfolio, crossCurricularTheme),

  FOREIGN KEY (portfolio)
  REFERENCES Portfolio (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (crossCurricularTheme)
  REFERENCES CrossCurricularTheme (id)
    ON DELETE RESTRICT
);

CREATE TABLE Portfolio_KeyCompetence (
  portfolio             BIGINT NOT NULL,
  keyCompetence         BIGINT NOT NULL,

  PRIMARY KEY (portfolio, keyCompetence),

  FOREIGN KEY (portfolio)
  REFERENCES Portfolio (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (keyCompetence)
  REFERENCES KeyCompetence (id)
    ON DELETE RESTRICT
);


CREATE TABLE Chapter_Material (
  chapter       BIGINT  NOT NULL,
  material      BIGINT  NOT NULL,
  materialOrder INTEGER NOT NULL,

  PRIMARY KEY (chapter, material),

  FOREIGN KEY (chapter)
  REFERENCES Chapter (id)
    ON DELETE RESTRICT,

  FOREIGN KEY (material)
  REFERENCES Material (id)
    ON DELETE RESTRICT
);

CREATE TABLE WaramuTaxonMapping (
  id    BIGINT PRIMARY KEY,
  name  VARCHAR(255) NOT NULL,
  taxon BIGINT,

  FOREIGN KEY (taxon)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT
);

CREATE TABLE EstCoreTaxonMapping (
  id    BIGINT PRIMARY KEY,
  name  VARCHAR(255) NOT NULL,
  taxon BIGINT,

  FOREIGN KEY (taxon)
  REFERENCES Taxon (id)
    ON DELETE RESTRICT
);

CREATE TABLE Comment (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    text      TEXT NOT NULL,
    creator   BIGINT NOT NULL,
    portfolio BIGINT,
    added     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
    FOREIGN KEY (creator)
    REFERENCES User (id)
      ON DELETE RESTRICT,
    
    FOREIGN KEY (portfolio)
    REFERENCES Portfolio (id)
      ON DELETE RESTRICT
);
