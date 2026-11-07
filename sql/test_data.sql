-- 05. Inventario de inicio y ventas para comprobar ambos retos.
USE EmpresaDB;
GO

INSERT INTO dbo.Inventario (Producto, Existencias)
VALUES ('Laptop', 10), ('Monitor', 12), ('Mouse', 20);

-- Las dos ventas solicitadas en el enunciado.
INSERT INTO dbo.Ventas (Producto, Cantidad) VALUES ('Laptop', 3);
INSERT INTO dbo.Ventas (Producto, Cantidad) VALUES ('Monitor', 5);

-- Reto principal: UNA instrucción que inserta TRES ventas simultáneamente.
INSERT INTO dbo.Ventas (Producto, Cantidad)
VALUES ('Laptop', 2), ('Monitor', 1), ('Mouse', 4);
GO
