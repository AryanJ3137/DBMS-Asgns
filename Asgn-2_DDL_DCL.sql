-- =====================================================================
-- ASSIGNMENT 2 : DDL + DCL  (MySQL)
-- Run:  mysql -u root -p < assignment_02_DDL_DCL.sql
-- =====================================================================


-- =====================================================================
-- BATCH 1 : UNIVERSITY DATABASE
-- =====================================================================
DROP DATABASE IF EXISTS a2_university;
CREATE DATABASE a2_university;
USE a2_university;

-- ---- CREATE TABLES (parents first, children later) ----
CREATE TABLE COURSE (
    CourseNo  VARCHAR(10) PRIMARY KEY,
    Title     VARCHAR(100) NOT NULL,
    Credits   INT NOT NULL CHECK (Credits > 0),
    Syllabus  VARCHAR(255)
);

CREATE TABLE STUDENT (
    StudentID INT PRIMARY KEY,
    Name      VARCHAR(50) NOT NULL,
    Program   VARCHAR(50)
);

CREATE TABLE INSTRUCTOR (
    InstructorID INT PRIMARY KEY,
    Name         VARCHAR(50) NOT NULL,
    Department   VARCHAR(50),
    Title        VARCHAR(50)
);

CREATE TABLE COURSE_OFFERING (
    OfferingID INT PRIMARY KEY,
    CourseNo   VARCHAR(10) NOT NULL,
    Year       INT NOT NULL,
    Semester   VARCHAR(10) NOT NULL,
    SectionNo  INT NOT NULL,
    Timings    VARCHAR(30),
    Classroom  VARCHAR(20),
    FOREIGN KEY (CourseNo) REFERENCES COURSE(CourseNo)
);

CREATE TABLE ENROLLMENT (
    StudentID  INT,
    OfferingID INT,
    Grade      CHAR(2),
    PRIMARY KEY (StudentID, OfferingID),
    FOREIGN KEY (StudentID)  REFERENCES STUDENT(StudentID),
    FOREIGN KEY (OfferingID) REFERENCES COURSE_OFFERING(OfferingID)
);

CREATE TABLE COURSE_PREREQUISITE (
    CourseNo             VARCHAR(10),
    PrerequisiteCourseNo VARCHAR(10),
    PRIMARY KEY (CourseNo, PrerequisiteCourseNo),
    FOREIGN KEY (CourseNo)             REFERENCES COURSE(CourseNo),
    FOREIGN KEY (PrerequisiteCourseNo) REFERENCES COURSE(CourseNo)
);

CREATE TABLE COURSE_OFFERING_INSTRUCTOR (
    OfferingID   INT,
    InstructorID INT,
    PRIMARY KEY (OfferingID, InstructorID),
    FOREIGN KEY (OfferingID)   REFERENCES COURSE_OFFERING(OfferingID),
    FOREIGN KEY (InstructorID) REFERENCES INSTRUCTOR(InstructorID)
);

SHOW TABLES;

-- ---- ALTER ----
ALTER TABLE STUDENT ADD COLUMN Email VARCHAR(80);                 -- add column
ALTER TABLE STUDENT MODIFY COLUMN Name VARCHAR(100);              -- change datatype
ALTER TABLE STUDENT RENAME COLUMN Program TO Course_Program;      -- rename column
ALTER TABLE STUDENT DROP COLUMN Email;                            -- drop column
ALTER TABLE INSTRUCTOR RENAME TO FACULTY;                         -- rename table
ALTER TABLE FACULTY RENAME TO INSTRUCTOR;                         -- rename back
DESC STUDENT;

-- ---- INSERT + TRUNCATE ----
INSERT INTO STUDENT VALUES (1, 'Amit', 'AIDS'), (2, 'Riya', 'CSE');
SELECT * FROM STUDENT;
TRUNCATE TABLE ENROLLMENT;          -- removes all rows, keeps the table

-- ---- DROP TABLE ----
DROP TABLE ENROLLMENT;
DROP TABLE COURSE_OFFERING_INSTRUCTOR;
SHOW TABLES;


-- =====================================================================
-- BATCH 2 : MOVIE / STREAMING DATABASE
-- =====================================================================
DROP DATABASE IF EXISTS a2_movie;
CREATE DATABASE a2_movie;
USE a2_movie;

CREATE TABLE DIRECTOR (
    DirectorID      INT PRIMARY KEY,
    Name            VARCHAR(50) NOT NULL,
    DOB             DATE,
    ExperienceYears INT CHECK (ExperienceYears >= 0)
);

CREATE TABLE PRODUCTION_HOUSE (
    HouseID     INT PRIMARY KEY,
    Name        VARCHAR(50) NOT NULL,
    Location    VARCHAR(50),
    FoundedYear INT
);

CREATE TABLE ACTOR (
    ActorID     INT PRIMARY KEY,
    Name        VARCHAR(50) NOT NULL,
    DOB         DATE,
    Gender      CHAR(1) CHECK (Gender IN ('M','F','O')),
    Nationality VARCHAR(30)
);

CREATE TABLE MOVIE (
    MovieID     INT PRIMARY KEY,
    Title       VARCHAR(100) NOT NULL,
    ReleaseYear INT,
    Genre       VARCHAR(30),
    Duration    INT CHECK (Duration > 0),
    Language    VARCHAR(30),
    Budget      DECIMAL(15,2),
    DirectorID  INT,
    HouseID     INT,
    FOREIGN KEY (DirectorID) REFERENCES DIRECTOR(DirectorID),
    FOREIGN KEY (HouseID)    REFERENCES PRODUCTION_HOUSE(HouseID)
);

CREATE TABLE MOVIE_ACTOR (
    MovieID INT,
    ActorID INT,
    PRIMARY KEY (MovieID, ActorID),
    FOREIGN KEY (MovieID) REFERENCES MOVIE(MovieID),
    FOREIGN KEY (ActorID) REFERENCES ACTOR(ActorID)
);

CREATE TABLE SUBSCRIBER (
    SubscriberID     INT PRIMARY KEY,
    Name             VARCHAR(50) NOT NULL,
    Email            VARCHAR(80) NOT NULL UNIQUE,
    SubscriptionType VARCHAR(20),
    JoinDate         DATE
);

CREATE TABLE VIEWING_HISTORY (
    SubscriberID     INT,
    MovieID          INT,
    WatchDate        DATE,
    WatchDuration    INT,
    CompletionStatus VARCHAR(20),
    PRIMARY KEY (SubscriberID, MovieID, WatchDate),
    FOREIGN KEY (SubscriberID) REFERENCES SUBSCRIBER(SubscriberID),
    FOREIGN KEY (MovieID)      REFERENCES MOVIE(MovieID)
);

CREATE TABLE RATING (
    SubscriberID INT,
    MovieID      INT,
    RatingValue  INT CHECK (RatingValue BETWEEN 1 AND 5),
    ReviewText   VARCHAR(255),
    RatingDate   DATE,
    PRIMARY KEY (SubscriberID, MovieID),
    FOREIGN KEY (SubscriberID) REFERENCES SUBSCRIBER(SubscriberID),
    FOREIGN KEY (MovieID)      REFERENCES MOVIE(MovieID)
);

SHOW TABLES;

-- ---- ALTER ----
ALTER TABLE ACTOR ADD COLUMN Email VARCHAR(80);
ALTER TABLE ACTOR MODIFY COLUMN Nationality VARCHAR(50);
ALTER TABLE ACTOR RENAME COLUMN Nationality TO Country;
ALTER TABLE ACTOR DROP COLUMN Email;
ALTER TABLE ACTOR RENAME TO ARTIST;
ALTER TABLE ARTIST RENAME TO ACTOR;
DESC ACTOR;

-- ---- INSERT + TRUNCATE ----
INSERT INTO ACTOR VALUES (1, 'Shah', '1980-01-01', 'M', 'Indian');
SELECT * FROM ACTOR;
TRUNCATE TABLE RATING;

-- ---- DROP TABLE ----
DROP TABLE RATING;
DROP TABLE VIEWING_HISTORY;
SHOW TABLES;


-- =====================================================================
-- BATCH 3 : TOURISM DATABASE
-- =====================================================================
DROP DATABASE IF EXISTS a2_tourism;
CREATE DATABASE a2_tourism;
USE a2_tourism;

CREATE TABLE TOURIST (
    TouristID  INT PRIMARY KEY,
    Name       VARCHAR(50) NOT NULL,
    Email      VARCHAR(80) UNIQUE,
    Phone      VARCHAR(15),
    Address    VARCHAR(100),
    PassportNo VARCHAR(20) UNIQUE
);

CREATE TABLE TOUR_PACKAGE (
    PackageID    INT PRIMARY KEY,
    PackageName  VARCHAR(50) NOT NULL,
    DurationDays INT CHECK (DurationDays > 0),
    BasePrice    DECIMAL(10,2) CHECK (BasePrice >= 0),
    Description  VARCHAR(255)
);

