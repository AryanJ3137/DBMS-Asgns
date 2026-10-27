-- =====================================================================
-- ASSIGNMENT 6 : Stored Procedures and Functions (MySQL)
-- Run:  mysql -u root -p < assignment_06_procedures_functions.sql
-- Each batch uses its own database.
-- =====================================================================


-- #####################################################################
-- BATCH A
-- #####################################################################
DROP DATABASE IF EXISTS a6_batch_a;
CREATE DATABASE a6_batch_a;
USE a6_batch_a;

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    name        VARCHAR(50),
    salary      DECIMAL(10,2),
    hire_date   DATE
);

CREATE TABLE EmployeeSalaryLog (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary  DECIMAL(10,2),
    new_salary  DECIMAL(10,2),
    changed_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Employees VALUES
(1,'Amit', 30000,'2024-01-10'),    -- less than 5 years
(2,'Riya', 50000,'2019-06-01'),    -- 5 to 10 years
(3,'Karan',80000,'2010-03-15');    -- 10 or more years

-- ---- Q1 : procedure UpdateEmployeeSalary ----
DELIMITER $$
CREATE PROCEDURE UpdateEmployeeSalary(IN p_employee_id INT, IN p_new_salary DECIMAL(10,2))
BEGIN
    DECLARE v_count      INT;
    DECLARE v_old_salary DECIMAL(10,2);

    SELECT COUNT(*) INTO v_count
    FROM Employees
    WHERE employee_id = p_employee_id;

    IF v_count = 1 THEN
        SELECT salary INTO v_old_salary
        FROM Employees
        WHERE employee_id = p_employee_id;

        UPDATE Employees
        SET salary = p_new_salary
        WHERE employee_id = p_employee_id;

        INSERT INTO EmployeeSalaryLog (employee_id, old_salary, new_salary)
        VALUES (p_employee_id, v_old_salary, p_new_salary);
    END IF;
END$$
DELIMITER ;

CALL UpdateEmployeeSalary(1, 35000);     -- exists  -> updated + logged
CALL UpdateEmployeeSalary(99, 10000);    -- missing -> nothing happens
SELECT * FROM Employees;
SELECT * FROM EmployeeSalaryLog;

-- ---- Q2 : function CalculateAnnualBonus ----
DELIMITER $$
CREATE FUNCTION CalculateAnnualBonus(p_employee_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_years  INT;

    SELECT salary, TIMESTAMPDIFF(YEAR, hire_date, CURDATE())
    INTO v_salary, v_years
    FROM Employees
    WHERE employee_id = p_employee_id;

    IF v_salary IS NULL THEN
        RETURN NULL;                         -- employee does not exist
    ELSEIF v_years < 5 THEN
        RETURN v_salary * 0.10;
    ELSEIF v_years < 10 THEN
        RETURN v_salary * 0.15;
    ELSE
        RETURN v_salary * 0.20;
    END IF;
END$$
DELIMITER ;

SELECT employee_id, name, salary, CalculateAnnualBonus(employee_id) AS annual_bonus
FROM Employees;
SELECT CalculateAnnualBonus(99) AS missing_employee;      -- NULL


-- #####################################################################
-- BATCH B
-- #####################################################################
DROP DATABASE IF EXISTS a6_batch_b;
CREATE DATABASE a6_batch_b;
USE a6_batch_b;

CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    balance    DECIMAL(12,2)
);

CREATE TABLE Orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_status VARCHAR(20),
    total_amount DECIMAL(12,2)
);

INSERT INTO Accounts VALUES (1, 5000), (2, 1000);
INSERT INTO Orders VALUES
(1,101,'Completed',500),
(2,101,'Completed',700),
(3,101,'Cancelled',900),
(4,102,'Pending',300);

-- ---- Q1 : procedure TransferFunds ----
DELIMITER $$
CREATE PROCEDURE TransferFunds(
    IN  p_sender_account_id   INT,
    IN  p_receiver_account_id INT,
    IN  p_transfer_amount     DECIMAL(12,2),
    OUT p_message             VARCHAR(100)
)
main: BEGIN
    DECLARE v_count   INT;
    DECLARE v_balance DECIMAL(12,2);

    -- any SQL error: undo everything and report
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: Transfer failed, changes rolled back';
    END;

    -- 1. both accounts must exist
    SELECT COUNT(*) INTO v_count
    FROM Accounts
    WHERE account_id IN (p_sender_account_id, p_receiver_account_id);

    IF p_sender_account_id = p_receiver_account_id OR v_count < 2 THEN
        SET p_message = 'Error: Account not found';
        LEAVE main;
    END IF;

    -- 2. sender must have enough balance
    SELECT balance INTO v_balance
    FROM Accounts
    WHERE account_id = p_sender_account_id;

    IF v_balance < p_transfer_amount THEN
        SET p_message = 'Error: Insufficient balance';
        LEAVE main;
    END IF;

    -- 3. do the transfer
    START TRANSACTION;
    UPDATE Accounts SET balance = balance - p_transfer_amount WHERE account_id = p_sender_account_id;
    UPDATE Accounts SET balance = balance + p_transfer_amount WHERE account_id = p_receiver_account_id;
    COMMIT;

    SET p_message = 'Success: Transfer completed';
