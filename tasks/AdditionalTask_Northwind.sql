USE northwind;

SELECT * FROM Orders;
SELECT * FROM [Order Details];
SELECT * FROM Customers;
SELECT * FROM Products;

/*
Zadanie 1. Korzystając z tabel Orders, Order Details, Customers i Products w bazie Northwind, napisz zapytanie SQL, które:
	• Dla każdego miesiąca w danym roku zwróci łączną wartość sprzedaży (np. SumOfSales) i liczbę unikalnych klientów.
	• Uwzględni wyliczanie wartości sprzedaży w oparciu o kolumny UnitPrice, Quantity i Discount (jak w rzeczywistych raportach sprzedażowych)
*/

-- Utworzenie widoku dla przejrzystości działań:

CREATE VIEW OrdersValues AS

-- Obliczenie całkowitej wartości poszczególnego zamówienia:

WITH CTE_single_order_value AS (
	SELECT OrderID, ROUND(SUM(UnitPrice * Quantity * (1-Discount)),2) as OrderValue
	FROM [Order Details]
	GROUP BY OrderID
	),

-- JOIN z tabelą Orders:

CTE_Orders_1 AS (
	SELECT Orders.OrderID, Orders.CustomerID, Orders.OrderDate, CTE_single_order_value.OrderValue, 
		CONVERT(nvarchar(7), Orders.OrderDate, 120) AS Month, CONVERT(nvarchar(4), Orders.OrderDate, 120) AS Year
	FROM Orders
	JOIN CTE_single_order_value
	ON Orders.OrderID = CTE_single_order_value.OrderID
	)

SELECT * FROM CTE_Orders_1;

-- # Zadanie 1.1: Suma sprzedaży po miesiącach:

SELECT Month, SUM (OrderValue) AS SumOfSales
FROM OrdersValues
GROUP BY Month
ORDER BY Month;

-- # Zadanie 1.2: Liczba unikalnych klientów w ujeciu miesięcznym

SELECT Month, COUNT (DISTINCT CustomerID) AS NumberOfUniqueClients 
FROM OrdersValues
GROUP BY Month
ORDER BY Month;


/*
Zadanie 2. Rozszerz zapytanie o funkcję okna (np. ROW_NUMBER() lub RANK()) w celu nadania rankingów (1-10) dziesięciu najlepszym klientom w ujęciu rocznym.
*/

-- tworzymy widok:

CREATE VIEW AnnualSales AS 
	SELECT DISTINCT CustomerID, Year, 
		SUM(OrderValue) OVER (PARTITION BY CustomerID, Year ORDER BY Year) AS TotalSales
	FROM OrdersValues;
	)

-- wyświetlenie 10 najlepszych klientów w ujęciu rocznym:
WITH CTE_AnnualClientsRank AS(
	SELECT CustomerID, Year, TotalSales, ROW_NUMBER() OVER (PARTITION BY Year ORDER BY TotalSales DESC) AS AnnualClientPosition
	FROM AnnualSales
	)
SELECT AnnualClientPosition, CustomerID, Year --, TotalSales
FROM CTE_AnnualClientsRank
WHERE AnnualClientPosition <=10;


/*
Zadanie 3. Wyjaśnij, w jaki sposób można zoptymalizować zapytanie (np. proponując odpowiednie indeksy na tabelach Orders, Order Details czy Customers).
*/

/*
Można stowrzyć indeksy dla często użytkowanych kolumn w danych tabelach (nie będących jednocześnie PRIMARY KEY) np:

- Tabela Orders: EmployeeID, OrderDate
- Tabela [Order Details]: UnitPrice, Quantity, Discount (composite index)

Z tabel Customers i Products de facto nie musiałem korzystać do rozwiązania tych zadań.
*/

CREATE INDEX idx_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX idx_Orders_OrderDate ON Orders(OrderDate);
CREATE INDEX idx_OrderDetails_UnitPrice_Quantity_Discount ON [Order Details](UnitPrice, Quantity, Discount);











































