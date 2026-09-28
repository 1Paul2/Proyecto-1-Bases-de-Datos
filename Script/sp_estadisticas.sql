USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE sp_estadistica
    @proveedor VARCHAR(100),
    @categoria VARCHAR(100)
AS
BEGIN
    SELECT 
        S.SupplierName,
        SC.SupplierCategoryName
    FROM Purchasing.Suppliers S
    INNER JOIN Purchasing.SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
END;
GO


