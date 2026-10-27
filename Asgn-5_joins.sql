-- =====================================================================
-- ASSIGNMENT 5 : JOINS (MySQL)
-- Run:  mysql -u root -p < assignment_05_joins.sql
-- =====================================================================

-- ##################  BATCH A - SET 1 (Restaurant duty)  ##################
DROP DATABASE IF EXISTS lab5_a1; CREATE DATABASE lab5_a1; USE lab5_a1;

CREATE TABLE Employee (emp_no INT PRIMARY KEY, name VARCHAR(50), skill VARCHAR(50), pay_rate DECIMAL(8,2));
CREATE TABLE Position (posting_no INT PRIMARY KEY, skill VARCHAR(50));
CREATE TABLE Duty_allocation (posting_no INT, emp_no INT, day DATE, shift VARCHAR(20));

INSERT INTO Employee VALUES
(1,'Amit','Cook',300),(2,'Riya','Waiter',250),(3,'Karan','Cook',320),(4,'Neha','Cleaner',200);
INSERT INTO Position VALUES (101,'Cook'),(102,'Waiter'),(103,'Manager');
INSERT INTO Duty_allocation VALUES
(101,1,'2026-10-20','Morning'),(102,2,'2026-10-20','Evening'),(101,3,'2026-10-21','Morning');

-- Q1
SELECT e.name, d.posting_no, d.shift
FROM Employee e
INNER JOIN Duty_allocation d ON e.emp_no = d.emp_no
WHERE d.day = '2026-10-20';

-- Q2
SELECT e.name, d.posting_no, d.shift
FROM Employee e
LEFT JOIN Duty_allocation d ON e.emp_no = d.emp_no AND d.day = '2026-10-20';

-- Q3
SELECT p.posting_no, p.skill, e.name
FROM Position p
LEFT JOIN Duty_allocation d ON p.posting_no = d.posting_no AND d.day = '2026-10-20'
LEFT JOIN Employee e ON e.emp_no = d.emp_no;

-- Q4
SELECT e.name, p.posting_no, d.shift
FROM Employee e
LEFT JOIN Duty_allocation d ON e.emp_no = d.emp_no AND d.day = '2026-10-20'
LEFT JOIN Position p ON p.posting_no = d.posting_no
UNION
SELECT e.name, p.posting_no, d.shift
FROM Position p
LEFT JOIN Duty_allocation d ON p.posting_no = d.posting_no AND d.day = '2026-10-20'
LEFT JOIN Employee e ON e.emp_no = d.emp_no;

-- Q5
SELECT e1.name AS employee1, e2.name AS employee2, e1.skill
FROM Employee e1
INNER JOIN Employee e2 ON e1.skill = e2.skill AND e1.emp_no < e2.emp_no;

-- ##################  BATCH A - SET 2 (Employee / Zip)  ##################
DROP DATABASE IF EXISTS lab5_a2; CREATE DATABASE lab5_a2; USE lab5_a2;

CREATE TABLE emp (eno INT PRIMARY KEY, ename VARCHAR(50), Zip VARCHAR(10), hdate DATE);
CREATE TABLE parts (pno INT PRIMARY KEY, pname VARCHAR(50), qty_on_hand INT, price DECIMAL(8,2));
CREATE TABLE customer (cno INT PRIMARY KEY, cname VARCHAR(50), street VARCHAR(50), Zip VARCHAR(10), phone VARCHAR(15));
CREATE TABLE orders (ono INT PRIMARY KEY, cno INT, receivedate DATE, shippeddate DATE);
CREATE TABLE odetails (ono INT, pno INT, qty INT);
CREATE TABLE zipcode (Zip VARCHAR(10) PRIMARY KEY, city VARCHAR(50));

