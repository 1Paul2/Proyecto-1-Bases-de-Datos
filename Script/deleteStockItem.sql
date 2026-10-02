use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_DeleteStockItem
    @StockItemID INT
AS
BEGIN
    DELETE FROM Syn_StockItems WHERE StockItemID = @StockItemID;
END;
GO
