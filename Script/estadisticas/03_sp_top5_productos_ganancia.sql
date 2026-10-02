USE WideWorldImporters;
GO

 -- #3

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