INSERT INTO zipcode VALUES ('411001','Pune'),('400001','Mumbai');
INSERT INTO customer VALUES
(1,'Amit','MG Road','411001','9000000001'),
(2,'Riya','FC Road','411001','9000000002'),
(3,'Karan','Marine Dr','400001','9000000003'),
(4,'Neha','Park St','400001','9000000004'),
(5,'Rohan','Lake Rd','411001','9000000005');
INSERT INTO parts VALUES (10,'Bolt',100,5),(20,'Nut',20,2),(30,'Screw',50,3),(40,'Washer',10,1);
INSERT INTO orders VALUES (1001,1,'2026-10-01','2026-10-03'),(1002,2,'2026-10-02','2026-10-04'),(1003,3,'2026-10-05',NULL);
INSERT INTO odetails VALUES (1001,10,50),(1001,20,30),(1002,30,10),(9999,40,5);

-- Q1
SELECT o.ono, c.cname, p.pname, od.qty
FROM orders o
INNER JOIN customer c ON o.cno = c.cno
INNER JOIN odetails od ON o.ono = od.ono
INNER JOIN parts p ON p.pno = od.pno
WHERE od.qty > p.qty_on_hand;

-- Q2
SELECT c.cname, o.ono, o.receivedate
FROM customer c
LEFT JOIN orders o ON c.cno = o.cno;

-- Q3
SELECT p.pname, o.ono, o.receivedate
FROM parts p
LEFT JOIN odetails od ON p.pno = od.pno
LEFT JOIN orders o ON o.ono = od.ono;

-- Q4
SELECT o.ono, od.pno, od.qty
FROM orders o LEFT JOIN odetails od ON o.ono = od.ono
UNION
SELECT od.ono, od.pno, od.qty
FROM orders o RIGHT JOIN odetails od ON o.ono = od.ono;

-- Q5
SELECT c1.cname AS customer1, c2.cname AS customer2, z.city
FROM customer c1
INNER JOIN customer c2 ON c1.Zip = c2.Zip AND c1.cno < c2.cno
INNER JOIN zipcode z ON z.Zip = c1.Zip;

-- ##################  BATCH B - SET 1 (Projects)  ##################
DROP DATABASE IF EXISTS lab5_b1; CREATE DATABASE lab5_b1; USE lab5_b1;

CREATE TABLE Project (project_id VARCHAR(10) PRIMARY KEY, proj_name VARCHAR(50), chief_arch INT);
CREATE TABLE Employee (Emp_id INT PRIMARY KEY, Emp_name VARCHAR(50));
CREATE TABLE Assigned_To (Project_id VARCHAR(10), Emp_id INT);

INSERT INTO Employee VALUES (1,'Amit'),(2,'Riya'),(3,'Karan'),(4,'Neha');
INSERT INTO Project VALUES ('C353','Bridge Design',1),('C400','Mall Design',2),('C500','Airport',3);
INSERT INTO Assigned_To VALUES ('C353',1),('C353',2),('C400',2),('C400',3);

-- Q1
SELECT e.Emp_name, p.proj_name
FROM Employee e
INNER JOIN Assigned_To a ON e.Emp_id = a.Emp_id
INNER JOIN Project p ON p.project_id = a.Project_id;

-- Q1b
SELECT Emp_id FROM Assigned_To WHERE Project_id = 'C353';

-- Q2
SELECT e.Emp_name, p.proj_name
FROM Employee e
LEFT JOIN Assigned_To a ON e.Emp_id = a.Emp_id
LEFT JOIN Project p ON p.project_id = a.Project_id;

-- Q3
SELECT p.proj_name, e.Emp_name
FROM Project p
LEFT JOIN Assigned_To a ON p.project_id = a.Project_id
LEFT JOIN Employee e ON e.Emp_id = a.Emp_id;

-- Q4
SELECT p.proj_name, e.Emp_name
FROM Project p
LEFT JOIN Assigned_To a ON p.project_id = a.Project_id
LEFT JOIN Employee e ON e.Emp_id = a.Emp_id
UNION
SELECT p.proj_name, e.Emp_name
FROM Employee e
LEFT JOIN Assigned_To a ON e.Emp_id = a.Emp_id
LEFT JOIN Project p ON p.project_id = a.Project_id;

-- Q5
SELECT e.Emp_name, p.proj_name,
       CASE WHEN p.chief_arch = e.Emp_id THEN 'Yes' ELSE 'No' END AS is_chief_architect
FROM Employee e
LEFT JOIN Assigned_To a ON e.Emp_id = a.Emp_id
LEFT JOIN Project p ON p.project_id = a.Project_id;

-- ##################  BATCH B - SET 2 (Product shipping)  ##################
DROP DATABASE IF EXISTS product_ship; CREATE DATABASE product_ship; USE product_ship;

CREATE TABLE CUSTOMER (
    CUST_ID INT PRIMARY KEY,
    CUST_NAME VARCHAR(50),
    ANNUAL_REVENUE DECIMAL(14,2),
    CUST_TYPE ENUM('manufacturer','wholesaler','retailer')
);
CREATE TABLE TRUCK (TRUCK_NO INT PRIMARY KEY, DRIVER_NAME VARCHAR(50));
CREATE TABLE CITY (CITY_NAME VARCHAR(50) PRIMARY KEY, POPULATION INT);
CREATE TABLE SHIPMENT (
    SHIPMENT_NO INT PRIMARY KEY,
    CUST_ID INT,
    WEIGHT DECIMAL(10,2),
    TRUCK_NO INT,
    DESTINATION VARCHAR(50),
    SHIP_DATE DATE,
    CITY_NAME VARCHAR(50),
    FOREIGN KEY (CUST_ID) REFERENCES CUSTOMER(CUST_ID),
    FOREIGN KEY (TRUCK_NO) REFERENCES TRUCK(TRUCK_NO),
    FOREIGN KEY (CITY_NAME) REFERENCES CITY(CITY_NAME)
);

INSERT INTO CUSTOMER VALUES
(311,'Alpha Mfg',15000000,'manufacturer'),
(312,'Beta Wholesale',5000000,'wholesaler'),
(313,'Gamma Retail',2000000,'retailer');
INSERT INTO TRUCK VALUES (1,'Jensen'),(2,'Jake Stinson'),(3,'Maria Lopez');
INSERT INTO CITY VALUES
('Denver',700000),('St. Louis',300000),('Smallville',8000),('Bigcity',2000000),('Emptyville',5000);
INSERT INTO SHIPMENT VALUES
(1,311,100,1,'Bigcity','2026-10-01','Bigcity'),
(2,311,1500,1,'St. Louis','2026-10-02','St. Louis'),
(3,312,150,2,'St. Louis','2026-10-03','St. Louis'),
(4,311,0.5,1,'Smallville','2026-10-04','Smallville'),
(5,313,20,1,'Unknown',  '2026-10-05',NULL),
(6,312,200,1,'Denver','2026-10-06','Denver'),
(7,313,10,2,'St. Louis','2026-10-07','St. Louis');

-- Q1
SELECT DISTINCT t.DRIVER_NAME
FROM TRUCK t INNER JOIN SHIPMENT s ON t.TRUCK_NO = s.TRUCK_NO
WHERE s.WEIGHT > 100;

-- Q2
SELECT s.SHIPMENT_NO, c.CUST_NAME, t.DRIVER_NAME, ci.CITY_NAME
FROM SHIPMENT s
INNER JOIN CUSTOMER c ON c.CUST_ID = s.CUST_ID
INNER JOIN TRUCK t ON t.TRUCK_NO = s.TRUCK_NO
INNER JOIN CITY ci ON ci.CITY_NAME = s.CITY_NAME
WHERE s.WEIGHT > 1000;

-- Q3
SELECT t.TRUCK_NO, t.DRIVER_NAME, s.SHIPMENT_NO, c.CUST_NAME, ci.CITY_NAME
FROM TRUCK t
LEFT JOIN SHIPMENT s ON t.TRUCK_NO = s.TRUCK_NO
LEFT JOIN CUSTOMER c ON c.CUST_ID = s.CUST_ID
LEFT JOIN CITY ci ON ci.CITY_NAME = s.CITY_NAME;

-- Q5
SELECT s.SHIPMENT_NO, s.WEIGHT, ci.CITY_NAME, ci.POPULATION
FROM SHIPMENT s LEFT JOIN CITY ci ON s.CITY_NAME = ci.CITY_NAME
UNION
SELECT s.SHIPMENT_NO, s.WEIGHT, ci.CITY_NAME, ci.POPULATION
FROM SHIPMENT s RIGHT JOIN CITY ci ON s.CITY_NAME = ci.CITY_NAME;

-- A1
SELECT DISTINCT c.CUST_NAME, c.ANNUAL_REVENUE
FROM CUSTOMER c
INNER JOIN SHIPMENT s ON c.CUST_ID = s.CUST_ID
INNER JOIN TRUCK t ON t.TRUCK_NO = s.TRUCK_NO
WHERE t.DRIVER_NAME = 'Jensen';

-- A2
SELECT DISTINCT c.CUST_NAME, c.ANNUAL_REVENUE
FROM CUSTOMER c INNER JOIN SHIPMENT s ON c.CUST_ID = s.CUST_ID
WHERE s.WEIGHT > 100;

-- A3
SELECT c.CUST_NAME FROM CUSTOMER c
WHERE NOT EXISTS (
    SELECT * FROM TRUCK t
    WHERE NOT EXISTS (
        SELECT * FROM SHIPMENT s
        WHERE s.CUST_ID = c.CUST_ID AND s.TRUCK_NO = t.TRUCK_NO));

-- A4
SELECT ci.CITY_NAME FROM CITY ci
WHERE NOT EXISTS (
    SELECT * FROM CUSTOMER c
    WHERE NOT EXISTS (
        SELECT * FROM SHIPMENT s
        WHERE s.CITY_NAME = ci.CITY_NAME AND s.CUST_ID = c.CUST_ID));

-- A5
SELECT t.DRIVER_NAME FROM TRUCK t
WHERE NOT EXISTS (
    SELECT * FROM CITY ci
    WHERE NOT EXISTS (
        SELECT * FROM SHIPMENT s
        WHERE s.TRUCK_NO = t.TRUCK_NO AND s.CITY_NAME = ci.CITY_NAME));

-- A6
SELECT DISTINCT c.CUST_NAME
FROM CUSTOMER c LEFT JOIN SHIPMENT s ON c.CUST_ID = s.CUST_ID
WHERE c.CUST_TYPE = 'manufacturer' OR s.CITY_NAME = 'St. Louis';

-- A7
SELECT DISTINCT ci.CITY_NAME
FROM CITY ci INNER JOIN SHIPMENT s ON ci.CITY_NAME = s.CITY_NAME
WHERE ci.POPULATION > 1000000 AND s.WEIGHT = 100 AND s.CUST_ID = 311;

-- A8
SELECT t.TRUCK_NO, t.DRIVER_NAME FROM TRUCK t
WHERE t.DRIVER_NAME = 'Jake Stinson'
  AND NOT EXISTS (
      SELECT * FROM SHIPMENT s
      WHERE s.TRUCK_NO = t.TRUCK_NO AND s.CITY_NAME = 'Denver');

-- A9
SELECT DISTINCT c.CUST_NAME
FROM CUSTOMER c
INNER JOIN SHIPMENT s ON c.CUST_ID = s.CUST_ID
INNER JOIN CITY ci ON ci.CITY_NAME = s.CITY_NAME
WHERE c.ANNUAL_REVENUE > 10000000 AND s.WEIGHT < 1 AND ci.POPULATION < 10000;

-- ##################  BATCH C (Hotel booking)  ##################
DROP DATABASE IF EXISTS lab5_hotel; CREATE DATABASE lab5_hotel; USE lab5_hotel;

CREATE TABLE Hotel (HotelNo INT PRIMARY KEY, Name VARCHAR(50), City VARCHAR(30));
CREATE TABLE Room  (RoomNo INT, HotelNo INT, Type VARCHAR(20), Price DECIMAL(8,2),
                    PRIMARY KEY (HotelNo, RoomNo));
CREATE TABLE Guest (GuestNo INT PRIMARY KEY, GuestName VARCHAR(50), GuestAddress VARCHAR(100));
CREATE TABLE Booking (HotelNo INT, GuestNo INT, DateFrom DATE, DateTo DATE, RoomNo INT);

INSERT INTO Hotel VALUES (1,'Grand Palace','Pune'),(2,'Sea View','Mumbai'),(3,'Hill Top','Pune');
INSERT INTO Room VALUES
(101,1,'Single',2000),(102,1,'Double',3500),(103,1,'Suite',6000),
(201,2,'Single',2500),(202,2,'Double',4000),
(301,3,'Single',1800);
INSERT INTO Guest VALUES (1,'Amit','Pune'),(2,'Riya','Delhi'),(3,'Karan','Mumbai');
INSERT INTO Booking VALUES
(1,1,'2026-10-01','2026-10-03',101),
(1,2,'2026-10-05','2026-10-08',102),
(2,2,'2026-11-01','2026-11-04',201);

-- ---- SET 1 ----
-- Q1. All rooms with their hotel names
SELECT r.RoomNo, r.Type, r.Price, h.Name AS hotel_name
FROM Room r
INNER JOIN Hotel h ON r.HotelNo = h.HotelNo;

-- Q2. All guests and their bookings (guests without bookings also)
SELECT g.GuestName, b.HotelNo, b.RoomNo, b.DateFrom, b.DateTo
FROM Guest g
LEFT JOIN Booking b ON g.GuestNo = b.GuestNo;

-- Q3. All rooms with booking details (rooms never booked also)
SELECT r.HotelNo, r.RoomNo, r.Type, b.GuestNo, b.DateFrom, b.DateTo
FROM Room r
LEFT JOIN Booking b ON r.HotelNo = b.HotelNo AND r.RoomNo = b.RoomNo;

-- Q4. All bookings with guest name, hotel name and room number
SELECT g.GuestName, h.Name AS hotel_name, b.RoomNo, b.DateFrom, b.DateTo
FROM Booking b
INNER JOIN Guest g ON b.GuestNo = g.GuestNo
INNER JOIN Hotel h ON b.HotelNo = h.HotelNo;

-- Q5. Bookings for hotels in Pune
SELECT b.*, h.Name AS hotel_name
FROM Booking b
INNER JOIN Hotel h ON b.HotelNo = h.HotelNo
WHERE h.City = 'Pune';

-- ---- SET 2 ----
-- Q1. Bookings in a specific city (Pune)
SELECT g.GuestName, h.Name AS hotel_name, b.RoomNo, b.DateFrom, b.DateTo
FROM Booking b
INNER JOIN Hotel h ON b.HotelNo = h.HotelNo
INNER JOIN Guest g ON b.GuestNo = g.GuestNo
WHERE h.City = 'Pune';

-- Q2. Number of rooms in each hotel
SELECT h.Name, COUNT(r.RoomNo) AS total_rooms
FROM Hotel h
LEFT JOIN Room r ON h.HotelNo = r.HotelNo
GROUP BY h.HotelNo, h.Name;

-- Q3. Average room price of each hotel
SELECT h.Name, AVG(r.Price) AS avg_price
FROM Hotel h
LEFT JOIN Room r ON h.HotelNo = r.HotelNo
GROUP BY h.HotelNo, h.Name;

-- Q4. Guests who never booked
SELECT g.GuestName
FROM Guest g
LEFT JOIN Booking b ON g.GuestNo = b.GuestNo
WHERE b.GuestNo IS NULL;

-- Q5. Rooms that were never booked
SELECT r.HotelNo, r.RoomNo, r.Type
FROM Room r
LEFT JOIN Booking b ON r.HotelNo = b.HotelNo AND r.RoomNo = b.RoomNo
WHERE b.GuestNo IS NULL;
