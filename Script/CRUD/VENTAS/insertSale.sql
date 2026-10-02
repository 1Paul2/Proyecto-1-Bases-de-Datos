USE WideWorldImporters;
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
        -- Harto ya de SQL
        DECLARE @BillToCustomerID INT;
        SELECT @BillToCustomerID = BillToCustomerID
        FROM Syn_Customers
        WHERE CustomerID = @CustomerID;

        IF @BillToCustomerID IS NULL
            SET @BillToCustomerID = @CustomerID;

        DECLARE @NewInvoiceID INT = NEXT VALUE FOR Sequences.InvoiceID;
        INSERT INTO Syn_Invoices (InvoiceID,CustomerID,BillToCustomerID,DeliveryMethodID,ContactPersonID,AccountsPersonID,SalespersonPersonID,PackedByPersonID,InvoiceDate,CustomerPurchaseOrderNumber,IsCreditNote,DeliveryInstructions,TotalDryItems,TotalChillerItems,LastEditedBy
        )
        VALUES (@NewInvoiceID,@CustomerID,@BillToCustomerID,@DeliveryMethodID,@ContactPersonID,@ContactPersonID,@SalespersonPersonID,@SalespersonPersonID,@InvoiceDate,@CustomerPurchaseOrderNumber,0,@DeliveryInstructions,0,0,@SalespersonPersonID
        );

        SELECT @NewInvoiceID AS NewInvoiceID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO