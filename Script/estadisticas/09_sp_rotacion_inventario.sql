USE WideWorldImporters;
GO

-- #9 

DROP SYNONYM IF EXISTS Syn_StockItemTransactions;
CREATE SYNONYM Syn_StockItemTransactions FOR Warehouse.StockItemTransactions;
GO

CREATE OR ALTER PROCEDURE sp_rotacion_inventario
    @anio      INT          = NULL,
    @categoria VARCHAR(100) = NULL,  
    @proveedor VARCHAR(100) = NULL    
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el año exista en los movimientos de inventario
    IF @anio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Syn_StockItemTransactions
                       WHERE YEAR(TransactionOccurredWhen) = @anio)
        THROW 50001, 'El año indicado no existe en la base de datos.', 1;

    -- Última fecha con datos
    DECLARE @ultima DATE;
    SELECT @ultima = MAX(CAST(TransactionOccurredWhen AS DATE))
    FROM Syn_StockItemTransactions;

    WITH Productos AS (
        SELECT SI.StockItemID, SI.StockItemName, S.SupplierName
        FROM Syn_StockItems SI
        INNER JOIN Syn_Suppliers S ON S.SupplierID = SI.SupplierID
        WHERE (@proveedor IS NULL OR S.SupplierName LIKE '%' + @proveedor + '%')
          AND (@categoria IS NULL OR EXISTS (
                SELECT 1
                FROM Syn_StockItemStockGroups SIG
                INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
                WHERE SIG.StockItemID = SI.StockItemID
                  AND SG.StockGroupName LIKE '%' + @categoria + '%'))
    ),
    MovimientosAnio AS (
        SELECT
            T.StockItemID,
            YEAR(T.TransactionOccurredWhen) AS Anio,
            SUM(T.Quantity) AS MovimientoNeto,
            SUM(CASE WHEN T.CustomerID IS NOT NULL AND T.Quantity < 0
                     THEN -T.Quantity ELSE 0 END) AS UnidadesVendidas
        FROM Syn_StockItemTransactions T
        INNER JOIN Productos P ON P.StockItemID = T.StockItemID
        GROUP BY T.StockItemID, YEAR(T.TransactionOccurredWhen)
    ),
    Inventario AS (
        SELECT
            StockItemID, Anio, UnidadesVendidas,
            -- inventario al cierre del año = suma acumulada de movimientos
            SUM(MovimientoNeto) OVER (PARTITION BY StockItemID ORDER BY Anio
                                      ROWS UNBOUNDED PRECEDING) AS InventarioFinal,
            SUM(MovimientoNeto) OVER (PARTITION BY StockItemID ORDER BY Anio
                                      ROWS UNBOUNDED PRECEDING) - MovimientoNeto AS InventarioInicial
        FROM MovimientosAnio
    ),
    Calculo AS (
        SELECT
            I.StockItemID, I.Anio, I.UnidadesVendidas,
            I.InventarioInicial, I.InventarioFinal,
            (I.InventarioInicial + I.InventarioFinal) / 2.0 AS InventarioPromedio,
            DATEDIFF(DAY, DATEFROMPARTS(I.Anio, 1, 1),
                     CASE WHEN DATEFROMPARTS(I.Anio, 12, 31) > @ultima
                          THEN @ultima ELSE DATEFROMPARTS(I.Anio, 12, 31) END) + 1 AS DiasPeriodo
        FROM Inventario I
        WHERE @anio IS NULL OR I.Anio = @anio    -- el filtro va después de los acumulados
    )
    SELECT
        P.StockItemName AS Producto,
        P.SupplierName  AS Proveedor,
        C.Anio,
        C.InventarioInicial,
        C.InventarioFinal,
        CAST(C.InventarioPromedio AS DECIMAL(18,2)) AS InventarioPromedio,
        C.UnidadesVendidas,
        CAST(C.UnidadesVendidas / NULLIF(C.InventarioPromedio, 0) AS DECIMAL(18,2)) AS Rotacion,
        CAST(C.DiasPeriodo * C.InventarioPromedio
             / NULLIF(C.UnidadesVendidas, 0) AS DECIMAL(18,2)) AS DiasRotacion
    FROM Calculo C
    INNER JOIN Productos P ON P.StockItemID = C.StockItemID
    ORDER BY P.StockItemName, C.Anio;
END;
GO
