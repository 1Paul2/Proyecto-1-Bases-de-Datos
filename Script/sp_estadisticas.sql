USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE sp_estadistica_proveedor
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
        FROM Syn_Suppliers S
        INNER JOIN Syn_SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
        INNER JOIN Syn_PurchaseOrders PO ON PO.SupplierID = S.SupplierID
        INNER JOIN Syn_PurchaseOrderLines POL ON POL.PurchaseOrderID = PO.PurchaseOrderID
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

CREATE OR ALTER PROCEDURE sp_estadistica_cliente
    @NomCliente VARCHAR(100),
    @categoria VARCHAR(100)
