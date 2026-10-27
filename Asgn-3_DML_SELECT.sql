-- =====================================================================
-- ASSIGNMENT 3 : DML + SELECT queries on COMPANY database (MySQL)
-- Run:  mysql -u root -p < assignment_03_DML_SELECT.sql
-- Query Sets 1-5 are given by roll number: do only YOUR set.
-- =====================================================================

-- ---------------------------------------------------------------------
-- SETUP : tables + sample data
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS company;
CREATE DATABASE company;
USE company;

CREATE TABLE DEPT (
    DEPTNO INT PRIMARY KEY,
    DNAME  VARCHAR(20),
    LOC    VARCHAR(20)
);

CREATE TABLE EMP (
    EMPNO    INT PRIMARY KEY,
    ENAME    VARCHAR(20),
    JOB      VARCHAR(20),
    MGR      INT,
    HIREDATE DATE,
    SAL      DECIMAL(10,2),
    COMM     DECIMAL(10,2),
    DEPTNO   INT
);

-- Helper: reloads the original data (so every set starts fresh).
DELIMITER $$
CREATE PROCEDURE reset_company()
BEGIN
    DELETE FROM EMP;
    DELETE FROM DEPT;

    INSERT INTO DEPT VALUES
    (10,'ACCOUNTING','NEW YORK'),
    (20,'RESEARCH','DALLAS'),
    (30,'SALES','CHICAGO'),
    (40,'OPERATIONS','BOSTON');

    INSERT INTO EMP VALUES
    (7369,'SMITH',  'CLERK',    7902,'1980-12-17',  800, 300,  20),
    (7499,'ALLEN',  'SALESMAN', 7698,'1981-02-20', 1600, 300,  30),
    (7521,'WARD',   'SALESMAN', 7698,'1981-02-22', 1250, 500,  30),
    (7566,'JONES',  'MANAGER',  7839,'1981-04-02', 2975, NULL, 20),
    (7654,'MARTIN', 'SALESMAN', 7698,'1981-09-28', 1250, 1400, 30),
    (7698,'BLAKE',  'MANAGER',  7839,'1981-05-01', 2850, NULL, 30),
    (7782,'CLARK',  'MANAGER',  7839,'1981-06-09', 2450, NULL, 10),
    (7788,'SCOTT',  'ANALYST',  7566,'1987-04-19', 3000, NULL, 20),
    (7839,'KING',   'PRESIDENT',NULL,'1981-11-17', 5000, NULL, 10),
    (7844,'TURNER', 'SALESMAN', 7698,'1981-09-08', 1500, 0,    30),
    (7876,'ADAMS',  'CLERK',    7788,'1987-05-23', 1100, NULL, 20),
    (7900,'JAMES',  'CLERK',    7698,'1981-12-03',  950, NULL, 30),
    (7902,'FORD',   'ANALYST',  7566,'1981-12-03', 3000, NULL, 20),
    (7934,'MILLER', 'CLERK',    7782,'1982-01-23', 1300, NULL, 10),
    (7000,'ANKUSH', 'CLERK',    7902,'2020-06-04',15000, 600,  20),
    (7999,'PRIYA',  'CLERK',    7902,'2019-12-11',12000, 800,  50);
END$$
DELIMITER ;

CALL reset_company();
SELECT * FROM DEPT;
SELECT * FROM EMP;


-- =====================================================================
-- QUERY SET 1
-- =====================================================================
CALL reset_company();

-- 1. Number of employees and average salary of department 20
SELECT COUNT(*) AS total_emp, AVG(SAL) AS avg_sal
FROM EMP
WHERE DEPTNO = 20;

-- 2. Name, salary and PF (10% of salary)
SELECT ENAME, SAL, SAL * 0.10 AS PF
FROM EMP;

-- 3. Employees in ascending order of salary
SELECT * FROM EMP ORDER BY SAL ASC;

-- 4. Name and hiredate, latest joiner first
SELECT ENAME, HIREDATE FROM EMP ORDER BY HIREDATE DESC;

-- 5. Salary, PF (10%), HRA (50%), DA (30%) and Gross, ordered by gross
SELECT ENAME,
       SAL,
       SAL * 0.10 AS PF,
       SAL * 0.50 AS HRA,
       SAL * 0.30 AS DA,
       SAL + SAL * 0.50 + SAL * 0.30 AS GROSS
FROM EMP
ORDER BY GROSS;

-- 6. Department-wise number of employees
SELECT DEPTNO, COUNT(*) AS total_emp
FROM EMP
GROUP BY DEPTNO;

-- 7. Increase salary of SALESMAN by 10%
UPDATE EMP SET SAL = SAL * 1.10 WHERE JOB = 'SALESMAN';
SELECT ENAME, JOB, SAL FROM EMP WHERE JOB = 'SALESMAN';

-- 8. Total, max, min and average salary of department 20
SELECT SUM(SAL) AS total_sal, MAX(SAL) AS max_sal,
       MIN(SAL) AS min_sal,   AVG(SAL) AS avg_sal
FROM EMP
WHERE DEPTNO = 20;

-- 9. Names whose third letter is 'I'
SELECT ENAME FROM EMP WHERE ENAME LIKE '__I%';

-- 10. Maximum salary of SALESMAN
SELECT MAX(SAL) AS max_salesman_sal FROM EMP WHERE JOB = 'SALESMAN';

-- 11. Increase salary of SALESMAN by 10% (again)
UPDATE EMP SET SAL = SAL * 1.10 WHERE JOB = 'SALESMAN';
SELECT ENAME, JOB, SAL FROM EMP WHERE JOB = 'SALESMAN';


-- =====================================================================
-- QUERY SET 2
-- =====================================================================
CALL reset_company();

-- 1. Name and annual salary, department-wise
SELECT DEPTNO, ENAME, SAL * 12 AS ANNUAL_SAL
FROM EMP
ORDER BY DEPTNO;

-- 2. Five employees with the least salary
SELECT * FROM EMP ORDER BY SAL ASC LIMIT 5;

-- 3. Employees whose deptno is not present in DEPT table
SELECT * FROM EMP
WHERE DEPTNO NOT IN (SELECT DEPTNO FROM DEPT);

-- 4. Employees with odd salary
SELECT * FROM EMP WHERE MOD(SAL, 2) = 1;

-- 5. Employees with a 3-digit salary
SELECT * FROM EMP WHERE SAL BETWEEN 100 AND 999;

-- 6. Employees hired in December
SELECT * FROM EMP WHERE MONTH(HIREDATE) = 12;

-- 7. Names containing the letter 'A'
SELECT ENAME FROM EMP WHERE ENAME LIKE '%A%';

-- 8. Maximum, minimum and average salary
SELECT MAX(SAL) AS max_sal, MIN(SAL) AS min_sal, AVG(SAL) AS avg_sal FROM EMP;

-- 9. Day of the week for a given date (DD-MM-YY)
SELECT DAYNAME(STR_TO_DATE('17-12-80', '%d-%m-%y')) AS day_of_week;

-- 10. Number of characters in each name (spaces not counted)
SELECT ENAME, LENGTH(REPLACE(ENAME, ' ', '')) AS char_count FROM EMP;

-- 11. Employees with salary below 1000, sorted
SELECT * FROM EMP WHERE SAL < 1000 ORDER BY SAL;


-- =====================================================================
-- QUERY SET 3
-- =====================================================================
CALL reset_company();

-- 1. Distinct designations
SELECT DISTINCT JOB FROM EMP;

-- 2. Delete employees who joined in 1980
DELETE FROM EMP WHERE YEAR(HIREDATE) = 1980;
SELECT * FROM EMP;

-- 3. Increase salary of MANAGER by 20%
UPDATE EMP SET SAL = SAL * 1.20 WHERE JOB = 'MANAGER';
SELECT ENAME, JOB, SAL FROM EMP WHERE JOB = 'MANAGER';

-- 4. Employees not in departments 30, 40, 10
SELECT * FROM EMP WHERE DEPTNO NOT IN (30, 40, 10);

-- 5. The different designations with number of employees in each
SELECT JOB, COUNT(*) AS total_emp FROM EMP GROUP BY JOB;

-- 6. Employees not eligible for commission
SELECT * FROM EMP WHERE COMM IS NULL;

-- 7. Names starting or ending with 'S'
SELECT ENAME FROM EMP WHERE ENAME LIKE 'S%' OR ENAME LIKE '%S';

-- 8. Names having 'A' as second letter
SELECT ENAME FROM EMP WHERE ENAME LIKE '_A%';

-- 9. Total number of employees
SELECT COUNT(*) AS total_emp FROM EMP;

