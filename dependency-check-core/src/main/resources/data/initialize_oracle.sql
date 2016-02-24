-- Drop
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE vulnerability_seq';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE cpeEntry_seq';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE software CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE cpeEntry CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE reference CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE vulnerability CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE properties CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;


CREATE TABLE vulnerability (id INT NOT NULL PRIMARY KEY, cve VARCHAR(20) UNIQUE,
    description CLOB, cwe VARCHAR(10), cvssScore DECIMAL(3,1), cvssAccessVector VARCHAR(20),
    cvssAccessComplexity VARCHAR(20), cvssAuthentication VARCHAR(20), cvssConfidentialityImpact VARCHAR(20),
    cvssIntegrityImpact VARCHAR(20), cvssAvailabilityImpact VARCHAR(20));

CREATE TABLE reference (cveid INT, name VARCHAR(1000), url VARCHAR(1000), source VARCHAR(255),
    CONSTRAINT fkReference FOREIGN KEY (cveid) REFERENCES vulnerability(id) ON DELETE CASCADE);

CREATE TABLE cpeEntry (id INT NOT NULL PRIMARY KEY, cpe VARCHAR(250), vendor VARCHAR(255), product VARCHAR(255));

CREATE TABLE software (cveid INT, cpeEntryId INT, previousVersion VARCHAR(50)
    , CONSTRAINT fkSoftwareCve FOREIGN KEY (cveid) REFERENCES vulnerability(id) ON DELETE CASCADE
    , CONSTRAINT fkSoftwareCpeProduct FOREIGN KEY (cpeEntryId) REFERENCES cpeEntry(id));

CREATE INDEX idxVulnerability ON vulnerability(cve);
CREATE INDEX idxReference ON reference(cveid);
CREATE INDEX idxCpe ON cpeEntry(cpe);
CREATE INDEX idxCpeEntry ON cpeEntry(vendor, product);
CREATE INDEX idxSoftwareCve ON software(cveid);
CREATE INDEX idxSoftwareCpe ON software(cpeEntryId);

CREATE TABLE properties (id varchar(50) PRIMARY KEY, value varchar(500));

CREATE SEQUENCE cpeEntry_seq;
CREATE SEQUENCE vulnerability_seq;

CREATE OR REPLACE TRIGGER VULNERABILITY_TRG
BEFORE INSERT
ON VULNERABILITY
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :new.ID := VULNERABILITY_SEQ.nextval;
END VULNERABILITY_TRG;

CREATE OR REPLACE TRIGGER CPEENTRY_TRG
BEFORE INSERT
ON CPEENTRY
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  :new.ID := CPEENTRY_SEQ.nextval;
END CPEENTRY_TRG;
