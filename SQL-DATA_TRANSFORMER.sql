====================================================================================
CREATE DATABASE IF NOT EXISTS Data_Transformer;
USE Data_Transformer;

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Employees;

-- 1. CUSTOMERS TABLE
-------------------------------------------------------------------------------------
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    RegistrationDate DATE
);

-- 2. ORDERS TABLE
--------------------------------------------------------------------------------------
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 3. EMPLOYEES TABLE
---------------------------------------------------------------------------------------
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Department VARCHAR(50),
    HireDate DATE,
    Salary DECIMAL(10, 2) NOT NULL
);

-- SAMPLE DATA
INSERT INTO Customers (CustomerID, FirstName, LastName, Email, RegistrationDate)
VALUES
(1, 'John',  'Doe',   ' john.doe@email.com ',   '2022-03-15'),
(2, 'Jane',  'Smith', 'jane.smith@email.com',   '2021-11-02'),
(3, 'Aarav', 'Patel', 'aarav.patel@email.com',  '2023-01-10'),
(4, 'Mia',   'Shah',  'mia.shah@email.com',     '2024-05-21');

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
VALUES
(101, 1, '2023-07-01', 150.50),
(102, 2, '2023-07-03', 200.75),
(103, 1, '2023-08-12', 650.00),
(104, 3, '2024-01-20', 1200.00),
(105, 2, '2024-03-15', 850.00),
(106, 3, '2024-06-05', 450.00);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, HireDate, Salary)
VALUES
(1, 'Mark',  'Johnson', 'Sales',      '2020-01-15', 50000.00),
(2, 'Susan', 'Lee',      'HR',         '2021-03-20', 55000.00),
(3, 'David', 'Brown',    'IT',         '2019-06-10', 72000.00),
(4, 'Emma',  'Wilson',   'Finance',    '2022-09-01', 45000.00),
(5, 'Noah',  'Davis',    'Marketing',  '2023-02-14', 60000.00);


-- 1. INNER JOIN: orders that have a matching customer.
------------------------------------------------------------------------------------
SELECT
    o.OrderID, o.OrderDate, o.TotalAmount,
    c.CustomerID, c.FirstName, c.LastName, c.Email
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
ORDER BY o.OrderID;

-- 2. LEFT JOIN: every customer, with matching orders if present.
-----------------------------------------------------------------------------------
SELECT
    c.CustomerID, c.FirstName, c.LastName,
    o.OrderID, o.OrderDate, o.TotalAmount
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
ORDER BY c.CustomerID, o.OrderID;

-- 3. RIGHT JOIN: every order and its matching customer, if present.
------------------------------------------------------------------------------------
SELECT
    o.OrderID, o.OrderDate, o.TotalAmount,
    c.CustomerID, c.FirstName, c.LastName
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
ORDER BY o.OrderID;

-- 4. FULL OUTER JOIN:
--------------------------------------------------------------------------------------
-- MySQL does not directly support FULL OUTER JOIN.
-- Combine LEFT JOIN with unmatched rows from the right side using UNION ALL.
SELECT
    c.CustomerID, c.FirstName, c.LastName,
    o.OrderID, o.OrderDate, o.TotalAmount
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID

UNION ALL

SELECT
    c.CustomerID, c.FirstName, c.LastName,
    o.OrderID, o.OrderDate, o.TotalAmount
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL
ORDER BY CustomerID, OrderID;

-- 5. Customers whose order amount is greater than the average order amount.
-------------------------------------------------------------------------------
SELECT DISTINCT
    c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.TotalAmount > (SELECT AVG(TotalAmount) FROM Orders)
ORDER BY o.TotalAmount DESC;

-- 6. Employees whose salary is greater than the average employee salary.
---------------------------------------------------------------------------------
SELECT
    EmployeeID, FirstName, LastName, Department, Salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees)
ORDER BY Salary DESC;

-- 7. Extract the year and month from each OrderDate.
---------------------------------------------------------------------------------
SELECT
    OrderID,
    OrderDate,
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth
FROM Orders
ORDER BY OrderDate;

-- 8. Difference in days between OrderDate and today's date.
----------------------------------------------------------------------------------
SELECT
    OrderID,
    OrderDate,
    DATEDIFF(CURDATE(), OrderDate) AS DaysSinceOrder
FROM Orders
ORDER BY OrderDate;

-- 9. Format OrderDate as DD-MMM-YYYY (for example, 01-Jul-2023).
----------------------------------------------------------------------------------
SELECT
    OrderID,
    OrderDate,
    DATE_FORMAT(OrderDate, '%d-%b-%Y') AS FormattedOrderDate
FROM Orders
ORDER BY OrderDate;

-- 10. Concatenate FirstName and LastName to create a full name.
----------------------------------------------------------------------------------
SELECT
    CustomerID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM Customers
ORDER BY CustomerID;

-- 11. Replace 'John' with 'Jonathan' in customer first names.
------------------------------------------------------------------------------------
SELECT
    CustomerID,
    FirstName,
    REPLACE(FirstName, 'John', 'Jonathan') AS UpdatedFirstName
FROM Customers
ORDER BY CustomerID;

-- 12. Convert FirstName to uppercase and LastName to lowercase.
-------------------------------------------------------------------------------------
SELECT
    CustomerID,
    UPPER(FirstName) AS FirstNameUppercase,
    LOWER(LastName) AS LastNameLowercase
FROM Customers
ORDER BY CustomerID;

-- 13. Remove leading/trailing spaces from the Email field.
-------------------------------------------------------------------------------------
SELECT
    CustomerID,
    Email AS OriginalEmail,
    TRIM(Email) AS TrimmedEmail
FROM Customers
ORDER BY CustomerID;

-- 14. Running total of TotalAmount for each order.
-------------------------------------------------------------------------------------
SELECT
    OrderID,
    OrderDate,
    TotalAmount,
    SUM(TotalAmount) OVER (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal
FROM Orders
ORDER BY OrderDate, OrderID;

-- 15. Rank orders by TotalAmount, highest amount gets rank 1.
--------------------------------------------------------------------------------------
SELECT
    OrderID,
    TotalAmount,
    RANK() OVER (ORDER BY TotalAmount DESC) AS OrderRank
FROM Orders
ORDER BY OrderRank, OrderID;

-- 16. Discount based on TotalAmount:
--------------------------------------------------------------------------------------
-- above 1000 = 10%; above 500 = 5%; otherwise 0%.
SELECT
    OrderID,
    TotalAmount,
    CASE
        WHEN TotalAmount > 1000 THEN 10
        WHEN TotalAmount > 500 THEN 5
        ELSE 0
    END AS DiscountPercent,
    ROUND(
        TotalAmount *
        CASE
            WHEN TotalAmount > 1000 THEN 0.10
            WHEN TotalAmount > 500 THEN 0.05
            ELSE 0
        END,
        2
    ) AS DiscountAmount,
    ROUND(
        TotalAmount -
        TotalAmount *
        CASE
            WHEN TotalAmount > 1000 THEN 0.10
            WHEN TotalAmount > 500 THEN 0.05
            ELSE 0
        END,
        2
    ) AS AmountAfterDiscount
FROM Orders
ORDER BY OrderID;

-- 17. Categorize employee salaries as High, Medium, or Low.
-- Assumption: High >= 70000; Medium >= 50000 and < 70000; otherwise Low.
-----------------------------------------------------------------------------------
SELECT
    EmployeeID,
    CONCAT(FirstName, ' ', LastName) AS EmployeeName,
    Department,
    Salary,
    CASE
        WHEN Salary >= 70000 THEN 'High'
        WHEN Salary >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS SalaryCategory
FROM Employees
ORDER BY Salary DESC;
======================================================================================