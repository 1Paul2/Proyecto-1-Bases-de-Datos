use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_DeleteSale
    @InvoiceID INT
AS
BEGIN
    DELETE FROM Syn_InvoiceLines WHERE InvoiceID = @InvoiceID;
    DELETE FROM Syn_Invoices WHERE InvoiceID = @InvoiceID;
END;
GO