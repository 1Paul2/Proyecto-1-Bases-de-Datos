use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_InsertStockItem
    @StockItemName NVARCHAR(100),
    @SupplierID INT,
    @ColorID INT = NULL,
    @UnitPackageID INT,
    @OuterPackageID INT,
    @QuantityPerOuter INT,
    @Brand NVARCHAR(50) = NULL,
    @Size NVARCHAR(20) = NULL,
    @TaxRate DECIMAL(18, 2),
    @UnitPrice DECIMAL(18, 2),
    @RecommendedRetailPrice DECIMAL(18, 2) = NULL,
    @TypicalWeightPerUnit DECIMAL(18, 2) = NULL,
    @SearchDetails NVARCHAR(MAX) = NULL,
    @BinLocation NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Syn_StockItems (StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID, QuantityPerOuter, Brand, Size, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit)
        VALUES (@StockItemName, @SupplierID, @ColorID, @UnitPackageID, @OuterPackageID, @QuantityPerOuter, @Brand, @Size, @TaxRate, @UnitPrice, @RecommendedRetailPrice, @TypicalWeightPerUnit);
        SELECT SCOPE_IDENTITY() AS NewStockItemID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO