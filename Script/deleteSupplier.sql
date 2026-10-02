CREATE OR ALTER PROCEDURE SP_DeleteSupplier
    @SupplierID INT
AS
BEGIN
    DELETE FROM Syn_Suppliers WHERE SupplierID = @SupplierID;
END;
GO