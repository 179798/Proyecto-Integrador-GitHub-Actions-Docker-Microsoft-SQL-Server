# Documento técnico: GitHub Actions, Docker y SQL Server


## 1. Objetivo y tecnologías

Automatizar la instalación temporal de SQL Server, la creación de `EmpresaDB`, la ejecución de lógica de ventas y sus pruebas. **GitHub** guarda y versiona los archivos; **GitHub Actions** ejecuta workflows YAML en Ubuntu; **Docker** inicia la imagen oficial `mcr.microsoft.com/mssql/server:2022-latest` (edición Developer); **T-SQL** define objetos y reglas de negocio; **sqlcmd** ejecuta los scripts; y **Artifacts** permite descargar el CSV generado.

## 2. Estructura y ejecución

- `.github/workflows/deploy.yml`: se activa con `push` a `main` o manualmente. Descarga el código, ejecuta `scripts/setup_db.sh` y comprueba los resultados con `sql/verify.sql`.
- `scripts/setup_db.sh`: inicia el contenedor, espera una conexión SQL y ejecuta, en orden, `create_database.sql`, `create_tables.sql`, `create_procedure.sql`, `create_trigger.sql` y `test_data.sql`.
- `.github/workflows/reporte.yml`: ejecución manual o programada; crea una instancia nueva, aplica los scripts, ejecuta `sql/report.sql` y publica `reporte_ventas.csv`.

El despliegue **no es permanente**: cada workflow usa un runner y una instancia de SQL Server temporales.

## 3. Base de datos y tablas

`EmpresaDB` contiene:

| Tabla | Campos principales | Función |
|---|---|---|
| `Ventas` | `VentaID` (IDENTITY, PK), `Producto`, `Cantidad`, `Fecha` | Registra ventas; fecha por defecto `GETDATE()` y cantidad positiva. |
| `AuditoriaVentas` | `AuditoriaID` (IDENTITY, PK), `VentaID` (FK), `FechaRegistro`, `Mensaje` | Guarda una auditoría por venta. |
| `Inventario` | `Producto` (PK), `Existencias` | Mantiene existencias no negativas. |

## 4. Procedimiento almacenado y trigger

`trg_AuditarVenta` es un trigger **`AFTER INSERT`** sobre `Ventas`. La tabla lógica **`inserted`** contiene *todas* las filas creadas por la instrucción actual; es temporal y no se almacena como tabla física. El trigger copia el conjunto a una variable del tipo tabla `dbo.TipoVentasInsertadas` y lo envía a `sp_RegistrarAuditoria`.

El procedimiento recibe ese parámetro **`READONLY`**, agrupa por producto (`GROUP BY`), descuenta unidades de `Inventario` con un **`UPDATE ... JOIN`** y escribe auditorías con **`INSERT ... SELECT`**. Si el producto no existe o no alcanza el inventario, lanza un error que impide registrar esa venta.

## 5. Reto principal: procesamiento por conjuntos

El código inicial con `SELECT @VentaID = VentaID FROM inserted` conserva solo un ID y puede ignorar filas cuando un `INSERT` agrega varias ventas. Un procesamiento **fila a fila** (cursor o bucle) trabaja un registro por vez y requiere más iteraciones. El enfoque **set-based** procesa varias filas con operaciones SQL únicas, evitando ese problema y normalmente reduciendo el costo de ejecución.

**Prueba:** una sola sentencia inserta tres ventas (`Laptop 2`, `Monitor 1`, `Mouse 4`), además de las dos iniciales (`Laptop 3`, `Monitor 5`). Se generan **cinco auditorías**, una por venta.

## 6. Reto avanzado: inventario y validación

El procedimiento actualiza automáticamente las existencias de los productos vendidos:

| Producto | Inicial | Ventas totales | Final |
|---|---:|---:|---:|
| Laptop | 10 | 5 | **5** |
| Monitor | 12 | 6 | **6** |
| Mouse | 20 | 4 | **16** |

`sql/verify.sql` verifica el número de ventas y auditorías, que cada venta tenga una auditoría y que el inventario sea correcto. Ante un resultado incorrecto utiliza `THROW` para fallar la prueba. La ejecución [01 - SQL Server](https://github.com/179798/Proyecto-Integrador-GitHub-Actions-Docker-Microsoft-SQL-Server/actions/runs/42404812456) finalizó correctamente y mostró: **«PRUEBAS CORRECTAS: 5 ventas, 5 auditorias e inventario actualizado.»**

## 7. Secrets, programación y reporte CSV

La contraseña de `sa` se obtiene del Secret **`MSSQL_SA_PASSWORD`** y no se incluye en el repositorio; las variables `ACCEPT_EULA=Y` y `MSSQL_PID=Developer` configuran el contenedor. Los workflows pasan la contraseña a SQL Server y a `sqlcmd` durante la ejecución.

El segundo workflow contiene `schedule: cron: '17 14 * * 1'` (**lunes, 14:17 UTC**) y `workflow_dispatch` para iniciarlo manualmente. Publica el Artifact **`reporte-ventas-csv`**, que contiene `reporte_ventas.csv` con encabezado y cinco ventas. La [ejecución manual verificada](https://github.com/179798/Proyecto-Integrador-GitHub-Actions-Docker-Microsoft-SQL-Server/actions/runs/42404896834) terminó correctamente. La ejecución futura por calendario está **configurada**, pero no se ha verificado aún su disparo automático.

## 8. Relación con el ejemplo y conclusión

El [ejemplo del docente](https://github.com/jesusrevilla/T41A-P16) utiliza PostgreSQL y GitHub Actions. Se conserva la idea de repositorio documentado y pruebas automatizadas, pero aquí se implementan los requisitos solicitados: **Docker + SQL Server + Secrets + trigger set-based + inventario + CSV como Artifact**. El proyecto demuestra el funcionamiento de la lógica y una integración continua reproducible, no un despliegue productivo persistente.

**Fuentes:** [SQL Server en Docker (Microsoft)](https://learn.microsoft.com/es-es/sql/linux/quickstart-install-connect-docker) · [Parámetros de tipo tabla (Microsoft)](https://learn.microsoft.com/es-es/sql/relational-databases/tables/use-table-valued-parameters-database-engine) · [Eventos de GitHub Actions](https://docs.github.com/es/actions/reference/workflows-and-actions/events-that-trigger-workflows).
