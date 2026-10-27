-- =====================================================================
-- ASSIGNMENT 7 : Cursors (MySQL)
-- Run:  mysql -u root -p < assignment_07_cursors.sql
-- Cursor recipe:  DECLARE variables -> DECLARE cursor -> DECLARE handler
--                 -> OPEN -> LOOP (FETCH, check done) -> CLOSE
-- =====================================================================


-- #####################################################################
-- BATCH 1 : Performance bonus
-- Rating 5 = 20%,  4 = 15%,  3 = 10%,  2 = 5%,  1 = 0%   (assumed)
-- #####################################################################
DROP DATABASE IF EXISTS a7_batch1;
CREATE DATABASE a7_batch1;
USE a7_batch1;

CREATE TABLE Employees (
    emp_id             INT PRIMARY KEY,
    emp_name           VARCHAR(50),
    department         VARCHAR(50),
    salary             DECIMAL(10,2),
    performance_rating INT              -- scale 1 to 5
);

CREATE TABLE Bonus_Payout (
    payout_id    INT AUTO_INCREMENT PRIMARY KEY,
    emp_id       INT,
    emp_name     VARCHAR(50),
    base_salary  DECIMAL(10,2),
    bonus_amount DECIMAL(10,2),
    final_salary DECIMAL(10,2),
    payout_date  DATE
);

INSERT INTO Employees VALUES
(1,'Amit', 'IT',   50000,5),
(2,'Riya', 'HR',   40000,4),
(3,'Karan','IT',   60000,3),
(4,'Neha', 'Sales',30000,2),
(5,'Sam',  'Sales',25000,1);

DELIMITER $$
CREATE PROCEDURE CalculateBonus()
BEGIN
    DECLARE v_emp_id  INT;
    DECLARE v_name    VARCHAR(50);
    DECLARE v_salary  DECIMAL(10,2);
    DECLARE v_rating  INT;
    DECLARE v_bonus   DECIMAL(10,2);
    DECLARE v_done    INT DEFAULT 0;

    DECLARE emp_cursor CURSOR FOR
        SELECT emp_id, emp_name, salary, performance_rating FROM Employees;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN emp_cursor;

    read_loop: LOOP
        FETCH emp_cursor INTO v_emp_id, v_name, v_salary, v_rating;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        CASE v_rating
            WHEN 5 THEN SET v_bonus = v_salary * 0.20;
            WHEN 4 THEN SET v_bonus = v_salary * 0.15;
            WHEN 3 THEN SET v_bonus = v_salary * 0.10;
            WHEN 2 THEN SET v_bonus = v_salary * 0.05;
            ELSE        SET v_bonus = 0;
        END CASE;

        INSERT INTO Bonus_Payout (emp_id, emp_name, base_salary, bonus_amount, final_salary, payout_date)
        VALUES (v_emp_id, v_name, v_salary, v_bonus, v_salary + v_bonus, CURDATE());
    END LOOP;

    CLOSE emp_cursor;
END$$
DELIMITER ;

CALL CalculateBonus();
SELECT * FROM Bonus_Payout;


-- #####################################################################
-- BATCH 2 : Customer account status
-- balance < 0       -> 'Suspended'  (+ warning in Audit_Log)
-- balance < 1000    -> 'Standard'   (+ warning in Audit_Log)
-- balance < 50000   -> 'Silver'
-- otherwise         -> 'Gold'                                (assumed)
-- #####################################################################
DROP DATABASE IF EXISTS a7_batch2;
CREATE DATABASE a7_batch2;
USE a7_batch2;

CREATE TABLE Customers (
    customer_id     INT PRIMARY KEY,
    customer_name   VARCHAR(50),
    account_balance DECIMAL(12,2),
    membership_tier VARCHAR(20) DEFAULT 'Standard'
);

