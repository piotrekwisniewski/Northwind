USE northwind;

-- Get all columns from the tables Customers, Orders and Suppliers

SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM Suppliers;
SELECT * FROM Employees;
SELECT * FROM [Order Details];

-- Get all Customers alphabetically, by Country and name

SELECT * 
FROM Customers
ORDER BY Country, CompanyName;

-- Get all Orders by date

SELECT OrderID, CustomerID, OrderDate
FROM Orders
ORDER BY Orders.OrderDate ASC;

-- Get the count of all Orders made during 1997

SELECT COUNT(OrderID) as [Orders '97]
FROM Orders
WHERE  YEAR(OrderDate) = 1997;


-- Get the names of all the contact persons where the person is a manager, alphabetically

-- *surname as whole part after first space
SELECT ContactName, ContactTitle
FROM Suppliers
WHERE ContactTitle LIKE '%Manager%'
ORDER BY SUBSTRING(ContactName, CHARINDEX(' ', ContactName), LEN(ContactName)) ASC;

-- * surname as last word
SELECT ContactName, ContactTitle
FROM Suppliers
WHERE ContactTitle LIKE '%Manager%'
ORDER BY SUBSTRING(ContactName, CHARINDEX(' ', ContactName), LEN(ContactName)) ASC;

/*
there should be more sophisticaded methods of retrieving first names and surnames 
- in case where people have more than 2 first names and more complex surnames, 
but for current case this simple methods are enough
*/

-- Get all orders placed on the 19th of May, 1997

SELECT OrderID, CustomerID, OrderDate
FROM Orders
WHERE OrderDate= '1997-05-19'
ORDER BY Orders.OrderDate ASC;


-- Excersices for JOINS

-- Create a report for all the orders of 1996 and their Customers (152 rows)


SELECT *
FROM Orders o
LEFT JOIN Customers c
ON o.CustomerID = c.CustomerID
WHERE YEAR(o.OrderDate) = '1996';


-- Create a report that shows the number of employees and customers from each city that has employees in it (5 rows)

SELECT e.City, COUNT(DISTINCT e.EmployeeID) AS EmployeesNumber, COUNT(DISTINCT c.CustomerID) AS CustomersNumber
FROM Employees e
LEFT JOIN Customers c
ON e.City = c.City
GROUP BY e.City
ORDER BY City;

-- Create a report that shows the number of employees and customers from each city that has customers in it (69 rows)

SELECT c.City as City, COUNT(DISTINCT e.EmployeeID) AS EmployeesNumber, COUNT(DISTINCT c.CustomerID) AS CustomersNumber
FROM Employees e
RIGHT JOIN Customers c
ON e.City = c.City
GROUP BY c.City
ORDER BY City;


-- Create a report that shows the number of employees and customers from each city (71 rows)


SELECT e.City, c.City, COUNT(DISTINCT e.EmployeeID) AS EmployeesNumber, COUNT(DISTINCT c.CustomerID) AS CustomersNumber
FROM Employees e
FULL OUTER JOIN Customers c
ON e.City = c.City
GROUP BY e.City, c.City
ORDER BY e.City, c.City;

-- Exercise SQL Queries for HAVING

-- Create a report that shows the order ids and the associated employee names for orders that shipped after the required date (37 rows)

SELECT o.OrderID, o.EmployeeID, e.FirstName, e.LastName, o.RequiredDate, o.ShippedDate
FROM Orders o
JOIN Employees e
ON o.EmployeeID = e.EmployeeID
WHERE o.ShippedDate > o.RequiredDate
ORDER BY RequiredDate;


-- Create a report that shows the total quantity of products (from the Order_Details table) ordered. Only show records for products for which the quantity ordered is fewer than 200 (5rows)

SELECT od.ProductID, p.ProductName, SUM(od.Quantity) AS [Total Product Quantity]
FROM  [Order Details] od
JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName
HAVING SUM(od.Quantity) < 200
ORDER BY SUM(od.ProductID) DESC;


--Create a report that shows the total number of orders by Customer since December 31, 1996. The report should only return rows for which the total number of orders is greater than 15 (5 rows)


SELECT CustomerID, COUNT(OrderID) AS TotalOrdersNum
FROM Orders
WHERE OrderDate >= '1996-12-31'
GROUP BY CustomerID
HAVING COUNT(OrderID) > 15


-- Exercise SQL Inserting Records
-- 3 steps in one Transaction

-- 1. Insert yourself into the Employees table. Include the following fields: LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, City, Region, PostalCode, Country, HomePhone, ReportsTo
-- 2. Insert an order for yourself in the Orders table. Include the following fields: CustomerID, EmployeeID, OrderDate, RequiredDate
-- 3. Insert order details in the Order_Details table. Include the following fields: OrderID, ProductID, UnitPrice, Quantity, Discount

BEGIN TRANSACTION;

BEGIN TRY

-- ad. 1. Insert yourself into the Employees table. Include the following fields: LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, City, Region, PostalCode, Country, HomePhone, ReportsTo

	INSERT INTO Employees (LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, City, Region, PostalCode, Country, HomePhone, ReportsTo) 
	VALUES ('Barney', 'Flitcher', 'Sales rep.', 'Mr.', '1968-01-01', '1992-03-02', 'Chester', NULL, 89899, 'UK',  '(71) 555-456-7896', 2);

-- ad. 2. Insert an order for yourself in the Orders table. Include the following fields: CustomerID, EmployeeID, OrderDate, RequiredDate

	DECLARE @empID int = SCOPE_IDENTITY();

	INSERT INTO Orders (CustomerID, EmployeeID, OrderDate, RequiredDate)
	VALUES ('CHOPS', @empID, '1997-11-11', '1998-11-11');

-- ad. 3. Insert order details in the Order_Details table. Include the following fields: OrderID, ProductID, UnitPrice, Quantity, Discount

	DECLARE @orderID int = SCOPE_IDENTITY();

	INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
	VALUES 
	(@orderID, 2, 18, 60, 0.05),
	(@orderID, 54, 7.45, 100, 0.05),
	(@orderID, 47, 7.6, 45, 0.05),
	(@orderID, 41, 7.70, 120, 0)
	   	  
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Error occured. Changes withdrawn.';
END CATCH;


-- Exercise SQL Updating Records (use transactions)

--1. Update the phone of yourself (from the previous entry in Employees table) (1 row)
--2. Double the quantity of the order details record you inserted before (1 row)
--3. Repeat previous update but this time update all orders associated with you (1 row)

BEGIN TRANSACTION;
BEGIN TRY

-- ad. 1:

	DECLARE @last_emp_id int = IDENT_CURRENT('Employees');
	UPDATE Employees
	SET HomePhone = '(71) 555-456-7897'
	WHERE EmployeeID = @last_emp_id;

-- ad. 2:
	
	DECLARE @last_order_id int = IDENT_CURRENT('Orders');
	UPDATE [Order Details]
	SET Quantity = 2*Quantity
	WHERE OrderID = @last_order_id;

-- ad. 3:
			
	UPDATE [Order Details]
	SET Quantity = 2*Quantity
	FROM [Order Details]
	INNER JOIN Orders
	ON [Order Details].OrderID = [Orders].OrderID
	WHERE EmployeeID = @last_emp_id
	   	 
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	PRINT 'Error occured. Changes withdrawn.';
END CATCH;


--Exercise SQL Deleting Records

--1. Delete the records you inserted before. Don't delete any other records!

BEGIN TRANSACTION

DECLARE @last_emp_id int = IDENT_CURRENT('Employees');
DECLARE @last_order_id int = IDENT_CURRENT('Orders')-1;

DELETE FROM [Order Details] WHERE OrderID = @last_order_id;
DELETE FROM Orders WHERE OrderID = @last_order_id;
DELETE FROM Employees WHERE EmployeeID = @last_emp_id;

COMMIT;

--Exercise Advanced SQL queries

--1. What were our total revenues in 1997 (Result must be 617.085,27)

-- OPT 1:

SELECT ROUND(SUM(D.UnitPrice * D.Quantity * (1-D.Discount)), 3) AS [1997 total revenue]
FROM [Order Details] D
INNER JOIN (SELECT OrderID FROM Orders WHERE YEAR(OrderDate) = 1997) O
ON D.OrderID = O.OrderID;



-- OPT 2 (Using CTE):

WITH CTE_1 AS(

	SELECT D.*, YEAR(O.OrderDate) AS Y
	FROM [Order Details] D
	INNER JOIN Orders O
	ON D.OrderID = O.OrderID
	WHERE YEAR(OrderDate) = 1997
	)


SELECT SUM(UnitPrice * Quantity * (1 - Discount)) AS [Total '97 revenue]
FROM CTE_1;


-- 2. What is the total amount each customer has payed us so far (Hint: QUICK-Stop has payed us 110.277,32)

-- Option 1:

WITH CTE_Clients AS (

SELECT D.*, Cus.CustomerID, Cus.CompanyName, (D.UnitPrice * D.Quantity * (1-D.Discount)) AS OrderValue
FROM [Order Details] D
JOIN (SELECT O.OrderID, O.CustomerID, C.CompanyName
	FROM Orders O
	INNER JOIN Customers C
	ON O.CustomerID = C.CustomerID) Cus
ON D.OrderID = Cus.OrderID
)

SELECT CustomerID, CompanyName, SUM(OrderValue) AS [Total customer payments]
FROM CTE_Clients
GROUP BY CustomerID, CompanyName
ORDER BY CustomerID ASC;

-- Option 2:

SELECT O.CustomerID, C.CompanyName, SUM((D.UnitPrice * D.Quantity * (1-D.Discount))) AS TotalSales
FROM [Order Details] D
INNER JOIN Orders O ON D.OrderID = O.OrderID
INNER JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY O.CustomerID, C.CompanyName
ORDER BY TotalSales DESC;


--3. Find the 10 top selling products (Hint: Top selling product is "Cote de Blaye")

-- By items sold:

SELECT TOP (10) P.ProductID, P.ProductName, SUM(D.Quantity) AS ItemsSold
FROM [Order Details] D
INNER JOIN Products P ON D.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY  ItemsSold DESC;

-- By Sales Value

SELECT TOP (10) P.ProductID, P.ProductName, SUM(D.Quantity * D.UnitPrice * (1-D.Discount)) AS SalesValue
FROM [Order Details] D
INNER JOIN Products P ON D.ProductID = P.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY  SalesValue DESC;


--4. Create a view with total revenues per customer


DROP VIEW IF EXISTS [Customer Revenue];
GO
CREATE VIEW [Customer Revenue] AS
	
	SELECT O.CustomerID, C.CompanyName, SUM((D.UnitPrice * D.Quantity * (1-D.Discount))) AS CustomerRevenue
	FROM [Order Details] D
	INNER JOIN Orders O ON D.OrderID = O.OrderID
	INNER JOIN Customers C ON O.CustomerID = C.CustomerID
	GROUP BY O.CustomerID, C.CompanyName;

SELECT * 
FROM [Customer Revenue]
ORDER BY CustomerRevenue DESC;


--5. Which UK Customers have payed us more than 1000 dollars (6 rows)


SELECT [Orders].CustomerID, C.CompanyName, CONVERT(money,SUM([Order Details].UnitPrice * [Order Details].Quantity * (1-[Order Details].Discount))*100/100) AS CustomerSales
FROM Orders
INNER JOIN [Order Details] ON [Orders].OrderID = [Order Details].OrderID
INNER JOIN (SELECT * FROM Customers WHERE Customers.Country = 'UK') C ON [Orders].CustomerID = C.CustomerID
GROUP BY [Orders].CustomerID, C.CompanyName
HAVING CONVERT(money,SUM([Order Details].UnitPrice * [Order Details].Quantity * (1-[Order Details].Discount))*100/100) > 1000
ORDER BY CustomerSales DESC;



--6. How much has each customer payed in total and how much in 1997.

WITH CTE_Sales AS (
	SELECT Customers.CustomerID, Customers.CompanyName, Customers.Country, 
	ISNULL(SUM([Order Details].Quantity * [Order Details].UnitPrice * (1 - [Order Details].Discount)),0) AS TotalSales,
    ISNULL(SUM(CASE WHEN YEAR(Orders.OrderDate) = 1997 THEN [Order Details].Quantity * [Order Details].UnitPrice * (1 - [Order Details].Discount) ELSE 0 END),0) AS Sales1997
	FROM Customers
	LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID
	LEFT JOIN [Order Details] ON [Order Details].OrderID = Orders.OrderID
	GROUP BY Customers.CustomerID, Customers.CompanyName, Customers.Country
	)

SELECT CustomerID, CompanyName, Country, 
       CONVERT(money, TotalSales) AS [Total sales], 
       CONVERT(money, Sales1997) AS [1997 sales]
FROM CTE_Sales
ORDER BY [Total sales] DESC;




