CREATE TABLE DESTINATION (
    DestinationID INT PRIMARY KEY,
    Name          VARCHAR(50) NOT NULL,
    City          VARCHAR(50),
    Country       VARCHAR(50),
    Description   VARCHAR(255)
);

CREATE TABLE HOTEL (
    HotelID       INT PRIMARY KEY,
    Name          VARCHAR(50) NOT NULL,
    City          VARCHAR(50),
    StarRating    INT CHECK (StarRating BETWEEN 1 AND 5),
    PricePerNight DECIMAL(10,2)
);

CREATE TABLE GUIDE (
    GuideID         INT PRIMARY KEY,
    Name            VARCHAR(50) NOT NULL,
    Language        VARCHAR(30),
    ExperienceYears INT
);

CREATE TABLE BOOKING (
    BookingID   INT PRIMARY KEY,
    TouristID   INT NOT NULL,
    PackageID   INT NOT NULL,
    BookingDate DATE,
    StartDate   DATE,
    EndDate     DATE,
    TotalAmount DECIMAL(10,2),
    Status      VARCHAR(20),
    FOREIGN KEY (TouristID) REFERENCES TOURIST(TouristID),
    FOREIGN KEY (PackageID) REFERENCES TOUR_PACKAGE(PackageID)
);

CREATE TABLE REVIEW (
    ReviewID   INT PRIMARY KEY,
    TouristID  INT NOT NULL,
    PackageID  INT NOT NULL,
    Rating     INT CHECK (Rating BETWEEN 1 AND 5),
    Comment    VARCHAR(255),
    ReviewDate DATE,
    FOREIGN KEY (TouristID) REFERENCES TOURIST(TouristID),
    FOREIGN KEY (PackageID) REFERENCES TOUR_PACKAGE(PackageID)
);

CREATE TABLE PACKAGE_DESTINATION (
    PackageID     INT,
    DestinationID INT,
    PRIMARY KEY (PackageID, DestinationID),
    FOREIGN KEY (PackageID)     REFERENCES TOUR_PACKAGE(PackageID),
    FOREIGN KEY (DestinationID) REFERENCES DESTINATION(DestinationID)
);

CREATE TABLE PACKAGE_HOTEL (
    PackageID INT,
    HotelID   INT,
    PRIMARY KEY (PackageID, HotelID),
    FOREIGN KEY (PackageID) REFERENCES TOUR_PACKAGE(PackageID),
    FOREIGN KEY (HotelID)   REFERENCES HOTEL(HotelID)
);

CREATE TABLE PACKAGE_GUIDE (
    PackageID INT,
    GuideID   INT,
    PRIMARY KEY (PackageID, GuideID),
    FOREIGN KEY (PackageID) REFERENCES TOUR_PACKAGE(PackageID),
    FOREIGN KEY (GuideID)   REFERENCES GUIDE(GuideID)
);

SHOW TABLES;

-- ---- ALTER ----
ALTER TABLE GUIDE ADD COLUMN Phone VARCHAR(15);
ALTER TABLE GUIDE MODIFY COLUMN Language VARCHAR(50);
ALTER TABLE GUIDE RENAME COLUMN Language TO SpokenLanguage;
ALTER TABLE GUIDE DROP COLUMN Phone;
ALTER TABLE GUIDE RENAME TO TOUR_GUIDE;
ALTER TABLE TOUR_GUIDE RENAME TO GUIDE;
DESC GUIDE;

-- ---- INSERT + TRUNCATE ----
INSERT INTO GUIDE VALUES (1, 'Ravi', 'Hindi', 5);
SELECT * FROM GUIDE;
TRUNCATE TABLE REVIEW;

-- ---- DROP TABLE ----
DROP TABLE REVIEW;
DROP TABLE PACKAGE_GUIDE;
SHOW TABLES;


-- =====================================================================
-- DCL : USERS AND PRIVILEGES  (same for every batch)
-- =====================================================================
DROP USER IF EXISTS 'sample'@'localhost';
CREATE USER 'sample'@'localhost' IDENTIFIED BY 'Sample@123';

GRANT SELECT, INSERT ON a2_tourism.* TO 'sample'@'localhost';
SHOW GRANTS FOR 'sample'@'localhost';

REVOKE INSERT ON a2_tourism.* FROM 'sample'@'localhost';
SHOW GRANTS FOR 'sample'@'localhost';

DROP USER 'sample'@'localhost';


-- =====================================================================
-- DROP DATABASE  (clean-up)
-- =====================================================================
DROP DATABASE a2_university;
DROP DATABASE a2_movie;
DROP DATABASE a2_tourism;
