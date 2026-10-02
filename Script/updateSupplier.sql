use WideWorldImporters;
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