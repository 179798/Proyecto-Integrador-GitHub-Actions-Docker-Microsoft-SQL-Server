-- 03. Un tipo de tabla permite enviar MUCHAS ventas en una sola llamada.
USE EmpresaDB;
GO

CREATE TYPE dbo.TipoVentasInsertadas AS TABLE (
    VentaID INT NOT NULL PRIMARY KEY,
    Producto VARCHAR(100) NOT NULL,
    Cantidad INT NOT NULL
);
GO

-- La versión original recibía un solo @VentaID INT. Se amplía para el reto
-- principal y el avanzado: auditar y descontar inventario por conjuntos.
CREATE PROCEDURE dbo.sp_RegistrarAuditoria
    @Ventas dbo.TipoVentasInsertadas READONLY
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM @Ventas)
        RETURN;

    -- Agrupar por producto evita descontarlo varias veces fila por fila.
    DECLARE @Totales TABLE (
        Producto VARCHAR(100) NOT NULL PRIMARY KEY,
        CantidadTotal INT NOT NULL
    );

    INSERT INTO @Totales (Producto, CantidadTotal)
    SELECT Producto, SUM(Cantidad)
    FROM @Ventas
    GROUP BY Producto;

    DECLARE @ProductosEsperados INT;
    SELECT @ProductosEsperados = COUNT(*) FROM @Totales;

    -- Una sola actualización por conjunto, sin cursores ni bucles.
    -- Si un producto no existe o faltan existencias, se rechazará la venta.
    UPDATE inv
       SET inv.Existencias = inv.Existencias - t.CantidadTotal
    FROM dbo.Inventario AS inv
    INNER JOIN @Totales AS t ON t.Producto = inv.Producto
    WHERE inv.Existencias >= t.CantidadTotal;

    DECLARE @ProductosActualizados INT = @@ROWCOUNT;
    IF @ProductosActualizados <> @ProductosEsperados
        THROW 50001, 'Producto inexistente o existencias insuficientes.', 1;

    -- Una auditoría por venta, incluso si un INSERT agregó muchas filas.
    INSERT INTO dbo.AuditoriaVentas (VentaID, Mensaje)
    SELECT VentaID, 'Venta registrada automáticamente'
    FROM @Ventas;
END;
GO
