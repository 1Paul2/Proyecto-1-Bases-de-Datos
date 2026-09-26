use WideWorldImporters
GO

CREATE OR ALTER PROCEDURE SP_GetSupplierCategories
AS
BEGIN
    SELECT SC.SupplierCategoryID as SupplierCategoryID,
    SC.SupplierCategoryName as SupplierCategoryName
    from Syn_SupplierCategories SC
    ORDER BY SC.SupplierCategoryName ASC
END;
GO

CREATE OR ALTER PROCEDURE SP_GetSuppliers
    @Name NVARCHAR(100) = NULL,
    @SupplierCategoryID INT = NULL
AS
BEGIN
    SELECT S.SupplierName as SupplierName,
    SC.SupplierCategoryName as SupplierCategoryName,
    DM.DeliveryMethodName as DeliveryMethodName
    FROM Syn_Suppliers S
    INNER JOIN Syn_SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
    INNER JOIN Syn_DeliveryMethods DM ON S.DeliveryMethodID = DM.DeliveryMethodID
    WHERE (@Name IS NULL OR S.SupplierName LIKE '%' + @Name + '%')
        AND (@SupplierCategoryID IS NULL OR S.SupplierCategoryID = @SupplierCategoryID)
    ORDER BY S.SupplierName ASC
END;
GO

CREATE OR ALTER PROCEDURE SP_GetSupplierDetails
    @SupplierID INT
AS
BEGIN
    SELECT S.SupplierReference as SupplierReference,
    S.SupplierName as SupplierName,
    SC.SupplierCategoryName as SupplierCategoryName,
    P.FullName as PrimaryContactName,
    P2.FullName as AlternateContactName,
    DM.DeliveryMethodName as DeliveryMethodName,
    C.CityName as DeliveryCityName,
    S.DeliveryPostalCode as DeliveryPostalCode,
    S.PhoneNumber as PhoneNumber,
    S.FaxNumber as FaxNumber,
    S.WebsiteURL as WebsiteURL,
    S.DeliveryAddressLine1 as DeliveryAddressLine1,
    S.DeliveryAddressLine2 as DeliveryAddressLine2,
    S.PostalAddressLine1 as PostalAddressLine1,
    S.PostalAddressLine2 as PostalAddressLine2,
    S.DeliveryLocation.Lat as DeliveryLatitude,
    S.DeliveryLocation.Long as DeliveryLongitude,
    S.BankAccountName as BankAccountName,
    S.BankAccountNumber as BankAccountNumber,
    S.PaymentDays as PaymentDays
    FROM Syn_Suppliers S
    INNER JOIN Syn_SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
    INNER JOIN Syn_DeliveryMethods DM ON S.DeliveryMethodID = DM.DeliveryMethodID
    INNER JOIN Syn_People P ON P.PersonID = S.PrimaryContactPersonID
    LEFT JOIN Syn_People P2 ON P2.PersonID = S.AlternateContactPersonID
    LEFT JOIN Syn_Cities C ON C.CityID = S.DeliveryCityID

    WHERE S.SupplierID = @SupplierID
END;
GO