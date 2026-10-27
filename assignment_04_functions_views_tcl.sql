-- =====================================================================
-- ASSIGNMENT 4 : Functions, GROUP BY, Subqueries, Set ops, Views, TCL
-- Run:  mysql -u root -p < assignment_04_functions_views_tcl.sql
-- Each batch has its own database and 6 questions.
-- =====================================================================


-- #####################################################################
-- BATCH 1 : GLOBAL GROCERIES
-- #####################################################################
DROP DATABASE IF EXISTS a4_groceries;
CREATE DATABASE a4_groceries;
USE a4_groceries;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(30),
    last_name   VARCHAR(30),
    email       VARCHAR(80),
    join_date   DATE
);
CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE,
    total_amount DECIMAL(12,2)
);
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(50),
    category     VARCHAR(30),
    price        DECIMAL(10,2)
);
CREATE TABLE order_items (
    item_id    INT PRIMARY KEY,
    order_id   INT,
    product_id INT,
    quantity   INT
);
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(30),
    last_name   VARCHAR(30),
    hire_date   DATE,
    department  VARCHAR(30),
    order_id    INT            -- the order this employee processed
);

-- ---- sample data ----
INSERT INTO customers VALUES
(101,'john','smith','john.smith@mail.com','2024-03-15'),
(102,'MARY','JONES','mary.jones@gmail.com','2024-07-01'),
(103,'raj','patel','raj.patel@yahoo.com','2023-05-20'),
(104,'anita','rao','anita.rao@mail.com','2022-01-10');

INSERT INTO orders VALUES
(1,101,'2024-04-01',1000),(2,101,'2024-04-02',1000),(3,101,'2024-04-03',1000),
(4,101,'2024-04-04',1000),(5,101,'2024-04-05',1000),(6,101,'2024-04-06',1000),
(7,101,'2024-04-07',1000),(8,101,'2024-04-08',1000),(9,101,'2024-04-09',1000),
(10,101,'2024-04-10',1000),
(11,102,'2024-08-01',90000),
(12,103,'2024-02-01',3000),
(13,104,'2024-03-01',500);

INSERT INTO products VALUES
(1,'Laptop','Electronics',60000),(2,'Phone','Electronics',30000),
(3,'Rice','Grocery',80),(4,'Milk','Dairy',25);

INSERT INTO order_items VALUES
(1,11,1,20),(2,11,2,10),(3,1,3,10),(4,12,4,5),(5,13,3,2);

INSERT INTO employees VALUES
(1,'Asha','Kale','2015-01-01','Sales',11),
(2,'Ravi','More','2023-06-01','Sales',12),
(3,'Neel','Shah','2018-04-04','Support',1),
(4,'Sam','Roy','2020-09-09','Sales',13);

-- ---- Q1 : customers who joined in 2024 ----
SELECT CONCAT(UPPER(LEFT(first_name,1)), LOWER(SUBSTRING(first_name,2)), ' ',
              UPPER(LEFT(last_name,1)),  LOWER(SUBSTRING(last_name,2)))   AS full_name,
       TIMESTAMPDIFF(MONTH, join_date, CURDATE())                         AS membership_months,
       CONCAT(LEFT(email,3), '...@', SUBSTRING_INDEX(email,'@',-1))       AS masked_email
FROM customers
WHERE YEAR(join_date) = 2024
ORDER BY join_date ASC;

-- ---- Q2 : category-wise revenue (only revenue > 1,000,000) ----
SELECT p.category,
       SUM(oi.quantity * p.price)  AS total_revenue,
       AVG(oi.quantity)            AS avg_quantity_per_order,
       COUNT(DISTINCT oi.order_id) AS unique_orders
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category
HAVING SUM(oi.quantity * p.price) > 1000000;

-- ---- Q3 : employees who processed orders of high-spending customers ----
SELECT DISTINCT CONCAT(e.first_name,' ',e.last_name) AS full_name, e.hire_date
FROM employees e
JOIN orders o ON o.order_id = e.order_id
WHERE o.customer_id IN (
        SELECT customer_id
        FROM orders
        GROUP BY customer_id
        HAVING SUM(total_amount) > (SELECT AVG(t.spent)
                                    FROM (SELECT SUM(total_amount) AS spent
                                          FROM orders
                                          GROUP BY customer_id) t)
);

-- ---- Q4 : unique names = employees (> 5 years) UNION customers (>= 10 orders) ----
SELECT first_name, last_name
FROM employees
WHERE TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) > 5
UNION
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders
                      GROUP BY customer_id HAVING COUNT(*) >= 10);

-- ---- Q5 : view of top 10 customers by lifetime spending ----
CREATE OR REPLACE VIEW v_top_customer_revenue AS
SELECT CONCAT(c.first_name,' ',c.last_name) AS full_name,
       c.email,
       SUM(o.total_amount)                  AS lifetime_spending
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY lifetime_spending DESC
LIMIT 10;

SELECT * FROM v_top_customer_revenue;

-- ---- Q6 : transaction with SAVEPOINT ----
START TRANSACTION;
UPDATE orders SET customer_id = 201 WHERE customer_id = 101;
SAVEPOINT after_first_update;
UPDATE orders SET customer_id = 201 WHERE customer_id = 103;   -- mistake
ROLLBACK TO SAVEPOINT after_first_update;                      -- undo only the mistake
UPDATE orders SET customer_id = 203 WHERE customer_id = 103;   -- correct update
UPDATE orders SET customer_id = 202 WHERE customer_id = 102;
COMMIT;

SELECT DISTINCT customer_id FROM orders ORDER BY customer_id;


-- #####################################################################
-- BATCH 2 : LIBRARY
-- #####################################################################
DROP DATABASE IF EXISTS a4_library;
CREATE DATABASE a4_library;
USE a4_library;

CREATE TABLE members (
    member_id  INT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name  VARCHAR(30),
    email      VARCHAR(80),
    join_date  DATE
);
CREATE TABLE books (
    book_id      INT PRIMARY KEY,
    title        VARCHAR(80),
    author       VARCHAR(50),
    genre        VARCHAR(30),
    publish_year INT
);
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(30),
    last_name   VARCHAR(30),
    hire_date   DATE,
    position    VARCHAR(30)
);
CREATE TABLE borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id    INT,
    book_id      INT,
    borrow_date  DATE,
    return_date  DATE,
    employee_id  INT           -- ASSUMPTION: the slide has no link to employees, so we add one
);

-- ---- sample data ----
INSERT INTO members VALUES
(555,'amit','shah',  'amit.shah@mail.com',  DATE_SUB(CURDATE(), INTERVAL 1 YEAR)),
(556,'RIYA','DESAI', 'riya.desai@mail.com', DATE_SUB(CURDATE(), INTERVAL 400 DAY)),
(557,'karan','mehta','karan.m@mail.com',    '2020-01-15'),
(558,'neha','joshi', 'neha.j@mail.com',     '2019-06-01');

INSERT INTO books VALUES
(1,'Wings of Fire','APJ Kalam','Biography',1999),
(2,'Harry Potter','JK Rowling','Fantasy',1997),
(3,'Python Basics','Guido','Technology',2015);

INSERT INTO employees VALUES
(1,'Meera','Iyer','2010-05-01','Librarian'),
(2,'Rohan','Das','2022-01-01','Assistant'),
(3,'Sana','Khan','2012-03-03','Clerk');

-- a few real rows ...
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id) VALUES
(555,2,'2025-02-01','2025-02-10',1),
(555,3,'2025-03-01','2025-03-08',1),
(556,2,'2025-04-01',NULL,2),
(557,2,'2025-05-01','2025-05-09',3),
(557,1,'2025-06-01','2025-06-12',3);
-- ... and many Fantasy rows, so the "more than 500 books" condition has data
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;
INSERT INTO borrowings (member_id, book_id, borrow_date, return_date, employee_id)
SELECT member_id, 2, borrow_date, return_date, employee_id FROM borrowings;

-- ---- Q1 : members who joined last year ----
SELECT CONCAT(UPPER(first_name), ' ', last_name) AS full_name,
       LENGTH(email)                             AS email_length,
       DATEDIFF(CURDATE(), join_date)            AS days_as_member
FROM members
WHERE YEAR(join_date) = YEAR(CURDATE()) - 1
ORDER BY join_date DESC;

-- ---- Q2 : genre-wise borrowing report (only genres with > 500 borrowings) ----
SELECT bk.genre,
       COUNT(*)                                       AS total_books_borrowed,
       AVG(DATEDIFF(br.return_date, br.borrow_date))  AS avg_borrow_days,
       COUNT(DISTINCT br.member_id)                   AS unique_members
FROM borrowings br
JOIN books bk ON bk.book_id = br.book_id
GROUP BY bk.genre
HAVING COUNT(*) > 500;

-- ---- Q3 : employees who processed books borrowed by "heavy" members ----
-- heavy member = borrowed more books than the average per member
SELECT DISTINCT CONCAT(e.first_name,' ',e.last_name) AS full_name, e.position
FROM employees e
JOIN borrowings br ON br.employee_id = e.employee_id
WHERE br.member_id IN (
        SELECT member_id
        FROM borrowings
        GROUP BY member_id
        HAVING COUNT(*) > (SELECT AVG(t.cnt)
                           FROM (SELECT COUNT(*) AS cnt
                                 FROM borrowings
                                 GROUP BY member_id) t)
);

-- ---- Q4 : names of members with overdue books UNION employees > 10 years ----
-- overdue = not returned and borrowed more than 14 days ago
SELECT first_name, last_name
FROM members
WHERE member_id IN (SELECT member_id FROM borrowings
                    WHERE return_date IS NULL
                      AND borrow_date < DATE_SUB(CURDATE(), INTERVAL 14 DAY))
UNION
SELECT first_name, last_name
FROM employees
WHERE TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) > 10;

-- ---- Q5 : view of top 15 borrowers ----
CREATE OR REPLACE VIEW v_top_borrowers AS
SELECT CONCAT(m.first_name,' ',m.last_name) AS full_name,
       m.email,
       COUNT(br.borrowing_id)               AS total_borrowed
FROM members m
JOIN borrowings br ON br.member_id = m.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.email
ORDER BY total_borrowed DESC
LIMIT 15;

SELECT * FROM v_top_borrowers;

-- ---- Q6 : transaction with SAVEPOINT ----
START TRANSACTION;
UPDATE borrowings SET member_id = 901 WHERE member_id = 555;
SAVEPOINT after_first_member_update;
UPDATE borrowings SET member_id = 901 WHERE member_id = 557;   -- mistake
ROLLBACK TO SAVEPOINT after_first_member_update;               -- undo only the mistake
UPDATE borrowings SET member_id = 903 WHERE member_id = 557;   -- correct update
UPDATE borrowings SET member_id = 902 WHERE member_id = 556;
COMMIT;

SELECT DISTINCT member_id FROM borrowings ORDER BY member_id;


-- #####################################################################
-- BATCH 3 : VOYAGE VENTURES (TRAVEL)
-- #####################################################################
DROP DATABASE IF EXISTS a4_voyage;
CREATE DATABASE a4_voyage;
USE a4_voyage;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(30),
    last_name   VARCHAR(30),
    email       VARCHAR(80),
    city        VARCHAR(30)
);
CREATE TABLE packages (
    package_id    INT PRIMARY KEY,
    package_name  VARCHAR(50),
    destination   VARCHAR(50),
    duration_days INT
);
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name  VARCHAR(30),
    last_name   VARCHAR(30),
    hire_date   DATE,
    department  VARCHAR(30)
);
CREATE TABLE bookings (
    booking_id   INT PRIMARY KEY,
    customer_id  INT,
    package_id   INT,
    booking_date DATE,
    total_price  DECIMAL(12,2),
    employee_id  INT           -- ASSUMPTION: the slide has no link to employees, so we add one
);

-- ---- sample data ----
INSERT INTO customers VALUES
(1,'Amit','Shah','amit@mail.com','Pune'),
(2,'Riya','Desai','riya@mail.com','Mumbai'),
(3,'Karan','Mehta','karan@mail.com','Delhi');

INSERT INTO packages VALUES
(1,'Goa Beach Fun','Goa',5),
(2,'Himalaya Trek','Manali',12),
(3,'Kerala Backwaters','Kerala',8);

INSERT INTO employees VALUES
(1,'Meera','Iyer','2015-05-01','Sales'),
(2,'Rohan','Das',DATE_SUB(CURDATE(), INTERVAL 1 YEAR),'Support'),
(3,'Sana','Khan','2018-03-03','Sales');

INSERT INTO bookings VALUES
(701,1,1,DATE_SUB(CURDATE(), INTERVAL 20 DAY), 30000,1),
(702,2,2,DATE_SUB(CURDATE(), INTERVAL 60 DAY), 45000,2),
(703,3,3,DATE_SUB(CURDATE(), INTERVAL 100 DAY),20000,3),
(704,2,3,DATE_SUB(CURDATE(), INTERVAL 300 DAY),25000,3),
(705,1,2,DATE_SUB(CURDATE(), INTERVAL 400 DAY), 5000,1);

-- ---- Q1 : bookings from the last 6 months ----
SELECT LOWER(CONCAT(c.first_name,' ',c.last_name))              AS customer_name,
       CONCAT('Destination: ', p.destination)                   AS destination,
       b.booking_date,
       DATE_ADD(b.booking_date, INTERVAL p.duration_days DAY)   AS estimated_return_date
FROM bookings b
JOIN customers c ON c.customer_id = b.customer_id
JOIN packages  p ON p.package_id  = b.package_id
WHERE b.booking_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY b.booking_date DESC;

-- ---- Q2 : destination-wise revenue (only revenue > 50,000) ----
SELECT p.destination,
       SUM(b.total_price) AS total_revenue,
       AVG(b.total_price) AS avg_booking_price,
       COUNT(*)           AS number_of_bookings
FROM bookings b
JOIN packages p ON p.package_id = b.package_id
GROUP BY p.destination
HAVING SUM(b.total_price) > 50000;

-- ---- Q3 : employees who handled bookings of valuable customers ----
-- valuable customer = total spend greater than the average total spend
SELECT DISTINCT CONCAT(e.first_name,' ',e.last_name) AS full_name, e.department
FROM employees e
JOIN bookings b ON b.employee_id = e.employee_id
WHERE b.customer_id IN (
        SELECT customer_id
        FROM bookings
        GROUP BY customer_id
        HAVING SUM(total_price) > (SELECT AVG(t.spent)
                                   FROM (SELECT SUM(total_price) AS spent
                                         FROM bookings
                                         GROUP BY customer_id) t)
);

-- ---- Q4 : customers who booked packages > 10 days UNION employees hired in last 2 years ----
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT b.customer_id
                      FROM bookings b
                      JOIN packages p ON p.package_id = b.package_id
                      WHERE p.duration_days > 10)
UNION
SELECT first_name, last_name
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR);

-- ---- Q5 : view of customer bookings summary ----
CREATE OR REPLACE VIEW v_customer_bookings_summary AS
SELECT CONCAT(c.first_name,' ',c.last_name) AS full_name,
       p.package_name,
       b.booking_date,
       b.total_price
FROM bookings b
JOIN customers c ON c.customer_id = b.customer_id
JOIN packages  p ON p.package_id  = b.package_id;

SELECT * FROM v_customer_bookings_summary;

-- ---- Q6 : transaction with SAVEPOINT ----
START TRANSACTION;
UPDATE bookings SET total_price = 1500 WHERE booking_id = 701;
SAVEPOINT after_first_price_update;
UPDATE bookings SET total_price = 1500 WHERE booking_id = 703;   -- mistake
ROLLBACK TO SAVEPOINT after_first_price_update;                  -- undo only the mistake
UPDATE bookings SET total_price = 2500 WHERE booking_id = 703;   -- correct update
UPDATE bookings SET total_price = 2000 WHERE booking_id = 702;
COMMIT;

SELECT booking_id, total_price FROM bookings ORDER BY booking_id;
