use WideWorldImporters
GO
CREATE SYNONYM Syn_Suppliers FOR Purchasing.Suppliers;
CREATE SYNONYM Syn_SupplierCategories FOR Purchasing.SupplierCategories;
CREATE SYNONYM Syn_People FOR Application.People;
CREATE SYNONYM Syn_DeliveryMethods FOR Application.DeliveryMethods;
CREATE SYNONYM Syn_Cities FOR Application.Cities;
CREATE SYNONYM Syn_StateProvinces FOR Application.StateProvinces;
CREATE SYNONYM Syn_StockItems FOR Warehouse.StockItems;
CREATE SYNONYM Syn_StockGroups FOR Warehouse.StockGroups;
CREATE SYNONYM Syn_StockItemStockGroups FOR Warehouse.StockItemStockGroups;
CREATE SYNONYM Syn_StockItemHoldings FOR Warehouse.StockItemHoldings;
CREATE SYNONYM Syn_Colors FOR Warehouse.Colors;
CREATE SYNONYM Syn_PackageTypes FOR Warehouse.PackageTypes;
CREATE SYNONYM Syn_Invoices FOR Sales.Invoices;
CREATE SYNONYM Syn_InvoiceLines FOR Sales.InvoiceLines;
CREATE SYNONYM Syn_Customers FOR Sales.Customers;