-- 10. Hiredate in the format 'June 4,1988'
SELECT ENAME, DATE_FORMAT(HIREDATE, '%M %e,%Y') AS hired_on FROM EMP;

-- 11. Salesmen whose commission is between 200 and 500
SELECT * FROM EMP WHERE JOB = 'SALESMAN' AND COMM BETWEEN 200 AND 500;


-- =====================================================================
-- QUERY SET 4
-- =====================================================================
CALL reset_company();

-- 1. Employees with more than 2 years in the company
SELECT * FROM EMP WHERE TIMESTAMPDIFF(YEAR, HIREDATE, CURDATE()) > 2;

-- 2. Employees ordered by basic salary
SELECT * FROM EMP ORDER BY SAL;

-- 3. Employees whose salary is more than SMITH's salary
SELECT * FROM EMP
WHERE SAL > (SELECT SAL FROM EMP WHERE ENAME = 'SMITH');

-- 4. Increase salary of employee 7499 by 10%
UPDATE EMP SET SAL = SAL * 1.10 WHERE EMPNO = 7499;
SELECT EMPNO, ENAME, SAL FROM EMP WHERE EMPNO = 7499;

-- 5. Salary between 10000 and 25000
SELECT * FROM EMP WHERE SAL BETWEEN 10000 AND 25000;

-- 6. Employees not eligible for commission
SELECT * FROM EMP WHERE COMM IS NULL;

-- 7. Increase salary of CLERK by 10%
UPDATE EMP SET SAL = SAL * 1.10 WHERE JOB = 'CLERK';
SELECT ENAME, JOB, SAL FROM EMP WHERE JOB = 'CLERK';

-- 8. Job-wise total, max, min and average salary
SELECT JOB, SUM(SAL) AS total_sal, MAX(SAL) AS max_sal,
            MIN(SAL) AS min_sal,   AVG(SAL) AS avg_sal
FROM EMP
GROUP BY JOB;

-- 9. Delete employees whose name starts with 'P'
DELETE FROM EMP WHERE ENAME LIKE 'P%';
SELECT * FROM EMP;

-- 10. CLERKs whose commission is more than 500
SELECT * FROM EMP WHERE JOB = 'CLERK' AND COMM > 500;

-- 11. Employees of departments 20, 30 and 40
SELECT * FROM EMP WHERE DEPTNO IN (20, 30, 40);


-- =====================================================================
-- QUERY SET 5
-- =====================================================================
CALL reset_company();

-- 1. Annual salary, job-wise
SELECT JOB, ENAME, SAL * 12 AS ANNUAL_SAL
FROM EMP
ORDER BY JOB;

-- 2. Delete employees whose name starts with 'A' or 'R'
DELETE FROM EMP WHERE ENAME LIKE 'A%' OR ENAME LIKE 'R%';
SELECT * FROM EMP;

-- 3. Increase salary of employee 7000 by 30%
UPDATE EMP SET SAL = SAL * 1.30 WHERE EMPNO = 7000;
SELECT EMPNO, ENAME, SAL FROM EMP WHERE EMPNO = 7000;

-- 4. Hire-date-wise total, max, min and average salary
SELECT HIREDATE, SUM(SAL) AS total_sal, MAX(SAL) AS max_sal,
                 MIN(SAL) AS min_sal,   AVG(SAL) AS avg_sal
FROM EMP
GROUP BY HIREDATE;

-- 5. Names whose last letter is 'T'
SELECT ENAME FROM EMP WHERE ENAME LIKE '%T';

-- 6. Employees whose salary is less than ANKUSH's salary
SELECT * FROM EMP
WHERE SAL < (SELECT SAL FROM EMP WHERE ENAME = 'ANKUSH');

-- 7. Salary between 10000 and 25000 (upper limit is not given in the slide)
SELECT * FROM EMP WHERE SAL BETWEEN 10000 AND 25000;

-- 8. Employees of departments 30, 40 and 10
SELECT * FROM EMP WHERE DEPTNO IN (30, 40, 10);

-- 9. CLERKs whose salary is more than 5000
SELECT * FROM EMP WHERE JOB = 'CLERK' AND SAL > 5000;

-- 10. CLERKs whose commission is more than 500, highest commission first
SELECT * FROM EMP WHERE JOB = 'CLERK' AND COMM > 500 ORDER BY COMM DESC;
