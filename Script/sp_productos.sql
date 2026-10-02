use WideWorldImporters
GO

CREATE OR ALTER PROCEDURE SP_GetStockGroups
AS
BEGIN
    SELECT SG.StockGroupID as StockGroupID,
    SG.StockGroupName as StockGroupName
    FROM Syn_StockGroups SG
    ORDER BY SG.StockGroupName ASC
END;
GO

CREATE OR ALTER PROCEDURE SP_GetStockItems
    @Name NVARCHAR(100) = NULL,
    @StockGroupID INT = NULL
AS
BEGIN
    SELECT SI.StockItemID as StockItemID,
    SI.StockItemName as StockItemName,
    STRING_AGG(SG.StockGroupName, ', ') as StockGroupNames,
    SIH.QuantityOnHand as QuantityOnHand
    FROM Syn_StockItems SI

    LEFT JOIN Syn_StockItemStockGroups SIG ON SIG.StockItemID = SI.StockItemID
    LEFT JOIN Syn_StockGroups SG ON SG.StockGroupID = SIG.StockGroupID
    INNER JOIN Syn_StockItemHoldings SIH ON SIH.StockItemID = SI.StockItemID
    WHERE (@Name IS NULL OR SI.StockItemName LIKE '%' + @Name + '%')
        AND (@StockGroupID IS NULL OR SG.StockGroupID = @StockGroupID)
    GROUP BY SI.StockItemID, SI.StockItemName, SIH.QuantityOnHand
    ORDER BY SI.StockItemName ASC
END;
GO

CREATE OR ALTER PROCEDURE SP_GetStockItemDetails
    @StockItemID INT
AS
BEGIN
    SELECT SI.StockItemName as StockItemName,
    S.SupplierID as SupplierID,
    S.SupplierName as SupplierName,
    C.ColorName as ColorName,
    PT.PackageTypeName as UnitPackageTypeName,
    PT2.PackageTypeName as OuterPackageTypeName,
    SI.QuantityPerOuter as QuantityPerOuter,
    SI.Brand as Brand,
    SI.Size as Size,
    SI.TaxRate as TaxRate,
    SI.UnitPrice as UnitPrice,
    SI.RecommendedRetailPrice as RecommendedRetailPrice,
    SI.TypicalWeightPerUnit as TypicalWeightPerUnit,
    SI.SearchDetails as SearchDetail,
    SIH.QuantityOnHand as QuantityOnHand,
    SIH.BinLocation as BinLocation
    FROM Syn_StockItems SI
    INNER JOIN Syn_Suppliers S ON S.SupplierID = SI.SupplierID
    LEFT JOIN Syn_Colors C ON C.ColorID = SI.ColorID
    INNER JOIN Syn_StockItemHoldings SIH ON SIH.StockItemID = SI.StockItemID
    INNER JOIN Syn_PackageTypes PT ON PT.PackageTypeID = SI.UnitPackageID
    INNER JOIN Syn_PackageTypes PT2 ON PT2.PackageTypeID = SI.OuterPackageID

    WHERE SI.StockItemID = @StockItemID
END;
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
    INSERT INTO Syn_StockItems (StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID, QuantityPerOuter, Brand, Size, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit, SearchDetails)
    VALUES (@StockItemName, @SupplierID, @ColorID, @UnitPackageID, @OuterPackageID, @QuantityPerOuter, @Brand, @Size, @TaxRate, @UnitPrice, @RecommendedRetailPrice, @TypicalWeightPerUnit, @SearchDetails);
    SELECT SCOPE_IDENTITY() AS NewStockItemID;
END;
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

CREATE OR ALTER PROCEDURE SP_DeleteStockItem
    @StockItemID INT
AS
BEGIN
    DELETE FROM Syn_StockItems WHERE StockItemID = @StockItemID;
END;
GO

CREATE OR ALTER PROCEDURE SP_GetAllStockItems
AS
BEGIN
    SELECT SI.StockItemID as StockItemID,
        SI.StockItemName as StockItemName,
        S.SupplierName as SupplierName,
        C.ColorName as ColorName,
        PT.PackageTypeName as UnitPackageTypeName,
        PT2.PackageTypeName as OuterPackageTypeName,
        SI.QuantityPerOuter as QuantityPerOuter,
        SI.Brand as Brand,
        SI.Size as Size,
        SI.TaxRate as TaxRate,
        SI.UnitPrice as UnitPrice,
        SI.RecommendedRetailPrice as RecommendedRetailPrice,
        SI.TypicalWeightPerUnit as TypicalWeightPerUnit,
        SI.SearchDetails as SearchDetail,
        SIH.QuantityOnHand as QuantityOnHand,
        SIH.BinLocation as BinLocation
    FROM Syn_StockItems SI
    INNER JOIN Syn_Suppliers S ON S.SupplierID = SI.SupplierID
    LEFT JOIN Syn_Colors C ON C.ColorID = SI.ColorID
    INNER JOIN Syn_StockItemHoldings SIH ON SIH.StockItemID = SI.StockItemID
    INNER JOIN Syn_PackageTypes PT ON PT.PackageTypeID = SI.UnitPackageID
    INNER JOIN Syn_PackageTypes PT2 ON PT2.PackageTypeID = SI.OuterPackageID
    ORDER BY SI.StockItemName ASC
END;
GO