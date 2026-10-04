USE WideWorldImporters;
GO

 -- #6

CREATE OR ALTER PROCEDURE sp_matriz_ventas_categoria_anio
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cols NVARCHAR(MAX);  
    DECLARE @colsSelect NVARCHAR(MAX);  
    DECLARE @sql NVARCHAR(MAX);

    -- Años en los que realmente hubo ventas
    SELECT @cols = STUFF((
        SELECT ',' + QUOTENAME(CAST(Anio AS VARCHAR(4)))
        FROM (SELECT DISTINCT YEAR(InvoiceDate) AS Anio FROM Syn_Invoices) A
        ORDER BY Anio
        FOR XML PATH('')), 1, 1, '');

    SELECT @colsSelect = STUFF((
        SELECT ',ISNULL(' + QUOTENAME(CAST(Anio AS VARCHAR(4))) + ', 0) AS '
               + QUOTENAME(CAST(Anio AS VARCHAR(4)))
        FROM (SELECT DISTINCT YEAR(InvoiceDate) AS Anio FROM Syn_Invoices) A
        ORDER BY Anio
        FOR XML PATH('')), 1, 1, '');

    SET @sql = N'
        SELECT Categoria, ' + @colsSelect + N'
        FROM (
            SELECT
                SG.StockGroupName   AS Categoria,
                YEAR(I.InvoiceDate) AS Anio,
                IL.ExtendedPrice    AS Monto
            FROM Syn_Invoices I
            INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
            INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = (
                SELECT MIN(SIG.StokGroupID)
                FROM Syn_StockGroups SIG
                WHERE SIG.StockGroupID = IL.StockGroupID
            )
        ) Origen
        PIVOT (
            SUM(Monto) FOR Anio IN (' + @cols + N')
        ) AS Matriz
        ORDER BY Categoria;';

    EXEC sp_executesql @sql;
END;
GO

EXEC sp_matriz_ventas_categoria_anio;