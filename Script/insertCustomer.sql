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
    @DeliveryCityID INT = NULL,
    @PostalPostalCode NVARCHAR(20) = NULL,
    @PhoneNumber NVARCHAR(20) = NULL,
    @FaxNumber NVARCHAR(20) = NULL,
    @PaymentDays INT,
    @WebsiteURL NVARCHAR(100) = NULL,
    @DeliveryAddressLine1 NVARCHAR(60) = NULL,
    @DeliveryAddressLine2 NVARCHAR(60) = NULL,
    @PostalAddressLine1 NVARCHAR(60) = NULL,
    @PostalAddressLine2 NVARCHAR(60) = NULL,
    @DeliveryLatitude DECIMAL(9, 6) = NULL,
    @DeliveryLongitude DECIMAL(9, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (@DeliveryLatitude IS NULL AND @DeliveryLongitude IS NOT NULL)
       OR (@DeliveryLatitude IS NOT NULL AND @DeliveryLongitude IS NULL)
        THROW 50001, 'Debe indicar ambas coordenadas o dejar ambas vacias.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Syn_Customers (CustomerName, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, BillToCustomerID, DeliveryMethodID, DeliveryCityID, PostalPostalCode, PhoneNumber, FaxNumber, PaymentDays, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2, DeliveryLocation)
        VALUES (@CustomerName, @CustomerCategoryID, @BuyingGroupID, @PrimaryContactPersonID, @AlternateContactPersonID, @BillToCustomerID, @DeliveryMethodID, @DeliveryCityID, @PostalPostalCode, @PhoneNumber, @FaxNumber, @PaymentDays, @WebsiteURL, @DeliveryAddressLine1, @DeliveryAddressLine2, @PostalAddressLine1, @PostalAddressLine2, CASE WHEN @DeliveryLatitude IS NULL AND @DeliveryLongitude IS NULL THEN NULL ELSE GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326) END);

        SELECT SCOPE_IDENTITY() AS NewCustomerID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO