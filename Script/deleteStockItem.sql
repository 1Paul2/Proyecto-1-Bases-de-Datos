use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_DeleteStockItem
    @StockItemID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM Syn_StockItems WHERE StockItemID = @StockItemID;

        IF @@ROWCOUNT = 0
            THROW 50001, 'El producto indicado no existe.', 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        IF ERROR_NUMBER() = 547
            THROW 50002, 'No se puede eliminar el producto porque tiene movimientos de inventario u otros registros relacionados.', 1;
        THROW;
    END CATCH;
END;
GO
