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
    INSERT INTO Sales.Customers (CustomerName, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, BillToCustomerID, DeliveryMethodID, DeliveryCityID, PostalPostalCode, PhoneNumber, FaxNumber, PaymentDays, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2, DeliveryLocation)
    VALUES (@CustomerName, @CustomerCategoryID, @BuyingGroupID, @PrimaryContactPersonID, @AlternateContactPersonID, @BillToCustomerID, @DeliveryMethodID, @DeliveryCityID, @PostalPostalCode, @PhoneNumber, @FaxNumber, @PaymentDays, @WebsiteURL, @DeliveryAddressLine1, @DeliveryAddressLine2, @PostalAddressLine1, @PostalAddressLine2, GEOGRAPHY::Point(@DeliveryLatitude, @DeliveryLongitude, 4326));
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;
GO