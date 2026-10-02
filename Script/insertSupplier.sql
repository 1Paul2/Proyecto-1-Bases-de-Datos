use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_InsertSupplier
    @SupplierReference NVARCHAR(20),
    @SupplierName NVARCHAR(100),
    @SupplierCategoryID INT,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT,
    @DeliveryMethodID INT,
    @DeliveryCityID INT,
    @PostalCityID INT,
    @DeliveryPostalCode NVARCHAR(10),
    @PostalPostalCode NVARCHAR(20),
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20),
    @WebsiteURL NVARCHAR(255),
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @PostalAddressLine1 NVARCHAR(60),
    @PostalAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL,
    @BankAccountBranch NVARCHAR(20),
    @BankAccountName NVARCHAR(100),
    @BankAccountNumber NVARCHAR(20),
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