use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_UpdateSale
    @InvoiceID INT,
    @CustomerID INT,
    @DeliveryMethodID INT,
    @CustomerPurchaseOrderNumber NVARCHAR(20),
    @ContactPersonID INT,
    @SalespersonPersonID INT,
    @InvoiceDate DATE,
    @DeliveryInstructions NVARCHAR(500),
    @BillToCustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE InvoiceID = @InvoiceID)
            THROW 50001, 'La venta indicada no existe.', 1;

        UPDATE Syn_Invoices
        SET CustomerID = @CustomerID,
        DeliveryMethodID = @DeliveryMethodID,
        CustomerPurchaseOrderNumber = @CustomerPurchaseOrderNumber,
        ContactPersonID = @ContactPersonID,
        SalespersonPersonID = @SalespersonPersonID,
        InvoiceDate = @InvoiceDate,
        DeliveryInstructions = @DeliveryInstructions,
        BillToCustomerID = @BillToCustomerID
        WHERE InvoiceID = @InvoiceID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO