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
AS
BEGIN
    SET NOCOUNT ON;

    WITH TotalesPorFactura AS (
        SELECT
            C.CustomerName,
            CC.CustomerCategoryName,
            I.InvoiceID,
            SUM(IL.Quantity * IL.UnitPrice) AS TotalFactura
        FROM Syn_Customers C
        INNER JOIN Syn_CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
        INNER JOIN Syn_Invoices I ON I.CustomerID = C.CustomerID
        INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
        WHERE C.CustomerName LIKE '%' + @NomCliente + '%'
          AND CC.CustomerCategoryName LIKE '%' + @categoria + '%'
        GROUP BY C.CustomerName, CC.CustomerCategoryName, I.InvoiceID
    )
    SELECT
        CustomerName AS Cliente,
        CustomerCategoryName AS Categoria,
        MIN(TotalFactura) AS Minimo,
        MAX(TotalFactura) AS Maximo,
        AVG(TotalFactura) AS Promedio
    FROM TotalesPorFactura
    GROUP BY ROLLUP (CustomerName, CustomerCategoryName);
END;
GO

EXEC sp_estadistica_cliente '', '';

CREATE OR ALTER PROCEDURE sp_top5_productos_ganancia
    @anio INT = NULL   
AS
BEGIN
    SET NOCOUNT ON;

    IF @anio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE YEAR(InvoiceDate) = @anio)
    BEGIN
        THROW 50001, 'El año indicado no existe en la base de datos.', 1;
    END;

    WITH GananciaPorProducto AS (
        SELECT
            YEAR(I.InvoiceDate) AS Anio,
            SI.StockItemID,
            SI.StockItemName,
            SUM(IL.LineProfit) AS Ganancia
        FROM Syn_Invoices I
        INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
        INNER JOIN Syn_StockItems SI ON SI.StockItemID = IL.StockItemID
        WHERE @anio IS NULL OR YEAR(I.InvoiceDate) = @anio
        GROUP BY YEAR(I.InvoiceDate), SI.StockItemID, SI.StockItemName
    ),
    Ranking AS (
        SELECT
            Anio,
            StockItemName,
            Ganancia,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY Ganancia DESC) AS Posicion
        FROM GananciaPorProducto
    )
    SELECT
        Anio,
        Posicion,
        StockItemName AS Producto,
        Ganancia
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion;
END;
GO

EXEC sp_top5_productos_ganancia;       
EXEC sp_top5_productos_ganancia 2015;   
