USE WideWorldImporters;
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

    IF (@DeliveryLatitude IS NULL AND @DeliveryLongitude IS NOT NULL)
       OR (@DeliveryLatitude IS NOT NULL AND @DeliveryLongitude IS NULL)
        THROW 50001, 'Debe indicar ambas coordenadas o dejar ambas vacias.', 1;

    IF @DeliveryLatitude IS NOT NULL AND @DeliveryLatitude NOT BETWEEN -90 AND 90
        THROW 50002, 'La latitud debe estar entre -90 y 90.', 1;

    IF @DeliveryLongitude IS NOT NULL AND @DeliveryLongitude NOT BETWEEN -180 AND 180
        THROW 50003, 'La longitud debe estar entre -180 y 180.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- El ID sale de la secuencia, no de IDENTITY
        DECLARE @NewSupplierID INT = NEXT VALUE FOR Sequences.SupplierID;

        INSERT INTO Syn_Suppliers (
            SupplierID,
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
            @NewSupplierID,
            @SupplierReference,
            @SupplierName,
            @SupplierCategoryID,
            @PrimaryContactPersonID,
            COALESCE(NULLIF(@AlternateContactPersonID, 0), @PrimaryContactPersonID),
            @DeliveryMethodID,
            @DeliveryCityID,
            @PostalCityID,
            @DeliveryPostalCode,
            @PostalPostalCode,
            ISNULL(@PhoneNumber, ''),
            ISNULL(@FaxNumber, ''),
            ISNULL(@WebsiteURL, ''),
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

        SELECT @NewSupplierID AS NewSupplierID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO