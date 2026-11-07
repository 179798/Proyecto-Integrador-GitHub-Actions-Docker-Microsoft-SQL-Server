# Proyecto Integrador: GitHub Actions + Docker + SQL Server

Este repositorio automatiza la creación y las pruebas de **EmpresaDB** en **Microsoft SQL Server 2022**, ejecutado con **Docker** dentro de **GitHub Actions**. Incluye auditoría automática de ventas, control de inventario y un reporte CSV.

## ¿Qué hace?

1. `deploy.yml` inicia SQL Server, crea la base de datos y ejecuta los scripts de `sql/`.
2. El trigger `trg_AuditarVenta` registra **todas** las ventas insertadas, incluso cuando se agregan varias a la vez. El procedimiento `sp_RegistrarAuditoria` genera las auditorías y descuenta existencias de `Inventario`.
3. `verify.sql` comprueba **5 ventas, 5 auditorías** y el inventario final: **Laptop 5, Monitor 6 y Mouse 16**.
4. `reporte.yml` genera `reporte_ventas.csv`, lo publica como Artifact **`reporte-ventas-csv`** y está programado para ejecutarse cada lunes a las **14:17 UTC**.

## Estructura

- `.github/workflows/`: despliegue y reporte programado.
- `sql/`: creación de la base, tablas, procedimiento, trigger, datos, verificaciones y reporte.
- `scripts/setup_db.sh`: arranque de Docker y ejecución de SQL.
- `docs/`: [documento técnico](docs/documento_tecnico.md), [PDF](docs/documento_tecnico.pdf) y [guía de evidencias](docs/evidencias/README.md).

## Uso y resultados

1. Crear el Secret de GitHub Actions **`MSSQL_SA_PASSWORD`** en *Settings → Secrets and variables → Actions*; nunca subir la contraseña.
2. En **Actions**, ejecutar **01 - Desplegar y probar SQL Server** y comprobar que finalice en verde.
3. Ejecutar **02 - Reporte programado de ventas CSV** y descargar el Artifact `reporte-ventas-csv`.

**Ejecuciones verificadas:** [pruebas SQL](https://github.com/179798/Proyecto-Integrador-GitHub-Actions-Docker-Microsoft-SQL-Server/actions/runs/42404812456) y [reporte CSV](https://github.com/179798/Proyecto-Integrador-GitHub-Actions-Docker-Microsoft-SQL-Server/actions/runs/42404896834) (7 de noviembre de 2026).

**Alcance:** SQL Server vive en un contenedor *temporal* durante cada ejecución, no en un servidor permanente. El proyecto implementa las tecnologías y los retos de la consigna; el [repositorio de referencia](https://github.com/jesusrevilla/T41A-P16) usa PostgreSQL solo como ejemplo de organización.
