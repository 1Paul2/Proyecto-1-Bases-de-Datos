USE WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_UpdateCustomer
    @CustomerID INT,
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
        THROW 50003, 'Debe indicar ambas coordenadas o dejar ambas vacias.', 1;

    IF @DeliveryLatitude IS NOT NULL AND @DeliveryLatitude NOT BETWEEN -90 AND 90
        THROW 50004, 'La latitud debe estar entre -90 y 90.', 1;

    IF @DeliveryLongitude IS NOT NULL AND @DeliveryLongitude NOT BETWEEN -180 AND 180
        THROW 50005, 'La longitud debe estar entre -180 y 180.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Syn_Customers WHERE CustomerID = @CustomerID)
            THROW 50001, 'El cliente indicado no existe.', 1;

        UPDATE Syn_Customers
        SET CustomerName = @CustomerName,
            CustomerCategoryID = @CustomerCategoryID,
            BuyingGroupID = NULLIF(@BuyingGroupID, 0),
            PrimaryContactPersonID = @PrimaryContactPersonID,
            AlternateContactPersonID = NULLIF(@AlternateContactPersonID, 0),
            -- BillToCustomerID y DeliveryCityID son NOT NULL: con 0 o NULL se conserva el valor actual
            BillToCustomerID = ISNULL(NULLIF(@BillToCustomerID, 0), BillToCustomerID),
            DeliveryMethodID = @DeliveryMethodID,
            DeliveryCityID = ISNULL(NULLIF(@DeliveryCityID, 0), DeliveryCityID),
            PostalCityID = @PostalCityID,
            DeliveryPostalCode = @DeliveryPostalCode,
            PostalPostalCode = @PostalPostalCode,
            PhoneNumber = ISNULL(@PhoneNumber, ''),
            FaxNumber = ISNULL(@FaxNumber, ''),
            PaymentDays = @PaymentDays,
            StandardDiscountPercentage = @StandardDiscountPercentage,
            IsStatementSent = @IsStatementSent,
            IsOnCreditHold = @IsOnCreditHold,
            WebsiteURL = ISNULL(@WebsiteURL, ''),
            DeliveryAddressLine1 = @DeliveryAddressLine1,
            DeliveryAddressLine2 = @DeliveryAddressLine2,
            PostalAddressLine1 = @PostalAddressLine1,
            PostalAddressLine2 = @PostalAddressLine2,
            AccountOpenedDate = @AccountOpenedDate,
            DeliveryLocation = CASE WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL THEN NULL ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326) END,
            LastEditedBy = COALESCE(@LastEditedBy, @PrimaryContactPersonID)
        WHERE CustomerID = @CustomerID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO