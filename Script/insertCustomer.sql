use WideWorldImporters;
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

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Syn_Customers (CustomerName, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, BillToCustomerID, DeliveryMethodID, DeliveryCityID, PostalCityID, DeliveryPostalCode, PostalPostalCode, PhoneNumber, FaxNumber, PaymentDays, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2, AccountOpenedDate, DeliveryLocation, LastEditedBy)
        VALUES (@CustomerName, @CustomerCategoryID, @BuyingGroupID, @PrimaryContactPersonID, @AlternateContactPersonID, @BillToCustomerID, @DeliveryMethodID, @DeliveryCityID, @PostalCityID, @DeliveryPostalCode, @PostalPostalCode, @PhoneNumber, @FaxNumber, @PaymentDays, @StandardDiscountPercentage, @IsStatementSent, @IsOnCreditHold, @WebsiteURL, @DeliveryAddressLine1, @DeliveryAddressLine2, @PostalAddressLine1, @PostalAddressLine2, @AccountOpenedDate, CASE WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL THEN NULL ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326) END, COALESCE(@LastEditedBy, @PrimaryContactPersonID));

        SELECT SCOPE_IDENTITY() AS NewCustomerID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO