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
        PostalPostalCode = @PostalPostalCode,
        PhoneNumber = @PhoneNumber,
        FaxNumber = @FaxNumber,
        PaymentDays = @PaymentDays,
        WebsiteURL = @WebsiteURL,
        DeliveryAddressLine1 = @DeliveryAddressLine1,
        DeliveryAddressLine2 = @DeliveryAddressLine2,
        PostalAddressLine1 = @PostalAddressLine1,
        PostalAddressLine2 = @PostalAddressLine2,
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