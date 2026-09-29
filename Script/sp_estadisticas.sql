USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE sp_estadistica
    @proveedor VARCHAR(100),
    @categoria VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    WITH TotalesPorPedido AS (
        SELECT 
            S.SupplierName,
            SC.SupplierCategoryName,
            PO.PurchaseOrderID,
            SUM(POL.OrderedOuters * POL.ExpectedUnitPricePerOuter) AS TotalPedido
        FROM Purchasing.Suppliers S
        INNER JOIN Purchasing.SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
        INNER JOIN Purchasing.PurchaseOrders PO ON PO.SupplierID = S.SupplierID
        INNER JOIN Purchasing.PurchaseOrderLines POL ON POL.PurchaseOrderID = PO.PurchaseOrderID
        WHERE S.SupplierName LIKE '%' + @proveedor + '%' 
            AND SC.SupplierCategoryName LIKE '%' + @categoria + '%'
        GROUP BY S.SupplierName, SC.SupplierCategoryName, PO.PurchaseOrderID
    )
    SELECT
        SupplierName AS Proveedor,
        SupplierCategoryName AS Categoria,
        MIN(TotalPedido) AS Minimo,
        MAX(TotalPedido) AS Maximo,
        AVG(TotalPedido) AS Promedio
    FROM TotalesPorPedido
    GROUP BY ROLLUP (SupplierName, SupplierCategoryName)
END;
GO

EXEC sp_estadistica '', '';