CREATE TABLE Audit_Log (
    log_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT,
    action_taken  VARCHAR(100),
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Customers (customer_id, customer_name, account_balance) VALUES
(1,'Amit',  -500),
(2,'Riya',   300),
(3,'Karan', 20000),
(4,'Neha', 120000);

DELIMITER $$
CREATE PROCEDURE CheckCustomerStatus()
BEGIN
    DECLARE v_id      INT;
    DECLARE v_balance DECIMAL(12,2);
    DECLARE v_done    INT DEFAULT 0;

    DECLARE cust_cursor CURSOR FOR
        SELECT customer_id, account_balance FROM Customers;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    OPEN cust_cursor;

    read_loop: LOOP
        FETCH cust_cursor INTO v_id, v_balance;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        IF v_balance < 0 THEN
            UPDATE Customers SET membership_tier = 'Suspended' WHERE customer_id = v_id;
            INSERT INTO Audit_Log (customer_id, action_taken)
            VALUES (v_id, 'WARNING: Negative balance - account Suspended');

        ELSEIF v_balance < 1000 THEN
            UPDATE Customers SET membership_tier = 'Standard' WHERE customer_id = v_id;
            INSERT INTO Audit_Log (customer_id, action_taken)
            VALUES (v_id, 'WARNING: Low balance - tier set to Standard');

        ELSEIF v_balance < 50000 THEN
            UPDATE Customers SET membership_tier = 'Silver' WHERE customer_id = v_id;

        ELSE
            UPDATE Customers SET membership_tier = 'Gold' WHERE customer_id = v_id;
        END IF;
    END LOOP;

    CLOSE cust_cursor;
END$$
DELIMITER ;

CALL CheckCustomerStatus();
SELECT * FROM Customers;
SELECT * FROM Audit_Log;


-- #####################################################################
-- BATCH 3 : Inventory reorder list
-- If current_stock < reorder_level:
--     order_quantity = (reorder_level * 2) - current_stock      (assumed)
--     total_cost     = order_quantity * unit_price
-- OUT parameter returns the cumulative cost of all reorders.
-- #####################################################################
DROP DATABASE IF EXISTS a7_batch3;
CREATE DATABASE a7_batch3;
USE a7_batch3;

CREATE TABLE Inventory (
    product_id    INT PRIMARY KEY,
    product_name  VARCHAR(50),
    current_stock INT,
    reorder_level INT,
    unit_price    DECIMAL(10,2)
);

CREATE TABLE Purchase_Orders (
    order_id       INT AUTO_INCREMENT PRIMARY KEY,
    product_id     INT,
    order_quantity INT,
    total_cost     DECIMAL(10,2),
    status         VARCHAR(20) DEFAULT 'Pending'
);

INSERT INTO Inventory VALUES
(1,'Keyboard', 5, 20, 500),
(2,'Mouse',   50, 20, 300),
(3,'Monitor',  2, 10, 8000),
(4,'Cable',   30, 30, 100);

DELIMITER $$
CREATE PROCEDURE GenerateReorderList(OUT p_total_cost DECIMAL(12,2))
BEGIN
    DECLARE v_product_id INT;
    DECLARE v_stock      INT;
    DECLARE v_level      INT;
    DECLARE v_price      DECIMAL(10,2);
    DECLARE v_qty        INT;
    DECLARE v_cost       DECIMAL(10,2);
    DECLARE v_done       INT DEFAULT 0;

    DECLARE inv_cursor CURSOR FOR
        SELECT product_id, current_stock, reorder_level, unit_price FROM Inventory;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    SET p_total_cost = 0;

    OPEN inv_cursor;

    read_loop: LOOP
        FETCH inv_cursor INTO v_product_id, v_stock, v_level, v_price;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        IF v_stock < v_level THEN
            SET v_qty  = (v_level * 2) - v_stock;
            SET v_cost = v_qty * v_price;

            INSERT INTO Purchase_Orders (product_id, order_quantity, total_cost)
            VALUES (v_product_id, v_qty, v_cost);

            SET p_total_cost = p_total_cost + v_cost;
        END IF;
    END LOOP;

    CLOSE inv_cursor;
END$$
DELIMITER ;

CALL GenerateReorderList(@total);
SELECT * FROM Purchase_Orders;
SELECT @total AS cumulative_cost;
