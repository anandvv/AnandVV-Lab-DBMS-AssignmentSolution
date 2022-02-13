create database eCommerce;

use eCommerce;

CREATE TABLE Supplier (
	SUPP_ID INT NOT NULL PRIMARY KEY,
	SUPP_NAME VARCHAR(50),
	SUPP_CITY VARCHAR(50),
	SUPP_PHONE VARCHAR(20)
);

CREATE TABLE Customer (
	CUS_ID INT NOT NULL PRIMARY KEY,
	CUS_NAME VARCHAR(50),
	CUS_PHONE VARCHAR(20),
	CUS_CITY VARCHAR(50),
	CUS_GENDER VARCHAR(10)
);

CREATE TABLE Category (
	CAT_ID INT NOT NULL PRIMARY KEY,
	CAT_NAME VARCHAR(50)
);

CREATE TABLE Product (
	PRO_ID INT NOT NULL PRIMARY KEY,
	PRO_NAME VARCHAR(50),
	PRO_DESC VARCHAR(255),
	CAT_ID INT references Category(CAT_ID)
);

CREATE TABLE ProductDetails (
	PROD_ID INT NOT NULL PRIMARY KEY,
	PRO_ID INT references Product(PRO_ID),
	SUPP_ID INT references Supplier(SUPP_ID),
	PRICE INT
);

CREATE TABLE Orders (
	ORD_ID INT NOT NULL PRIMARY KEY,
	ORD_AMOUNT INT,
	ORD_DATE DATE,
	CUS_ID INT references Customer(CUS_ID),
	PROD_ID INT references Product(PRO_ID)
);

CREATE TABLE Rating (
	RAT_ID INT NOT NULL PRIMARY KEY,
	CUS_ID INT references Customer(CUS_ID),
	SUPP_ID INT references Supplier(SUPP_ID),
	RAT_RATSTARS INT
);

INSERT INTO Supplier values(1, 'Rajesh Retails', 'Delhi', '1234567890');
INSERT INTO Supplier values(2, 'Appario Ltd.', 'Mumbai', '2589631470');
INSERT INTO Supplier values(3, 'Knome products', 'Bangalore', '9785462315');
INSERT INTO Supplier values(4, 'Bansal Retails', 'Kochi', '8975463285');
INSERT INTO Supplier values(5, 'Mittal Ltd.', 'Lucknow', '7898456532');

INSERT INTO Customer values(1, 'AAKASH', '9999999999', 'Delhi', 'M');
INSERT INTO Customer values(2, 'AMAN', '9785463215', 'Noida', 'M');
INSERT INTO Customer values(3, 'NEHA', '9999999999', 'Mumbai', 'F');
INSERT INTO Customer values(4, 'MEGHA', '9994562399', 'Kolkata', 'F');
INSERT INTO Customer values(5, 'PULKIT', '7895999999', 'Lucknow', 'M');

INSERT INTO Category values(1, 'BOOKS');
INSERT INTO Category values(2, 'GAMES');
INSERT INTO Category values(3, 'GROCERIES');
INSERT INTO Category values(4, 'ELECTRONICS');
INSERT INTO Category values(5, 'CLOTHES');

INSERT INTO Product values(1, 'GTA V', 'DFJDJFDJFDJFDJFJF', 2);
INSERT INTO Product values(2, 'TSHIRT', 'DFDFJDFJDKFD', 5);
INSERT INTO Product values(3, 'ROG LAPTOP', 'DFNTTNTNTERND', 4);
INSERT INTO Product values(4, 'OATS', 'REURENTBTOTH', 3);
INSERT INTO Product values(5, 'HARRY POTTER', 'NBEMCTHTJTH', 1);

INSERT INTO ProductDetails values(1,1,2, 1500);
INSERT INTO ProductDetails values(2,3,5,30000);
INSERT INTO ProductDetails values(3,5,1, 3000);
INSERT INTO ProductDetails values(4,2,3, 2500);
INSERT INTO ProductDetails values(5,4,1, 1000);

INSERT INTO Orders values(20, 1500, '2021-10-12', 3, 5);
INSERT INTO Orders values(25, 30500, '2021-09-16', 5, 2);
INSERT INTO Orders values(26, 2000, '2021-10-05', 1, 1);
INSERT INTO Orders values(30, 3500, '2021-08-16', 4, 3);
INSERT INTO Orders values(50, 2000, '2021-10-06', 2, 1);

INSERT INTO Rating values(1,2,2,4);
INSERT INTO Rating values(2,3,4,3);
INSERT INTO Rating values(3,5,1,5);
INSERT INTO Rating values(4,1,3,2);
INSERT INTO Rating values(5,4,5,4);

/* Display the number of the customer group by their genders who have placed any order of amount greater than or equal to Rs.3000 */
select count(C.CUS_ID) AS NoOfCustomers, C.CUS_GENDER AS Gender
FROM Customer C 
INNER JOIN Orders O
ON C.CUS_ID = O.CUS_ID
WHERE O.ORD_AMOUNT > 3000
GROUP BY C.CUS_GENDER;

/* Display all the orders along with the product name ordered by a customer having Customer_Id=2 */
SELECT O.ORD_ID as OrderID, O.ORD_AMOUNT as OrderAmount, O.ORD_DATE as OrderDate, O.CUS_ID as CustomerID, O.PROD_ID as ProductID, P.PRO_NAME as ProductName
FROM ORDERS O
INNER JOIN Product P
ON O.PROD_ID = P.PRO_ID
WHERE CUS_ID=2;

/* Display the Supplier details who can supply more than one product */
SELECT IT.SupplierID, S.SUPP_NAME AS SupplierName, S.SUPP_CITY AS SupplierCity, S.SUPP_PHONE AS PhoneNumber, IT.NoOfProducts FROM
(SELECT count(PD.PROD_ID) AS NoOfProducts, PD.SUPP_ID as SupplierID
FROM ProductDetails PD
group by PD.SUPP_ID) IT
INNER JOIN Supplier S
ON IT.SupplierID = S.SUPP_ID
WHERE IT.NoOfProducts > 1;

/* Find the category of the product whose order amount is minimum */
SELECT C.CAT_NAME as CategoryName FROM
(SELECT P.PRO_ID as ProductId, P.PRO_NAME as ProductName, IT.OrderAmount, P.CAT_ID FROM ((
SELECT SUM(O.ORD_AMOUNT) AS OrderAmount, O.PROD_ID as ProductId
FROM Orders O
GROUP BY PROD_ID
ORDER BY OrderAmount ASC LIMIT 1) IT
INNER JOIN Product P
ON IT.ProductID = P.PRO_ID)) IT2
INNER JOIN Category C
ON C.CAT_ID = IT2.CAT_ID;

/* Display the Id and Name of the Product ordered after “2021-10-05” */
SELECT P.PRO_ID as ProductId, P.PRO_NAME as ProductName FROM Orders O
INNER JOIN Product P
ON O.PROD_ID = P.PRO_ID
WHERE O.ORD_DATE > '2021-10-05'
ORDER BY ProductId;

/* Display customer name and gender whose names start or end with character 'A' */
SELECT C.CUS_NAME as CustomerName, C.CUS_GENDER as Gender from Customer C
WHERE C.CUS_NAME like 'A%' OR C.CUS_NAME like '%A';

/* STORED PROCEDURE */

DELIMITER //

CREATE PROCEDURE SP_DisplayRating (IN supplierName VARCHAR(50))
BEGIN
	SELECT R.SUPP_ID, S.SUPP_NAME, R.RAT_RATSTARS, 
    CASE
		WHEN R.RAT_RATSTARS > 4 THEN "Genuine Supplier"
        WHEN R.RAT_RATSTARS > 2 THEN "Average Supplier"
        ELSE "Supplier should not be considered"
    END AS VERDICT
	FROM rating R
    INNER JOIN Supplier S
    ON R.SUPP_ID = S.SUPP_ID
	WHERE R.SUPP_ID = (
		SELECT SUPP_ID
		FROM Supplier
		WHERE SUPP_NAME = supplierName);
END //

DELIMITER ;
        
CALL sp_displayrating('Rajesh Retails');


