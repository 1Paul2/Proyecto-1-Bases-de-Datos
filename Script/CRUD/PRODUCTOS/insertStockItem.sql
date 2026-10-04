USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE SP_InsertStockItem
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

    IF NOT EXISTS (SELECT 1 FROM Syn_Suppliers WHERE SupplierID = @SupplierID)
        THROW 50020, 'El proveedor indicado no existe.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Syn_StockItems
        (
            StockItemName, SupplierID, LeadTimeDays, ColorID,
            UnitPackageID, OuterPackageID, QuantityPerOuter,
            Brand, Size, TaxRate, UnitPrice, IsChillerStock,
            RecommendedRetailPrice, TypicalWeightPerUnit,
            LastEditedBy
        )
        VALUES
        (
            @StockItemName, @SupplierID, @LeadTimeDays, @ColorID,
            @UnitPackageID, @OuterPackageID, @QuantityPerOuter,
            @Brand, @Size, @TaxRate, @UnitPrice, @IsChillerStock,
            @RecommendedRetailPrice, @TypicalWeightPerUnit,
            @LastEditedBy
        );

        DECLARE @NewStockItemID INT = SCOPE_IDENTITY();
        INSERT INTO Syn_StockItemHoldings
        (
            StockItemID, QuantityOnHand, BinLocation,
            LastStocktakeQuantity, LastCostPrice,
            ReorderLevel, TargetStockLevel, LastEditedBy
        )
        VALUES
        (
            @NewStockItemID, 0, @BinLocation,
            0, @UnitPrice,
            0, 0, @LastEditedBy
        );

        SELECT @NewStockItemID AS NewStockItemID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO