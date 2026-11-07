-- 04. En SQL Server un trigger AFTER INSERT se ejecuta por SENTENCIA.
-- inserted puede contener 1, 3, 100 o más filas.
USE EmpresaDB;
GO

CREATE TRIGGER dbo.trg_AuditarVenta
ON dbo.Ventas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ventas dbo.TipoVentasInsertadas;

    INSERT INTO @Ventas (VentaID, Producto, Cantidad)
    SELECT VentaID, Producto, Cantidad
    FROM inserted;

    EXEC dbo.sp_RegistrarAuditoria @Ventas = @Ventas;
END;
GO
