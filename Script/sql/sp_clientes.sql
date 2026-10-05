use WideWorldImporters;
GO 


CREATE OR ALTER PROCEDURE SP_CLIENTES
    @Nombre VARCHAR(100)
AS
BEGIN 
    SELECT SC.CustomerID AS CustomerID,
    SC.CustomerCategoryID AS CustomerCategoryID,
    SC.BuyingGroupID AS BuyingGroupID,
    SC.PrimaryContactPersonID AS PrimaryContactPersonID,
    SC.AlternateContactPersonID AS AlternateContactPersonID,
    SC.BillToCustomerID AS BillToCustomerID,
    SC.DeliveryMethodID AS DeliveryMethodID,
    SC.DeliveryCityID AS DeliveryCityID,
    SC.PostalCityID AS PostalCityID,
    SC.CustomerName as Nombre,
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
    SC.PostalPostalCode AS PostalPostalCode,
    SC.DeliveryPostalCode AS DeliveryPostalCode,
    SC.PhoneNumber AS PhoneNumber,
    SC.FaxNumber AS FaxNumber,
    SC.PaymentDays AS PaymentDays,
    SC.StandardDiscountPercentage AS StandardDiscountPercentage,
    SC.IsStatementSent AS IsStatementSent,
    SC.IsOnCreditHold AS IsOnCreditHold,
    SC.WebsiteURL AS WebsiteURL,
    SC.DeliveryAddressLine1 AS DeliveryAddressLine1,
    SC.DeliveryAddressLine2 AS DeliveryAddressLine2,
    SC.PostalAddressLine1 AS PostalAddressLine1,
    SC.PostalAddressLine2 AS PostalAddressLine2,
    SC.AccountOpenedDate AS AccountOpenedDate,
    SC.DeliveryLocation.Lat AS Latitud,
    SC.DeliveryLocation.Long AS Longitud,
    SC.DeliveryLocation.Lat AS DeliveryLatitude,
    SC.DeliveryLocation.Long AS DeliveryLongitude
        FROM Syn_Customers SC

        INNER JOIN Syn_CustomerCategories SCC ON SCC.CustomerCategoryID = SC.CustomerCategoryID
        LEFT JOIN Syn_BuyingGroups SB ON SB.BuyingGroupID = SC.BuyingGroupID
        INNER JOIN Syn_People AP1 ON AP1.PersonID = SC.PrimaryContactPersonID
        LEFT JOIN Syn_People AP2 ON AP2.PersonID = SC.AlternateContactPersonID
        LEFT JOIN Syn_Customers BillTo ON BillTo.CustomerID = SC.BillToCustomerID
        INNER JOIN Syn_DeliveryMethods ADM ON ADM.DeliveryMethodID = SC.DeliveryMethodID
        LEFT JOIN Syn_Cities AC ON AC.CityID = SC.DeliveryCityID

    WHERE SC.CustomerName = @Nombre
    GROUP BY SC.CustomerID, SC.CustomerCategoryID, SC.BuyingGroupID, SC.PrimaryContactPersonID,
        SC.AlternateContactPersonID, SC.BillToCustomerID, SC.DeliveryMethodID, SC.DeliveryCityID,
        SC.PostalCityID,
        SC.CustomerName, SCC.CustomerCategoryName, SB.BuyingGroupName, AP1.FullName,
        AP2.FullName, BillTo.CustomerName, ADM.DeliveryMethodName, AC.CityName, SC.PostalPostalCode,
        SC.DeliveryPostalCode,
        SC.PhoneNumber, SC.FaxNumber, SC.PaymentDays, SC.StandardDiscountPercentage, SC.IsStatementSent, SC.IsOnCreditHold, SC.WebsiteURL, SC.DeliveryAddressLine1,
        SC.DeliveryAddressLine2, SC.PostalAddressLine1, SC.PostalAddressLine2, SC.AccountOpenedDate,
        SC.DeliveryLocation.Lat,
        SC.DeliveryLocation.Long 
    ORDER BY SC.CustomerName ASC
END;
GO

--EXEC SP_LISTA_CLIENTES @Apodo = 'Tail';
--EXEC SP_CLIENTES @Nombre = 'Tailspin Toys (Arbor Vitae, WI)';
CREATE OR ALTER PROCEDURE SP_LISTA_CLIENTES
    @Apodo VARCHAR(100) = NULL,
    @CustomerCategoryID INT = NULL,
    @DeliveryMethodID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SC.CustomerID AS CustomerID,
        SC.CustomerName AS Nombre,
        SCC.CustomerCategoryName AS Categoria,
        ADM.DeliveryMethodName AS Metodo_de_entrega
    FROM Syn_Customers SC
    INNER JOIN Syn_CustomerCategories SCC ON SCC.CustomerCategoryID = SC.CustomerCategoryID
    INNER JOIN Syn_DeliveryMethods ADM ON ADM.DeliveryMethodID = SC.DeliveryMethodID
    WHERE (@Apodo IS NULL OR SC.CustomerName LIKE '%' + @Apodo + '%')
      AND (@CustomerCategoryID IS NULL OR SC.CustomerCategoryID = @CustomerCategoryID)
      AND (@DeliveryMethodID IS NULL OR SC.DeliveryMethodID = @DeliveryMethodID)
    ORDER BY SC.CustomerName ASC;
END;
GO
