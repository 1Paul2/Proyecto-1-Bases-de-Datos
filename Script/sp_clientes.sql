use WideWorldImporters;
GO 

CREATE OR ALTER PROCEDURE SP_LISTA_CLIENTES
    @Apodo VARCHAR(100)
AS
BEGIN
    SELECT 
        SC.CustomerName AS Nombre,
        SCC.CustomerCategoryName AS Categoria,
        ADM.DeliveryMethodName AS Metodo_de_entrega
    FROM Sales.Customers SC
    INNER JOIN Sales.CustomerCategories SCC ON SCC.CustomerCategoryID = SC.CustomerCategoryID
    INNER JOIN Application.DeliveryMethods ADM ON ADM.DeliveryMethodID = SC.DeliveryMethodID
    WHERE SC.CustomerName LIKE '%' + @Apodo + '%'
    ORDER BY SC.CustomerName ASC;
END;
GO

Create OR ALTER PROCEDURE SP_CLIENTES
    @Nombre VARCHAR(100)
AS
BEGIN 
    SELECT SC.CustomerName as Nombre,
    SCC.CustomerCategoryName as Categoría,
    SB.BuyingGroupName as Grupo_de_compra,
    AP1.FullName as Contacto_Primario,
    AP2.FullName as Contacto_Secundario,
    BillTo.CustomerName AS Cliente_por_facturar,
    ADM.DeliveryMethodName as Métodos_de_entrega,
    AC.CityName as Ciudad_de_entrega,
    SC.PostalPostalCode as Código_postal,
    SC.PhoneNumber AS Telefono,
    SC.FaxNumber AS Fax,
    SC.PaymentDays as Días_de_gracia_para_pagar,
    SC.WebsiteURL AS Sitio_web,
    SC.DeliveryAddressLine1 AS Direccion_Entrega_1,
    SC.DeliveryAddressLine2 AS Direccion_Entrega_2,
    SC.PostalAddressLine1 AS Direccion_Postal_1,
    SC.PostalAddressLine2 AS Direccion_Postal_2,
    SC.DeliveryLocation.Lat AS Latitud,
    SC.DeliveryLocation.Long AS Longitud
        from Sales.Customers SC

        INNER JOIN Sales.CustomerCategories SCC on SCC.CustomerCategoryID = SC.CustomerCategoryID
        LEFT JOIN Sales.BuyingGroups SB ON SB.BuyingGroupID = SC.BuyingGroupID
        INNER JOIN Application.People AP1 ON AP1.PersonID = SC.PrimaryContactPersonID
        LEFT JOIN Application.People AP2 ON AP2.PersonID = SC.AlternateContactPersonID --No todos tienen un alternativo
        LEFT JOIN Sales.Customers BillTo ON BillTo.CustomerID = SC.BillToCustomerID
        INNER JOIN Application.DeliveryMethods ADM on ADM.DeliveryMethodID = SC.DeliveryMethodID
        LEFT JOIN Application.Cities AC ON AC.CityID = SC.DeliveryCityID

    WHERE SC.CustomerName = @Nombre
    GROUP BY SC.CustomerName,SCC.CustomerCategoryName,SB.BuyingGroupName,AP1.FullName ,
        AP2.FullName,BillTo.CustomerName,ADM.DeliveryMethodName, AC.CityName,SC.PostalPostalCode,
        SC.PhoneNumber,SC.FaxNumber,SC.PaymentDays,SC.WebsiteURL,SC.DeliveryAddressLine1,
        SC.DeliveryAddressLine2,SC.PostalAddressLine1,SC.PostalAddressLine2,SC.DeliveryLocation.Lat,
        SC.DeliveryLocation.Long 
    ORDER BY SC.CustomerName ASC
END;
GO

--EXEC SP_LISTA_CLIENTES @Apodo = 'Tail';
--EXEC SP_CLIENTES @Nombre = 'Tailspin Toys (Arbor Vitae, WI)';

CREATE OR ALTER PROCEDURE SP_InsertarCliente
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

CREATE OR ALTER PROCEDURE SP_UPDATE_CLIENTE
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

CREATE OR ALTER PROCEDURE SP_ELIMINAR_CLIENTE
    @CustomerID INT
AS
BEGIN
    DELETE FROM Sales.Customers WHERE CustomerID = @CustomerID;
END;
GO

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