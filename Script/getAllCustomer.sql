CREATE OR ALTER PROCEDURE SP_GetAllCustomers
AS
BEGIN
    SELECT C.CustomerID,
           C.CustomerName,
           CC.CustomerCategoryName,
           BG.BuyingGroupName,
           P1.FullName AS PrimaryContact,
           P2.FullName AS AlternateContact,
           B.CustomerName AS BillToCustomer,
           DM.DeliveryMethodName,
           City.CityName AS DeliveryCity,
           C.PostalPostalCode,
           C.PhoneNumber,
           C.FaxNumber,
           C.PaymentDays,
           C.WebsiteURL,
           C.DeliveryAddressLine1,
           C.DeliveryAddressLine2,
           C.PostalAddressLine1,
           C.PostalAddressLine2,
           C.DeliveryLocation.Lat AS DeliveryLatitude,
           C.DeliveryLocation.Long AS DeliveryLongitude
    FROM Sales.Customers C
    INNER JOIN Sales.CustomerCategories CC ON C.CustomerCategoryID = CC.CustomerCategoryID
    LEFT JOIN Sales.BuyingGroups BG ON C.BuyingGroupID = BG.BuyingGroupID
    INNER JOIN Application.People P1 ON C.PrimaryContactPersonID = P1.PersonID
    LEFT JOIN Application.People P2 ON C.AlternateContactPersonID = P2.PersonID
    LEFT JOIN Sales.Customers B ON C.BillToCustomerID = B.CustomerID
    INNER JOIN Application.DeliveryMethods DM ON C.DeliveryMethodID = DM.DeliveryMethodID
    LEFT JOIN Application.Cities City ON C.DeliveryCityID = City.CityID
    ORDER BY C.CustomerName ASC;
END;
GO