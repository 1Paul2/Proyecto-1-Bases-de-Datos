use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_InsertSupplier
    @SupplierReference NVARCHAR(40),
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT,
    @DeliveryMethodID INT,
    @DeliveryCityID INT,
    @PostalCityID INT,
    @DeliveryPostalCode NVARCHAR(20),
    @PostalPostalCode NVARCHAR(20),
    @PhoneNumber NVARCHAR(40),
    @FaxNumber NVARCHAR(40),
    @WebsiteURL NVARCHAR(512),
    @DeliveryAddressLine1 NVARCHAR(120),
    @DeliveryAddressLine2 NVARCHAR(120) = NULL,
    @PostalAddressLine1 NVARCHAR(120),
    @PostalAddressLine2 NVARCHAR(120) = NULL,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL,
    @BankAccountBranch NVARCHAR(100),
    @BankAccountName NVARCHAR(100),
    @BankAccountNumber NVARCHAR(40),
    @PaymentDays INT,
    @LastEditedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
            INSERT INTO Syn_Suppliers (
                SupplierReference,
                SupplierName,
                SupplierCategoryID,
                PrimaryContactPersonID,
                AlternateContactPersonID,
                DeliveryMethodID,
                DeliveryCityID,
                PostalCityID,
                DeliveryPostalCode,
                PostalPostalCode,
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
                PaymentDays,
                LastEditedBy
            )
            VALUES (
                @SupplierReference,
                @SupplierName,
                @SupplierCategoryID,
                @PrimaryContactPersonID,
                @AlternateContactPersonID,
                @DeliveryMethodID,
                @DeliveryCityID,
                @PostalCityID,
                @DeliveryPostalCode,
                @PostalPostalCode,
                @PhoneNumber,
                @FaxNumber,
                @WebsiteURL,
                @DeliveryAddressLine1,
                @DeliveryAddressLine2,
                @PostalAddressLine1,
                @PostalAddressLine2,
                CASE
                    WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL
                        THEN NULL
                    ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326)
                END,
                @BankAccountBranch,
                @BankAccountName,
                @BankAccountNumber,
                @PaymentDays,
                @LastEditedBy
            );
            SELECT SCOPE_IDENTITY() AS NewSupplierID;
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO