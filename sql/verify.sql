-- Pruebas automáticas: si alguna falla, GitHub Actions queda en rojo.
USE EmpresaDB;
GO
SET NOCOUNT ON;

IF (SELECT COUNT(*) FROM dbo.Ventas) <> 5
    THROW 51001, 'ERROR: se esperaban exactamente 5 ventas.', 1;

IF (SELECT COUNT(*) FROM dbo.AuditoriaVentas) <> 5
    THROW 51002, 'ERROR: se esperaban exactamente 5 auditorias.', 1;

IF EXISTS (
    SELECT v.VentaID
    FROM dbo.Ventas AS v
    LEFT JOIN dbo.AuditoriaVentas AS a ON a.VentaID = v.VentaID
    GROUP BY v.VentaID
    HAVING COUNT(a.AuditoriaID) <> 1
)
    THROW 51003, 'ERROR: cada venta debe tener exactamente 1 auditoria.', 1;

IF EXISTS (
    SELECT 1 FROM dbo.Inventario
    WHERE (Producto = 'Laptop' AND Existencias <> 5)
       OR (Producto = 'Monitor' AND Existencias <> 6)
       OR (Producto = 'Mouse' AND Existencias <> 16)
)
    THROW 51004, 'ERROR: el inventario no se desconto correctamente.', 1;

IF (SELECT COUNT(*) FROM dbo.Inventario) <> 3
    THROW 51005, 'ERROR: se esperaban 3 productos en inventario.', 1;

PRINT 'PRUEBAS CORRECTAS: 5 ventas, 5 auditorias e inventario actualizado.';
SELECT VentaID, Producto, Cantidad, Fecha FROM dbo.Ventas ORDER BY VentaID;
SELECT AuditoriaID, VentaID, FechaRegistro, Mensaje
FROM dbo.AuditoriaVentas ORDER BY AuditoriaID;
SELECT Producto, Existencias FROM dbo.Inventario ORDER BY Producto;
GO
