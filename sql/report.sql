-- Una fila CSV por venta. Entrecomillamos columnas y escapamos comillas.
SET NOCOUNT ON;
SELECT CONCAT('"', VentaID, '","',
              REPLACE(Producto, '"', '""'), '","',
              Cantidad, '","', CONVERT(VARCHAR(19), Fecha, 126), '"')
FROM dbo.Ventas
ORDER BY VentaID;
GO
