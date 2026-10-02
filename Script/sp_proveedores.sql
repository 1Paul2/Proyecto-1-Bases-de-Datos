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
    SELECT S.SupplierID as SupplierID,
    S.SupplierName as SupplierName,
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
    S.BankAccountBranch as BankAccountBranch,
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

CREATE OR ALTER PROCEDURE SP_InsertSupplier
    @SupplierReference NVARCHAR(20),
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT = NULL,
    @DeliveryMethodID INT,
    @DeliveryCityID INT,
    @DeliveryPostalCode NVARCHAR(10),
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20) = NULL,
    @WebsiteURL NVARCHAR(255) = NULL,
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @PostalAddressLine1 NVARCHAR(60),
    @PostalAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL,
    @BankAccountBranch NVARCHAR(20),
    @BankAccountName NVARCHAR(100),
    @BankAccountNumber NVARCHAR(20),
    @PaymentDays INT
AS
BEGIN
    INSERT INTO Syn_Suppliers (
        SupplierReference,
        SupplierName,
        SupplierCategoryID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        DeliveryPostalCode,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        PostalAddressLine1,
        PostalAddressLine2,
        DeliveryLocation,
        BankAccountBranch,
        BankAccountName,
        BankAccountNumber,
        PaymentDays
    )
    VALUES (
        @SupplierReference,
        @SupplierName,
        @SupplierCategoryID,
        @PrimaryContactPersonID,
        @AlternateContactPersonID,
        @DeliveryMethodID,
        @DeliveryCityID,
        @DeliveryPostalCode,
        @PhoneNumber,
        @FaxNumber,
        @WebsiteURL,
        @DeliveryAddressLine1,
        @DeliveryAddressLine2,
        @PostalAddressLine1,
        @PostalAddressLine2,
        GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326),
        @BankAccountBranch,
        @BankAccountName,
        @BankAccountNumber,
        @PaymentDays
    );
    SELECT SCOPE_IDENTITY() AS NewSupplierID;
END;
GO

CREATE OR ALTER PROCEDURE SP_UpdateSupplier
    @SupplierID INT,
    @SupplierReference NVARCHAR(20),
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT = NULL,
    @DeliveryMethodID INT,
    @DeliveryCityID INT,
    @DeliveryPostalCode NVARCHAR(10),
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20) = NULL,
    @WebsiteURL NVARCHAR(255) = NULL,
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @PostalAddressLine1 NVARCHAR(60),
    @PostalAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL,
    @BankAccountBranch NVARCHAR(20),
    @BankAccountName NVARCHAR(100),
    @BankAccountNumber NVARCHAR(20),
    @PaymentDays INT
AS
BEGIN
    UPDATE Syn_Suppliers
    SET SupplierReference = @SupplierReference,
        SupplierName = @SupplierName,
        SupplierCategoryID = @SupplierCategoryID,
        PrimaryContactPersonID = @PrimaryContactPersonID,
        AlternateContactPersonID = @AlternateContactPersonID,
        DeliveryMethodID = @DeliveryMethodID,
        DeliveryCityID = @DeliveryCityID,
        DeliveryPostalCode = @DeliveryPostalCode,
        PhoneNumber = @PhoneNumber,
        FaxNumber = @FaxNumber,
        WebsiteURL = @WebsiteURL,
        DeliveryAddressLine1 = @DeliveryAddressLine1,
        DeliveryAddressLine2 = @DeliveryAddressLine2,
        PostalAddressLine1 = @PostalAddressLine1,
        PostalAddressLine2 = @PostalAddressLine2,
        DeliveryLocation = GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326),
        BankAccountBranch = @BankAccountBranch,
        BankAccountName = @BankAccountName,
        BankAccountNumber = @BankAccountNumber,
        PaymentDays = @PaymentDays
    WHERE SupplierID = @SupplierID;
END;
GO

CREATE OR ALTER PROCEDURE SP_DeleteSupplier
    @SupplierID INT
AS
BEGIN
    DELETE FROM Syn_Suppliers WHERE SupplierID = @SupplierID;
END;
GO

CREATE OR ALTER PROCEDURE SP_GetAllSuppliers
AS
BEGIN
    SELECT S.SupplierID as SupplierID,
    S.SupplierReference as SupplierReference,
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
    S.BankAccountBranch as BankAccountBranch,
    S.BankAccountName as BankAccountName,
    S.BankAccountNumber as BankAccountNumber,
    S.PaymentDays as PaymentDays
    FROM Syn_Suppliers S
    INNER JOIN Syn_SupplierCategories SC ON SC.SupplierCategoryID = S.SupplierCategoryID
    INNER JOIN Syn_DeliveryMethods DM ON S.DeliveryMethodID = DM.DeliveryMethodID
    INNER JOIN Syn_People P ON P.PersonID = S.PrimaryContactPersonID
    LEFT JOIN Syn_People P2 ON P2.PersonID = S.AlternateContactPersonID
    LEFT JOIN Syn_Cities C ON C.CityID = S.DeliveryCityID
    ORDER BY S.SupplierName ASC;
END;
GO