END$$
DELIMITER ;

CALL TransferFunds(1, 2, 1500, @msg);   SELECT @msg;     -- success
CALL TransferFunds(1, 2, 99999, @msg);  SELECT @msg;     -- insufficient balance
CALL TransferFunds(1, 77, 100, @msg);   SELECT @msg;     -- account not found
SELECT * FROM Accounts;

-- ---- Q2 : function GetTotalOrderValue ----
DELIMITER $$
CREATE FUNCTION GetTotalOrderValue(p_customer_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT IFNULL(SUM(total_amount), 0.00) INTO v_total
    FROM Orders
    WHERE customer_id = p_customer_id
      AND order_status = 'Completed';

    RETURN v_total;
END$$
DELIMITER ;

SELECT GetTotalOrderValue(101) AS customer_101;          -- 1200.00
SELECT GetTotalOrderValue(102) AS customer_102;          -- 0.00
SELECT GetTotalOrderValue(555) AS customer_missing;      -- 0.00


-- #####################################################################
-- BATCH C
-- #####################################################################
DROP DATABASE IF EXISTS a6_batch_c;
CREATE DATABASE a6_batch_c;
USE a6_batch_c;

CREATE TABLE Orders (
    order_id     INT PRIMARY KEY,
    order_date   DATE,
    total_amount DECIMAL(12,2)
);

CREATE TABLE Products (
    product_id     INT PRIMARY KEY,
    stock_quantity INT
);

-- orders placed in the previous month (works on any day you run it)
INSERT INTO Orders VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), 1000),
(2, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), 2500),
(3, CURDATE(), 700),                                     -- this month, ignored
(4, DATE_SUB(CURDATE(), INTERVAL 2 MONTH), 400);         -- two months ago, ignored

INSERT INTO Products VALUES (1, 50), (2, 0);

-- ---- Q1 : procedure GenerateMonthlySalesSummary ----
DELIMITER $$
CREATE PROCEDURE GenerateMonthlySalesSummary()
BEGIN
    DECLARE v_month  VARCHAR(7);
    DECLARE v_total  DECIMAL(12,2);
    DECLARE v_orders INT;
    DECLARE v_exists INT;

    -- 1. create summary table if it does not exist
    CREATE TABLE IF NOT EXISTS MonthlySalesSummary (
        month_year       VARCHAR(7) PRIMARY KEY,
        total_sales      DECIMAL(12,2),
        number_of_orders INT
    );

    -- 2. previous month as 'YYYY-MM'
    SET v_month = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m');

    -- 3. calculate its totals
    SELECT IFNULL(SUM(total_amount), 0), COUNT(*)
    INTO v_total, v_orders
    FROM Orders
    WHERE DATE_FORMAT(order_date, '%Y-%m') = v_month;

    -- 4. update if the month already exists, else insert
    SELECT COUNT(*) INTO v_exists
    FROM MonthlySalesSummary
    WHERE month_year = v_month;

    IF v_exists > 0 THEN
        UPDATE MonthlySalesSummary
        SET total_sales = v_total, number_of_orders = v_orders
        WHERE month_year = v_month;
    ELSE
        INSERT INTO MonthlySalesSummary VALUES (v_month, v_total, v_orders);
    END IF;
END$$
DELIMITER ;

CALL GenerateMonthlySalesSummary();      -- inserts
CALL GenerateMonthlySalesSummary();      -- updates (still only one row)
SELECT * FROM MonthlySalesSummary;

-- ---- Q2 : function CheckProductAvailability ----
DELIMITER $$
CREATE FUNCTION CheckProductAvailability(p_product_id INT, p_quantity_requested INT)
RETURNS TINYINT(1)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_stock INT;

    SELECT stock_quantity INTO v_stock
    FROM Products
    WHERE product_id = p_product_id;

    IF v_stock IS NOT NULL AND v_stock >= p_quantity_requested THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END$$
DELIMITER ;

SELECT CheckProductAvailability(1, 10)  AS enough_stock;    -- 1
SELECT CheckProductAvailability(1, 100) AS too_many;        -- 0
SELECT CheckProductAvailability(99, 1)  AS no_such_product; -- 0
