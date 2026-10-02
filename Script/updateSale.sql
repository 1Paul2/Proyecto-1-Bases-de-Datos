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
    @DeliveryInstructions NVARCHAR(500)
AS
BEGIN
    UPDATE Syn_Invoices
    SET CustomerID = @CustomerID,
        DeliveryMethodID = @DeliveryMethodID,
        CustomerPurchaseOrderNumber = @CustomerPurchaseOrderNumber,
        ContactPersonID = @ContactPersonID,
        SalespersonPersonID = @SalespersonPersonID,
        InvoiceDate = @InvoiceDate,
        DeliveryInstructions = @DeliveryInstructions
    WHERE InvoiceID = @InvoiceID;
END;
GO