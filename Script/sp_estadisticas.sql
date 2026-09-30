USE WideWorldImporters;
GO
 -- #1
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


 -- #2

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
 

 -- #4

CREATE OR ALTER PROCEDURE sp_top5_clientes_facturas
    @anioInicio INT = NULL,  
    @anioFin INT = NULL    
AS
BEGIN
    SET NOCOUNT ON;

    -- Si no se indican, se usa el rango completo de la base
    IF @anioInicio IS NULL SELECT @anioInicio = MIN(YEAR(InvoiceDate)) FROM Syn_Invoices;
    IF @anioFin IS NULL SELECT @anioFin    = MAX(YEAR(InvoiceDate)) FROM Syn_Invoices;

    -- Validar que los años existan en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE YEAR(InvoiceDate) = @anioInicio)
        THROW 50001, 'El año de inicio no existe en la base de datos.', 1;

    IF NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE YEAR(InvoiceDate) = @anioFin)
        THROW 50002, 'El año final no existe en la base de datos.', 1;

    IF @anioInicio > @anioFin
        THROW 50003, 'El año de inicio no puede ser mayor que el año final.', 1;

    WITH TotalPorFactura AS (
        SELECT
            I.InvoiceID,
            I.CustomerID,
            YEAR(I.InvoiceDate) AS Anio,
            SUM(IL.ExtendedPrice) AS TotalFactura
        FROM Syn_Invoices I
        INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
        WHERE YEAR(I.InvoiceDate) BETWEEN @anioInicio AND @anioFin
        GROUP BY I.InvoiceID, I.CustomerID, YEAR(I.InvoiceDate)
    ),
    FacturasPorCliente AS (
        SELECT
            T.Anio,
            C.CustomerID,
            C.CustomerName,
            COUNT(*)            AS CantidadFacturas,
            SUM(T.TotalFactura) AS MontoTotal
        FROM TotalPorFactura T
        INNER JOIN Syn_Customers C ON C.CustomerID = T.CustomerID
        GROUP BY T.Anio, C.CustomerID, C.CustomerName
    ),
    Ranking AS (
        SELECT
            Anio,
            CustomerName,
            CantidadFacturas,
            MontoTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY CantidadFacturas DESC) AS Posicion
        FROM FacturasPorCliente
    )
    SELECT
        Anio,
        Posicion,
        CustomerName AS Cliente,
        CantidadFacturas,
        MontoTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion, CustomerName;
END;
GO


 -- #5


CREATE OR ALTER PROCEDURE sp_top5_proveedores_ordenes
    @anioInicio INT = NULL,  
    @anioFin INT = NULL   
AS
BEGIN
    SET NOCOUNT ON;

    -- Si no se indican, se usa el rango completo de la base
    IF @anioInicio IS NULL SELECT @anioInicio = MIN(YEAR(OrderDate)) FROM Syn_PurchaseOrders;
    IF @anioFin    IS NULL SELECT @anioFin    = MAX(YEAR(OrderDate)) FROM Syn_PurchaseOrders;

    -- Validar que los años existan en la base de datos
    IF NOT EXISTS (SELECT 1 FROM Syn_PurchaseOrders WHERE YEAR(OrderDate) = @anioInicio)
        THROW 50001, 'El año de inicio no existe en la base de datos.', 1;

    IF NOT EXISTS (SELECT 1 FROM Syn_PurchaseOrders WHERE YEAR(OrderDate) = @anioFin)
        THROW 50002, 'El año final no existe en la base de datos.', 1;

    IF @anioInicio > @anioFin
        THROW 50003, 'El año de inicio no puede ser mayor que el año final.', 1;

    WITH TotalPorOrden AS (
        SELECT
            PO.PurchaseOrderID,
            PO.SupplierID,
            YEAR(PO.OrderDate) AS Anio,
            SUM(POL.OrderedOuters * POL.ExpectedUnitPricePerOuter) AS TotalOrden
        FROM Syn_PurchaseOrders PO
        INNER JOIN Syn_PurchaseOrderLines POL ON POL.PurchaseOrderID = PO.PurchaseOrderID
        WHERE YEAR(PO.OrderDate) BETWEEN @anioInicio AND @anioFin
        GROUP BY PO.PurchaseOrderID, PO.SupplierID, YEAR(PO.OrderDate)
    ),
    OrdenesPorProveedor AS (
        SELECT
            T.Anio,
            S.SupplierID,
            S.SupplierName,
            COUNT(*) AS CantidadOrdenes,
            SUM(T.TotalOrden) AS MontoTotal
        FROM TotalPorOrden T
        INNER JOIN Syn_Suppliers S ON S.SupplierID = T.SupplierID
        GROUP BY T.Anio, S.SupplierID, S.SupplierName
    ),
    Ranking AS (
        SELECT
            Anio,
            SupplierName,
            CantidadOrdenes,
            MontoTotal,
            DENSE_RANK() OVER (PARTITION BY Anio ORDER BY CantidadOrdenes DESC) AS Posicion
        FROM OrdenesPorProveedor
    )
    SELECT
        Anio,
        Posicion,
        SupplierName AS Proveedor,
        CantidadOrdenes,
        MontoTotal
    FROM Ranking
    WHERE Posicion <= 5
    ORDER BY Anio, Posicion, SupplierName;
