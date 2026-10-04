USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE SP_UpdateStockItem
    @StockItemID INT,
    @StockItemName NVARCHAR(100),
    @SupplierID INT,
    @LeadTimeDays INT,
    @ColorID INT = NULL,
    @UnitPackageID INT,
    @OuterPackageID INT,
    @QuantityPerOuter INT,
    @Brand NVARCHAR(50) = NULL,
    @Size NVARCHAR(20) = NULL,
    @TaxRate DECIMAL(18, 2),
    @UnitPrice DECIMAL(18, 2),
    @IsChillerStock bit,
    @RecommendedRetailPrice DECIMAL(18, 2) = NULL,
    @TypicalWeightPerUnit DECIMAL(18, 2) = NULL,
    @BinLocation NVARCHAR(20) = NULL,
    @LastEditedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Syn_StockItems WHERE StockItemID = @StockItemID)
        THROW 50001, 'El producto indicado no existe.', 1;

    IF NOT EXISTS (SELECT 1 FROM Syn_Suppliers WHERE SupplierID = @SupplierID)
        THROW 50020, 'El proveedor indicado no existe.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Syn_StockItems
        SET StockItemName = @StockItemName,
            SupplierID = @SupplierID,
            LeadTimeDays = @LeadTimeDays,
            ColorID = @ColorID,
            UnitPackageID = @UnitPackageID,
            OuterPackageID = @OuterPackageID,
            QuantityPerOuter = @QuantityPerOuter,
            Brand = @Brand,
            Size = @Size,
            TaxRate = @TaxRate,
            UnitPrice = @UnitPrice,
            IsChillerStock = @IsChillerStock,
            RecommendedRetailPrice = @RecommendedRetailPrice,
            TypicalWeightPerUnit = @TypicalWeightPerUnit,
            LastEditedBy = @LastEditedBy
        WHERE StockItemID = @StockItemID;
        IF EXISTS (SELECT 1 FROM Syn_StockItemHoldings WHERE StockItemID = @StockItemID)
        BEGIN
            UPDATE Syn_StockItemHoldings
            SET BinLocation = @BinLocation,
                LastEditedBy = @LastEditedBy
            WHERE StockItemID = @StockItemID;
        END
        ELSE
        BEGIN
            INSERT INTO Syn_StockItemHoldings (StockItemID, QuantityOnHand, BinLocation, LastStocktakeQuantity, LastCostPrice, ReorderLevel, TargetStockLevel, LastEditedBy)
            VALUES (@StockItemID, 0, @BinLocation, 0, @UnitPrice, 0, 0, @LastEditedBy);
        END
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO