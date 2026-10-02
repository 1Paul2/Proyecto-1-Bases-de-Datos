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
    UPDATE Sales.Customers
    SET CustomerName = @CustomerName,
        CustomerCategoryID = @CustomerCategoryID,
        BuyingGroupID = @BuyingGroupID,
        PrimaryContactPersonID = @PrimaryContactPersonID,
        AlternateContactPersonID = @AlternateContactPersonID,
        BillToCustomerID = @BillToCustomerID,
        DeliveryMethodID = @DeliveryMethodID,
        DeliveryCityID = @DeliveryCityID,
        PostalPostalCode = @PostalPostalCode,
        PhoneNumber = @PhoneNumber,
        FaxNumber = @FaxNumber,
        PaymentDays = @PaymentDays,
        WebsiteURL = @WebsiteURL,
        DeliveryAddressLine1 = @DeliveryAddressLine1,
        DeliveryAddressLine2 = @DeliveryAddressLine2,
        PostalAddressLine1 = @PostalAddressLine1,
        PostalAddressLine2 = @PostalAddressLine2,
        DeliveryLocation = GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326)
    WHERE CustomerID = @CustomerID;
END;
GO