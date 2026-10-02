use WideWorldImporters;
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
    @DeliveryLongitude DECIMAL(9, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

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
        BillToCustomerID = NULLIF(@BillToCustomerID, 0),
        DeliveryMethodID = @DeliveryMethodID,
        DeliveryCityID = NULLIF(@DeliveryCityID, 0),
        PostalCityID = @PostalCityID,
        DeliveryPostalCode = @DeliveryPostalCode,
        PostalPostalCode = @PostalPostalCode,
        PhoneNumber = @PhoneNumber,
        FaxNumber = @FaxNumber,
        PaymentDays = @PaymentDays,
        StandardDiscountPercentage = @StandardDiscountPercentage,
        IsStatementSent = @IsStatementSent,
        IsOnCreditHold = @IsOnCreditHold,
        WebsiteURL = @WebsiteURL,
        DeliveryAddressLine1 = @DeliveryAddressLine1,
        DeliveryAddressLine2 = @DeliveryAddressLine2,
        PostalAddressLine1 = @PostalAddressLine1,
        PostalAddressLine2 = @PostalAddressLine2,
        AccountOpenedDate = @AccountOpenedDate,
            DeliveryLocation = CASE WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL THEN NULL ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326) END
        WHERE CustomerID = @CustomerID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO