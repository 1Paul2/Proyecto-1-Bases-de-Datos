use WideWorldImporters;
GO
CREATE OR ALTER PROCEDURE SP_GetAllSales
AS
BEGIN
    SELECT I.InvoiceID as InvoiceID,
        I.InvoiceDate as InvoiceDate,
        C.CustomerName as CustomerName,
        D.DeliveryMethodName as DeliveryMethod,
        SUM(IL.ExtendedPrice) as TotalAmount
    FROM Syn_Invoices I
    INNER JOIN Syn_Customers C ON I.CustomerID = C.CustomerID
    INNER JOIN Syn_DeliveryMethods D ON I.DeliveryMethodID = D.DeliveryMethodName
    LEFT JOIN Syn_InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
    GROUP BY I.InvoiceID, I.InvoiceDate, C.CustomerName, D.DeliveryMethodName
    ORDER BY C.CustomerName ASC, I.InvoiceDate DESC;
END;
GO