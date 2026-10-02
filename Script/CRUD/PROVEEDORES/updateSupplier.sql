use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_UpdateSupplier
    @SupplierID INT,
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

    IF (@DeliveryLatitude IS NULL AND @DeliveryLongitude IS NOT NULL)
       OR (@DeliveryLatitude IS NOT NULL AND @DeliveryLongitude IS NULL)
        THROW 50001, 'Debe indicar ambas coordenadas o dejar ambas vacias.', 1;

    IF @DeliveryLatitude NOT BETWEEN -90 AND 90
        THROW 50002, 'La latitud debe estar entre -90 y 90.', 1;

    IF @DeliveryLongitude NOT BETWEEN -180 AND 180
        THROW 50003, 'La longitud debe estar entre -180 y 180.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Syn_Suppliers WHERE SupplierID = @SupplierID)
            THROW 50004, 'El proveedor indicado no existe.', 1;

        UPDATE Syn_Suppliers
        SET SupplierReference = @SupplierReference,
            SupplierName = @SupplierName,
            SupplierCategoryID = @SupplierCategoryID,
            PrimaryContactPersonID = @PrimaryContactPersonID,
            AlternateContactPersonID = @AlternateContactPersonID,
            DeliveryMethodID = @DeliveryMethodID,
            DeliveryCityID = @DeliveryCityID,
            PostalCityID = @PostalCityID,
            DeliveryPostalCode = @DeliveryPostalCode,
            PostalPostalCode = @PostalPostalCode,
            PhoneNumber = @PhoneNumber,
            FaxNumber = @FaxNumber,
            WebsiteURL = @WebsiteURL,
            DeliveryAddressLine1 = @DeliveryAddressLine1,
            DeliveryAddressLine2 = @DeliveryAddressLine2,
            PostalAddressLine1 = @PostalAddressLine1,
            PostalAddressLine2 = @PostalAddressLine2,
            DeliveryLocation = CASE
                WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL
                    THEN NULL
                ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326)
            END,
            BankAccountBranch = @BankAccountBranch,
            BankAccountName = @BankAccountName,
            BankAccountNumber = @BankAccountNumber,
            PaymentDays = @PaymentDays,
            LastEditedBy = @LastEditedBy
        WHERE SupplierID = @SupplierID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO