USE northwind;

/*
Exercise #1
-- Select the name, address, city, and region of employees
*/

SELECT FirstName, LastName, City, Region 
FROM Employees;

/*
Exercise #2
Select the name, address, city, and region of employees living in USA
*/

SELECT FirstName, LastName, City, Region 
FROM Employees
WHERE Country = 'USA';

/*
Exercise #3
Select the name, address, city, and region of employees older than 50 years
old
*/

-- In addition there is a performance check of 2 approaches (possible to check with high volume of data - too less in this query in northwind database):

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Method 1: Format()

WITH EmployeeAge AS (
	SELECT FirstName, LastName, City, Region, FORMAT(BirthDate,'yyyy-MM-dd') as BirthDate, (0 + FORMAT(GETDATE(),'yyyyMMdd') - FORMAT(BirthDate,'yyyyMMdd')) / 10000 AS Age
	FROM Employees
)
SELECT *
FROM EmployeeAge
WHERE Age > 60
ORDER BY Age DESC;

-- Method 2: CONVERT():
-- With a big amount of datetime data this approach should be faster

WITH EmployeeAge AS (
	SELECT FirstName, LastName, City, Region, 
	FORMAT(BirthDate,'yyyy-MM-dd') as BirthDate,
	(CONVERT(INT, CONVERT(VARCHAR(8), GETDATE(), 112)) - CONVERT(INT, CONVERT(VARCHAR(8), BirthDate, 112))) / 10000 AS Age
    FROM Employees
)
SELECT *
FROM EmployeeAge
WHERE Age > 60
ORDER BY Age DESC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;



/*
Exercise #4
Select the name, address, city, and region of employees that have placed
orders to be delivered in Belgium. Write two versions of the query, with and
without join.
*/