END;
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
            INNER JOIN Syn_StockItemStockGroups SIG ON SIG.StockItemID = IL.StockItemID
            INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
        ) Origen
        PIVOT (
            SUM(Monto) FOR Anio IN (' + @cols + N')
        ) AS Matriz
        ORDER BY Categoria;';


END;
GO

EXEC sp_matriz_ventas_categoria_anio;

 -- #7

 CREATE OR ALTER PROCEDURE sp_seguimiento_compras_cliente
    @anio INT = NULL,
    @mes INT = NULL,
    @categoria VARCHAR(100) = NULL, 
    @subcategoria VARCHAR(100) = NULL    
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @anio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE YEAR(InvoiceDate) = @anio)
        THROW 50001, 'El año indicado no existe en la base de datos.', 1;

    IF @mes IS NOT NULL AND @mes NOT BETWEEN 1 AND 12
        THROW 50002, 'El mes debe estar entre 1 y 12.', 1;

    WITH Lineas AS (
        SELECT
            I.CustomerID,
            I.InvoiceID,
            I.InvoiceDate,
            YEAR(I.InvoiceDate)  AS Anio,
            MONTH(I.InvoiceDate) AS Mes,
            IL.Quantity,
            IL.ExtendedPrice
        FROM Syn_Invoices I
        INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
        WHERE (@anio IS NULL OR YEAR(I.InvoiceDate)  = @anio)
          AND (@mes  IS NULL OR MONTH(I.InvoiceDate) = @mes)
          AND (@categoria IS NULL OR EXISTS (
                SELECT 1
                FROM Syn_StockItemStockGroups SIG
                INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
                WHERE SIG.StockItemID = IL.StockItemID
                  AND SG.StockGroupName LIKE '%' + @categoria + '%'))
          AND (@subcategoria IS NULL OR EXISTS (
                SELECT 1
                FROM Syn_StockItems SI
                INNER JOIN Syn_PackageTypes PT ON PT.PackageTypeID = SI.UnitPackageID
                WHERE SI.StockItemID = IL.StockItemID
                  AND PT.PackageTypeName LIKE '%' + @subcategoria + '%'))
    ),
    Resumen AS (
        SELECT
            CustomerID, Anio, Mes,
            COUNT(DISTINCT InvoiceID) AS CantidadFacturas,
            SUM(ExtendedPrice) AS MontoTotal,
            SUM(Quantity) AS CantidadTotal,
            MIN(Quantity) AS CantidadMinima,
            MAX(Quantity) AS CantidadMaxima
        FROM Lineas
        GROUP BY CustomerID, Anio, Mes
    ),
    Facturas AS (
        SELECT
            CustomerID, Anio, Mes, InvoiceID, InvoiceDate,
            ROW_NUMBER() OVER (PARTITION BY CustomerID, Anio, Mes
                               ORDER BY InvoiceDate ASC,  InvoiceID ASC)  AS RnPrimera,
            ROW_NUMBER() OVER (PARTITION BY CustomerID, Anio, Mes
                               ORDER BY InvoiceDate DESC, InvoiceID DESC) AS RnUltima
        FROM (SELECT DISTINCT CustomerID, Anio, Mes, InvoiceID, InvoiceDate FROM Lineas) F
    )
    SELECT
        C.CustomerName AS Cliente,
        R.Anio,
        R.Mes,
        R.CantidadFacturas,
        R.MontoTotal,
        P.InvoiceID AS PrimeraFactura,
        P.InvoiceDate AS FechaPrimera,
        U.InvoiceID AS UltimaFactura,
        U.InvoiceDate AS FechaUltima,
        R.CantidadTotal,
        R.CantidadMinima,
        R.CantidadMaxima
    FROM Resumen R
    INNER JOIN Syn_Customers C ON C.CustomerID = R.CustomerID
    INNER JOIN Facturas P ON P.CustomerID = R.CustomerID AND P.Anio = R.Anio
                         AND P.Mes = R.Mes AND P.RnPrimera = 1
    INNER JOIN Facturas U ON U.CustomerID = R.CustomerID AND U.Anio = R.Anio
                         AND U.Mes = R.Mes AND U.RnUltima = 1
    ORDER BY C.CustomerName, R.Anio, R.Mes;
END;
GO

-- #8

CREATE OR ALTER PROCEDURE sp_seguimiento_compras_proveedor
    @anio INT = NULL,
    @mes INT = NULL,
    @categoria VARCHAR(100) = NULL,   
    @subcategoria VARCHAR(100) = NULL    
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @anio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Syn_PurchaseOrders WHERE YEAR(OrderDate) = @anio)
        THROW 50001, 'El año indicado no existe en la base de datos.', 1;

    IF @mes IS NOT NULL AND @mes NOT BETWEEN 1 AND 12
        THROW 50002, 'El mes debe estar entre 1 y 12.', 1;

    WITH Lineas AS (
        SELECT
            PO.SupplierID,
            PO.PurchaseOrderID,
            PO.OrderDate,
            YEAR(PO.OrderDate) AS Anio,
            MONTH(PO.OrderDate) AS Mes,
            POL.OrderedOuters,
            POL.OrderedOuters * POL.ExpectedUnitPricePerOuter AS Monto
        FROM Syn_PurchaseOrders PO
        INNER JOIN Syn_PurchaseOrderLines POL ON POL.PurchaseOrderID = PO.PurchaseOrderID
        WHERE (@anio IS NULL OR YEAR(PO.OrderDate)  = @anio)
          AND (@mes  IS NULL OR MONTH(PO.OrderDate) = @mes)
          AND (@categoria IS NULL OR EXISTS (
                SELECT 1
                FROM Syn_StockItemStockGroups SIG
                INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
                WHERE SIG.StockItemID = POL.StockItemID
                  AND SG.StockGroupName LIKE '%' + @categoria + '%'))
          AND (@subcategoria IS NULL OR EXISTS (
                SELECT 1
                FROM Syn_StockItems SI
                INNER JOIN Syn_PackageTypes PT ON PT.PackageTypeID = SI.UnitPackageID
                WHERE SI.StockItemID = POL.StockItemID
                  AND PT.PackageTypeName LIKE '%' + @subcategoria + '%'))
    ),
    Resumen AS (
        SELECT
            SupplierID, Anio, Mes,
            COUNT(DISTINCT PurchaseOrderID) AS CantidadOrdenes,
            SUM(Monto) AS MontoTotal,
            SUM(OrderedOuters) AS CantidadTotal,
            MIN(OrderedOuters) AS CantidadMinima,
            MAX(OrderedOuters) AS CantidadMaxima
        FROM Lineas
        GROUP BY SupplierID, Anio, Mes
    ),
    Ordenes AS (
        SELECT
            SupplierID, Anio, Mes, PurchaseOrderID, OrderDate,
            ROW_NUMBER() OVER (PARTITION BY SupplierID, Anio, Mes
                               ORDER BY OrderDate ASC,  PurchaseOrderID ASC)  AS RnPrimera,
            ROW_NUMBER() OVER (PARTITION BY SupplierID, Anio, Mes
                               ORDER BY OrderDate DESC, PurchaseOrderID DESC) AS RnUltima
        FROM (SELECT DISTINCT SupplierID, Anio, Mes, PurchaseOrderID, OrderDate FROM Lineas) O
    )
    SELECT
        S.SupplierName AS Proveedor,
        R.Anio,
        R.Mes,
        R.CantidadOrdenes,
        R.MontoTotal,
        P.PurchaseOrderID AS PrimeraOrden,
        P.OrderDate AS FechaPrimera,
        U.PurchaseOrderID AS UltimaOrden,
        U.OrderDate AS FechaUltima,
        R.CantidadTotal,
        R.CantidadMinima,
        R.CantidadMaxima
    FROM Resumen R
    INNER JOIN Syn_Suppliers S ON S.SupplierID = R.SupplierID
    INNER JOIN Ordenes P ON P.SupplierID = R.SupplierID AND P.Anio = R.Anio
                        AND P.Mes = R.Mes AND P.RnPrimera = 1
    INNER JOIN Ordenes U ON U.SupplierID = R.SupplierID AND U.Anio = R.Anio
                        AND U.Mes = R.Mes AND U.RnUltima = 1
    ORDER BY S.SupplierName, R.Anio, R.Mes;
END;
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
-- #10 

CREATE OR ALTER PROCEDURE sp_metodo_envio_favorito
    @anio INT = NULL,
    @mes INT = NULL,
    @catCliente VARCHAR(100) = NULL,   
    @catProducto VARCHAR(100) = NULL,  
    @producto VARCHAR(100) = NULL,  
    @soloFavorito BIT = 1     
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones
    IF @anio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE YEAR(InvoiceDate) = @anio)
        THROW 50001, 'El año indicado no existe en la base de datos.', 1;

    IF @mes IS NOT NULL AND @mes NOT BETWEEN 1 AND 12
        THROW 50002, 'El mes debe estar entre 1 y 12.', 1;

    WITH Ventas AS (
        SELECT
            I.InvoiceID,
            I.DeliveryMethodID,
            C.DeliveryCityID
        FROM Syn_Invoices I
        INNER JOIN Syn_Customers C          ON C.CustomerID = I.CustomerID
        INNER JOIN Syn_CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
        WHERE (@anio IS NULL OR YEAR(I.InvoiceDate)  = @anio)
          AND (@mes  IS NULL OR MONTH(I.InvoiceDate) = @mes)
          AND (@catCliente IS NULL OR CC.CustomerCategoryName LIKE '%' + @catCliente + '%')
          AND ((@catProducto IS NULL AND @producto IS NULL) OR EXISTS (
                SELECT 1
                FROM Syn_InvoiceLines IL
                INNER JOIN Syn_StockItems SI ON SI.StockItemID = IL.StockItemID
                WHERE IL.InvoiceID = I.InvoiceID
                  AND (@producto IS NULL OR SI.StockItemName LIKE '%' + @producto + '%')
                  AND (@catProducto IS NULL OR EXISTS (
                        SELECT 1
                        FROM Syn_StockItemStockGroups SIG
                        INNER JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
                        WHERE SIG.StockItemID = SI.StockItemID
                          AND SG.StockGroupName LIKE '%' + @catProducto + '%'))))
    ),
    Conteo AS (
        SELECT
            DeliveryCityID,
            DeliveryMethodID,
            COUNT(*) AS CantidadVentas
        FROM Ventas
        GROUP BY DeliveryCityID, DeliveryMethodID
    ),
    Ranking AS (
        SELECT
            DeliveryCityID,
            DeliveryMethodID,
            CantidadVentas,
            SUM(CantidadVentas) OVER (PARTITION BY DeliveryCityID) AS TotalVentasLugar,
            DENSE_RANK() OVER (PARTITION BY DeliveryCityID
                               ORDER BY CantidadVentas DESC) AS Posicion
        FROM Conteo
    )
    SELECT
        SP.StateProvinceName AS Provincia,
        CI.CityName AS Ciudad,
        DM.DeliveryMethodName AS MetodoEnvio,
        R.CantidadVentas,
        R.TotalVentasLugar,
        R.Posicion
    FROM Ranking R
    INNER JOIN Syn_Cities CI ON CI.CityID = R.DeliveryCityID
    INNER JOIN Syn_StateProvinces SP ON SP.StateProvinceID = CI.StateProvinceID
    INNER JOIN Syn_DeliveryMethods DM ON DM.DeliveryMethodID = R.DeliveryMethodID
    WHERE @soloFavorito = 0 OR R.Posicion = 1
    ORDER BY R.CantidadVentas DESC, SP.StateProvinceName, CI.CityName, R.Posicion;
END;
GO



