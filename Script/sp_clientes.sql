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