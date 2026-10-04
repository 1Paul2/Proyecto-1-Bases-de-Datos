USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE SP_InsertSale
    @CustomerID                   INT,
    @DeliveryMethodID             INT,
    @CustomerPurchaseOrderNumber  NVARCHAR(20),
    @ContactPersonID              INT,
    @SalespersonPersonID          INT,
    @InvoiceDate                  DATE,
    @DeliveryInstructions         NVARCHAR(500),
    @Lines                     NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Validaciones
    IF NOT EXISTS (SELECT 1 FROM Syn_Customers WHERE CustomerID = @CustomerID)
        THROW 50010, 'El cliente indicado no existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM Syn_DeliveryMethods WHERE DeliveryMethodID = @DeliveryMethodID)
        THROW 50011, 'El método de entrega indicado no existe.', 1;

    IF @Lines IS NULL OR LTRIM(RTRIM(@Lines)) = ''
        THROW 50012, 'Debe incluir al menos una línea de factura.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- PARSER
        ;WITH Filas AS (
            SELECT LTRIM(RTRIM(value)) AS Fila
            FROM STRING_SPLIT(@Lines, ';')
            WHERE LTRIM(RTRIM(value)) <> ''
        ),
        Campos AS (
            SELECT
                F.Fila,
                ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Rn,
                LTRIM(RTRIM(P1.value)) AS StockItemID,
                LTRIM(RTRIM(P2.value)) AS Quantity,
                LTRIM(RTRIM(P3.value)) AS UnitPrice,
                LTRIM(RTRIM(P4.value)) AS TaxRate,
                LTRIM(RTRIM(P5.value)) AS Description
            FROM Filas F
            CROSS APPLY (SELECT value FROM STRING_SPLIT(F.Fila, '|') ORDER BY (SELECT NULL) OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) P1
            CROSS APPLY (SELECT value FROM STRING_SPLIT(F.Fila, '|') ORDER BY (SELECT NULL) OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY) P2
            CROSS APPLY (SELECT value FROM STRING_SPLIT(F.Fila, '|') ORDER BY (SELECT NULL) OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY) P3
            CROSS APPLY (SELECT value FROM STRING_SPLIT(F.Fila, '|') ORDER BY (SELECT NULL) OFFSET 3 ROWS FETCH NEXT 1 ROWS ONLY) P4
            CROSS APPLY (SELECT value FROM STRING_SPLIT(F.Fila, '|') ORDER BY (SELECT NULL) OFFSET 4 ROWS FETCH NEXT 1 ROWS ONLY) P5
        )
        SELECT
            CAST(StockItemID AS INT)          AS StockItemID,
            CAST(Quantity    AS INT)          AS Quantity,
            CAST(UnitPrice   AS DECIMAL(18,2)) AS UnitPrice,
            CAST(TaxRate     AS DECIMAL(18,3)) AS TaxRate,
            Description
        INTO #Lineas
        FROM Campos;

        IF EXISTS (
            SELECT 1 FROM #Lineas L
            WHERE NOT EXISTS (SELECT 1 FROM Syn_StockItems SI WHERE SI.StockItemID = L.StockItemID)
        )
            THROW 50013, 'Una o más líneas referencian un producto inexistente.', 1;

        DECLARE @BillToCustomerID INT;
        SELECT @BillToCustomerID = BillToCustomerID
        FROM Syn_Customers
        WHERE CustomerID = @CustomerID;

        IF @BillToCustomerID IS NULL
            SET @BillToCustomerID = @CustomerID;

        DECLARE @NewInvoiceID INT = NEXT VALUE FOR Sequences.InvoiceID;
        INSERT INTO Syn_Invoices
        (
            InvoiceID, CustomerID, BillToCustomerID, DeliveryMethodID,
            ContactPersonID, AccountsPersonID, SalespersonPersonID, PackedByPersonID,
            InvoiceDate, CustomerPurchaseOrderNumber, IsCreditNote,
            DeliveryInstructions, TotalDryItems, TotalChillerItems, LastEditedBy
        )
        VALUES
        (
            @NewInvoiceID, @CustomerID, @BillToCustomerID, @DeliveryMethodID,
            @ContactPersonID, @ContactPersonID, @SalespersonPersonID, @SalespersonPersonID,
            @InvoiceDate, @CustomerPurchaseOrderNumber, 0,
            @DeliveryInstructions, 0, 0, @SalespersonPersonID
        );
        DECLARE @NewLineID INT = NEXT VALUE FOR Sequences.InvoiceLineID;

        INSERT INTO Syn_InvoiceLines
        (
            InvoiceLineID, InvoiceID, StockItemID, Description,
            PackageTypeID, Quantity, UnitPrice, TaxRate, TaxAmount,
            LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen
        )
        SELECT
            @NewLineID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1,
            @NewInvoiceID,
            L.StockItemID,
            ISNULL(NULLIF(L.Description, ''), SI.StockItemName),
            SI.UnitPackageID,
            L.Quantity,
            L.UnitPrice,
            L.TaxRate,
            CAST(L.Quantity * L.UnitPrice * L.TaxRate / 100.0 AS DECIMAL(18,2)),
            CAST(L.Quantity * (L.UnitPrice - ISNULL(SI.RecommendedRetailPrice, 0)) AS DECIMAL(18,2)),
            CAST(L.Quantity * L.UnitPrice AS DECIMAL(18,2)),
            @SalespersonPersonID,
            SYSDATETIME()
        FROM #Lineas L
        INNER JOIN Syn_StockItems SI ON SI.StockItemID = L.StockItemID;

        DROP TABLE #Lineas;

        SELECT @NewInvoiceID AS NewInvoiceID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF OBJECT_ID('tempdb..#Lineas') IS NOT NULL DROP TABLE #Lineas;
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO