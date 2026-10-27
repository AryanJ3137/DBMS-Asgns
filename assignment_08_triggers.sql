-- =====================================================================
-- ASSIGNMENT 8 : Triggers (MySQL)
-- Run:  mysql -u root -p < assignment_08_triggers.sql
-- =====================================================================


-- #####################################################################
-- BATCH 1 : Friend symmetry
-- Rule: (A,B) inserted/deleted in Friend  ->  (B,A) inserted/deleted too.
--
-- MySQL problem: a trigger is NOT allowed to change its own table
-- (ERROR 1442). So the textbook trigger
--       AFTER INSERT ON Friend ... INSERT INTO Friend VALUES (NEW.ID2, NEW.ID1)
-- fails. Fix: keep the reversed pairs in a second table, Friend_Mirror.
-- #####################################################################
DROP DATABASE IF EXISTS a8_batch1;
CREATE DATABASE a8_batch1;
USE a8_batch1;

CREATE TABLE Highschooler (ID INT PRIMARY KEY, name VARCHAR(50), grade INT);
CREATE TABLE Friend       (ID1 INT, ID2 INT);
CREATE TABLE Likes        (ID1 INT, ID2 INT);
CREATE TABLE Friend_Mirror(ID1 INT, ID2 INT);       -- stores the reversed pairs

INSERT INTO Highschooler VALUES (1,'Amit',9),(2,'Riya',10),(3,'Karan',11);

DELIMITER $$
CREATE TRIGGER friend_ins
AFTER INSERT ON Friend
FOR EACH ROW
BEGIN
    INSERT INTO Friend_Mirror VALUES (NEW.ID2, NEW.ID1);
END$$

CREATE TRIGGER friend_del
AFTER DELETE ON Friend
FOR EACH ROW
BEGIN
    DELETE FROM Friend_Mirror WHERE ID1 = OLD.ID2 AND ID2 = OLD.ID1;
END$$
DELIMITER ;

-- test
INSERT INTO Friend VALUES (1,2);
INSERT INTO Friend VALUES (2,3);
SELECT * FROM Friend;
SELECT * FROM Friend_Mirror;                        -- (2,1) and (3,2)

DELETE FROM Friend WHERE ID1 = 1 AND ID2 = 2;
SELECT * FROM Friend_Mirror;                        -- only (3,2) is left

-- complete friendship list (both directions)
SELECT ID1, ID2 FROM Friend
UNION
SELECT ID1, ID2 FROM Friend_Mirror;


-- #####################################################################
-- BATCH 2 : Keep AUTHOR.SoldCopies up to date
--   book_upd    : SoldCopies of a BOOK changes  -> authors of that book change by the difference
--   writing_ins : new (Isbn, Name) in WRITING   -> author gets the book's SoldCopies added
-- #####################################################################
DROP DATABASE IF EXISTS a8_batch2;
CREATE DATABASE a8_batch2;
USE a8_batch2;

CREATE TABLE BOOK    (Isbn VARCHAR(20) PRIMARY KEY, Title VARCHAR(100), SoldCopies INT);
CREATE TABLE AUTHOR  (Name VARCHAR(50) PRIMARY KEY, SoldCopies INT DEFAULT 0);
CREATE TABLE WRITING (Isbn VARCHAR(20), Name VARCHAR(50));

DELIMITER $$
CREATE TRIGGER book_upd
AFTER UPDATE ON BOOK
FOR EACH ROW
BEGIN
    UPDATE AUTHOR
    SET SoldCopies = SoldCopies + (NEW.SoldCopies - OLD.SoldCopies)
    WHERE Name IN (SELECT Name FROM WRITING WHERE Isbn = NEW.Isbn);
END$$

CREATE TRIGGER writing_ins
AFTER INSERT ON WRITING
FOR EACH ROW
BEGIN
    UPDATE AUTHOR
    SET SoldCopies = SoldCopies + (SELECT SoldCopies FROM BOOK WHERE Isbn = NEW.Isbn)
    WHERE Name = NEW.Name;
END$$
DELIMITER ;

-- test
INSERT INTO BOOK   VALUES ('B1','DBMS Basics',100);
INSERT INTO AUTHOR VALUES ('Amit',0),('Riya',0);

INSERT INTO WRITING VALUES ('B1','Amit');           -- Amit gets +100
INSERT INTO WRITING VALUES ('B1','Riya');           -- Riya gets +100
SELECT * FROM AUTHOR;                               -- Amit 100, Riya 100

UPDATE BOOK SET SoldCopies = 150 WHERE Isbn = 'B1'; -- both authors get +50
SELECT * FROM AUTHOR;                               -- Amit 150, Riya 150


-- #####################################################################
-- BATCH 3 : Reject an Enrollment if Student or COURSEYEAR does not exist
-- (Columns renamed: #Students -> Students, #ExternalStuds -> ExternalStuds,
--  Date -> EnrollDate, because # and DATE are awkward names in MySQL.)
-- A BEFORE INSERT trigger stops the insert with SIGNAL = "rollback".
-- #####################################################################
DROP DATABASE IF EXISTS a8_batch3;
CREATE DATABASE a8_batch3;
USE a8_batch3;

CREATE TABLE STUDENT (
    ID            INT PRIMARY KEY,
    Name          VARCHAR(50),
    Address       VARCHAR(100),
    Phone         VARCHAR(15),
    Faculty       VARCHAR(50),
    Year          INT,
    Campus        VARCHAR(30),
    EarnedCredits INT
);

CREATE TABLE COURSE (
    CourseCode VARCHAR(10) PRIMARY KEY,
    Name       VARCHAR(50),
    Credits    INT,
    Campus     VARCHAR(30)
);

CREATE TABLE COURSEYEAR (
    CourseCode     VARCHAR(10),
    Year           INT,
    Teacher        VARCHAR(50),
    Quarter        INT,
    Students       INT,
    ExternalStuds  INT,
    PRIMARY KEY (CourseCode, Year)
);

CREATE TABLE ENROLLMENT (
    StudID     INT,
    CourseCode VARCHAR(10),
    Year       INT,
    EnrollDate DATE
);

DELIMITER $$
CREATE TRIGGER enrollment_check
BEFORE INSERT ON ENROLLMENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM STUDENT WHERE ID = NEW.StudID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enrollment rejected: student does not exist';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM COURSEYEAR
                   WHERE CourseCode = NEW.CourseCode AND Year = NEW.Year) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Enrollment rejected: course-year does not exist';
    END IF;
END$$
DELIMITER ;

-- test
INSERT INTO STUDENT    VALUES (1,'Amit','Pune','9999999999','Engineering',2,'Pune',40);
INSERT INTO COURSE     VALUES ('DB101','DBMS',4,'Pune');
INSERT INTO COURSEYEAR VALUES ('DB101',2026,'Prof. Rao',1,60,5);

INSERT INTO ENROLLMENT VALUES (1,'DB101',2026,CURDATE());   -- OK
-- run these two one by one in the terminal; each one gives the expected ERROR:
-- INSERT INTO ENROLLMENT VALUES (9,'DB101',2026,CURDATE());   -- student missing
-- INSERT INTO ENROLLMENT VALUES (1,'DB999',2026,CURDATE());   -- course-year missing
SELECT * FROM ENROLLMENT;                                   -- only the first row
