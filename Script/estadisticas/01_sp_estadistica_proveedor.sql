USE WideWorldImporters;
GO

-- #2

CREATE OR ALTER PROCEDURE sp_estadistica_cliente
    @NomCliente VARCHAR(100) = '',
    @categoria  VARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;

    WITH TotalesPorFactura AS (
        SELECT
            C.CustomerName,
            CC.CustomerCategoryName,
            I.InvoiceID,
            SUM(IL.ExtendedPrice) AS TotalFactura
        FROM Syn_Customers C
        INNER JOIN Syn_CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
        INNER JOIN Syn_Invoices I ON I.CustomerID = C.CustomerID
        INNER JOIN Syn_InvoiceLines IL ON IL.InvoiceID = I.InvoiceID
        WHERE C.CustomerName LIKE '%' + ISNULL(@NomCliente, '') + '%'
          AND CC.CustomerCategoryName LIKE '%' + ISNULL(@categoria, '') + '%'
        GROUP BY C.CustomerName, CC.CustomerCategoryName, I.InvoiceID
    )
    SELECT
        CASE WHEN GROUPING(CustomerName) = 1 THEN 'Total general' ELSE CustomerName END AS Cliente,
        CASE WHEN GROUPING(CustomerCategoryName) = 1 THEN 'Total' ELSE CustomerCategoryName END AS Categoria,
        MIN(TotalFactura) AS Minimo,
        MAX(TotalFactura) AS Maximo,
        AVG(TotalFactura) AS Promedio
    FROM TotalesPorFactura
    GROUP BY ROLLUP (CustomerName, CustomerCategoryName);
END;
GO