use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_UpdateStockItem
    @StockItemID INT,
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
    UPDATE Syn_StockItems
    SET StockItemName = @StockItemName,
        SupplierID = @SupplierID,
        ColorID = @ColorID,
        UnitPackageID = @UnitPackageID,
        OuterPackageID = @OuterPackageID,
        QuantityPerOuter = @QuantityPerOuter,
        Brand = @Brand,
        Size = @Size,
        TaxRate = @TaxRate,
        UnitPrice = @UnitPrice,
        RecommendedRetailPrice = @RecommendedRetailPrice,
        TypicalWeightPerUnit = @TypicalWeightPerUnit,
        SearchDetails = @SearchDetails
    WHERE StockItemID = @StockItemID;
END;
GO