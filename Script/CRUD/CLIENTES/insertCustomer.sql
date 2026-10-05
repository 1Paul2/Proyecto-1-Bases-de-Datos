USE WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_InsertCustomer
    @CustomerName NVARCHAR(100),
    @CustomerCategoryID INT,
    @BuyingGroupID INT = NULL,
    @PrimaryContactPersonID INT,
    @AlternateContactPersonID INT = NULL,
    @BillToCustomerID INT = NULL,
    @DeliveryMethodID INT,
    @DeliveryCityID INT,
    @PostalCityID INT,
    @DeliveryPostalCode NVARCHAR(10),
    @PostalPostalCode NVARCHAR(20),
    @PhoneNumber NVARCHAR(20),
    @FaxNumber NVARCHAR(20),
    @PaymentDays INT,
    @StandardDiscountPercentage DECIMAL(18, 3),
    @IsStatementSent BIT,
    @IsOnCreditHold BIT,
    @WebsiteURL NVARCHAR(100),
    @DeliveryAddressLine1 NVARCHAR(60),
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @PostalAddressLine1 NVARCHAR(60),
    @PostalAddressLine2 NVARCHAR(60) = NULL,
    @AccountOpenedDate DATE,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL,
    @LastEditedBy INT = NULL
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
        DECLARE @NewCustomerID INT = NEXT VALUE FOR Sequences.CustomerID;

        INSERT INTO Syn_Customers (CustomerID, CustomerName, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, BillToCustomerID, DeliveryMethodID, DeliveryCityID, PostalCityID, DeliveryPostalCode, PostalPostalCode, PhoneNumber, FaxNumber, PaymentDays, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2, AccountOpenedDate, DeliveryLocation, LastEditedBy)
        VALUES (
            @NewCustomerID,
            @CustomerName,
            @CustomerCategoryID,
            NULLIF(@BuyingGroupID, 0),
            @PrimaryContactPersonID,
            NULLIF(@AlternateContactPersonID, 0),
            -- BillToCustomerID es NOT NULL: si no viene, el cliente se factura a si mismo
            COALESCE(NULLIF(@BillToCustomerID, 0), @NewCustomerID),
            @DeliveryMethodID,
            @DeliveryCityID,
            @PostalCityID,
            @DeliveryPostalCode,
            @PostalPostalCode,
            ISNULL(@PhoneNumber, ''),
            ISNULL(@FaxNumber, ''),
            @PaymentDays,
            @StandardDiscountPercentage,
            @IsStatementSent,
            @IsOnCreditHold,
            ISNULL(@WebsiteURL, ''),
            @DeliveryAddressLine1,
            @DeliveryAddressLine2,
            @PostalAddressLine1,
            @PostalAddressLine2,
            @AccountOpenedDate,
            CASE WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL THEN NULL ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326) END,
            COALESCE(@LastEditedBy, @PrimaryContactPersonID)
        );

        SELECT @NewCustomerID AS NewCustomerID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO