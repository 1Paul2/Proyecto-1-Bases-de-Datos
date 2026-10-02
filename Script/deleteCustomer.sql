CREATE OR ALTER PROCEDURE SP_DeleteCustomer
    @CustomerID INT
AS
BEGIN
    DELETE FROM Sales.Customers WHERE CustomerID = @CustomerID;
END;
GO