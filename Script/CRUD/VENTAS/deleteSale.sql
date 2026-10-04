use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_DeleteSale
    @InvoiceID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Syn_Invoices WHERE InvoiceID = @InvoiceID)
            THROW 50001, 'La venta indicada no existe.', 1;

        DELETE FROM Syn_InvoiceLines WHERE InvoiceID = @InvoiceID;
        DELETE FROM Syn_Invoices WHERE InvoiceID = @InvoiceID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() = 547
            THROW 50002, 'No se puede eliminar la venta porque tiene registros relacionados.', 1;
        THROW;
    END CATCH;
END;
GO