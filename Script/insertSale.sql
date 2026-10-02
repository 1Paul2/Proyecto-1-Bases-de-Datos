use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_InsertSale
    @CustomerID INT,
    @DeliveryMethodID INT,
    @CustomerPurchaseOrderNumber NVARCHAR(20),
    @ContactPersonID INT,
    @SalespersonPersonID INT,
    @InvoiceDate DATE,
    @DeliveryInstructions NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Syn_Invoices (CustomerID, DeliveryMethodID, CustomerPurchaseOrderNumber, ContactPersonID, SalespersonPersonID, InvoiceDate, DeliveryInstructions)
        VALUES (@CustomerID, @DeliveryMethodID, @CustomerPurchaseOrderNumber, @ContactPersonID, @SalespersonPersonID, @InvoiceDate, @DeliveryInstructions);
        SELECT SCOPE_IDENTITY() AS NewInvoiceID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO