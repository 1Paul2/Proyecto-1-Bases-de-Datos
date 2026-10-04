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
    SELECT SI.StockItemID as StockItemID,
    SI.StockItemName as StockItemName,
    S.SupplierID as SupplierID,
    S.SupplierName as SupplierName,
    SI.LeadTimeDays as LeadTimeDays,
    C.ColorName as ColorName,
    SI.ColorID as ColorID,
    SI.UnitPackageID as UnitPackageID,
    SI.OuterPackageID as OuterPackageID,
    PT.PackageTypeName as UnitPackageTypeName,
    PT2.PackageTypeName as OuterPackageTypeName,
    SI.QuantityPerOuter as QuantityPerOuter,
    SI.Brand as Brand,
    SI.Size as Size,
    SI.TaxRate as TaxRate,
    SI.UnitPrice as UnitPrice,
    SI.IsChillerStock as IsChillerStock,
    SI.RecommendedRetailPrice as RecommendedRetailPrice,
    SI.TypicalWeightPerUnit as TypicalWeightPerUnit,
    SI.SearchDetails as SearchDetails,
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