# Proyecto Integrador: GitHub Actions + Docker + Microsoft SQL Server

Automatización de **EmpresaDB** con SQL Server 2022 Developer, Docker y GitHub Actions. Cada ejecución parte de un contenedor temporal, crea la base, registra ventas, prueba el trigger para inserciones múltiples y actualiza inventario. Un segundo workflow genera un CSV y lo publica como Artifact.

## Objetivos cumplidos

- [x] Docker ejecutado en un runner hospedado por GitHub (sin instalar programas localmente).
- [x] Base `EmpresaDB`, tablas `Ventas` y `AuditoriaVentas`.
- [x] Procedimiento `sp_RegistrarAuditoria` y trigger `trg_AuditarVenta`.
- [x] Contraseña del administrador guardada en `MSSQL_SA_PASSWORD` (GitHub Secret).
- [x] Reto principal: `inserted` e inserciones múltiples con procesamiento por conjuntos.
- [x] Reto avanzado: tabla `Inventario` y descuento de existencias desde el procedimiento.
- [x] Pruebas automáticas de 5 ventas, 5 auditorías e inventario final.
- [x] Segundo workflow programado y activable manualmente que publica un CSV como Artifact.
- [x] Documento técnico en `docs/documento_tecnico.md` y `docs/documento_tecnico.pdf`.
- [ ] Evidencias reales: captura los workflows ejecutados en tu propia cuenta.

## Estructura

```text
proyecto-sqlserver-actions/
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── reporte.yml
├── sql/
│   ├── create_database.sql
│   ├── create_tables.sql
│   ├── create_procedure.sql
│   ├── create_trigger.sql
│   ├── test_data.sql
│   ├── verify.sql
│   └── report.sql
├── scripts/
│   └── setup_db.sh
├── docs/
│   ├── documento_tecnico.md
│   ├── documento_tecnico.pdf
│   └── evidencias/
│       └── README.md
└── README.md
```

## Configuración SIN instalar Docker ni SQL Server

1. En GitHub crea un repositorio público nuevo llamado `proyecto-sqlserver-actions`, con rama principal `main`. Si lo creas con README, sustituye su contenido por el de este proyecto.
2. Descomprime el archivo ZIP descargado del proyecto en tu computadora.
3. Antes de agregar los workflows, abre el repositorio > **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.
4. En **Name** escribe exactamente `MSSQL_SA_PASSWORD`. En **Secret** pega una contraseña de SQL Server fuerte y exclusiva (al menos 8 caracteres, con distintos tipos de caracteres). Presiona **Add secret**. No escribas la contraseña en ningún archivo del repositorio.
5. En la pestaña **Code**, usa **Add file > Upload files**. Arrastra **el contenido** de la carpeta descomprimida (las carpetas `.github`, `sql`, `scripts`, `docs` y `README.md`), conservando la estructura; pulsa **Commit changes**. Si tu navegador no muestra `.github` (carpeta oculta), usa la opción **Create new file** con la ruta `.github/workflows/deploy.yml` y luego `.github/workflows/reporte.yml`.
6. En **Actions**, entra a `01 - Desplegar y probar SQL Server` > **Run workflow** > **Run workflow**. Un check verde indica que pasó todo.
7. Ejecuta también `02 - Reporte programado de ventas CSV` mediante **Run workflow**. Al terminar, abre la ejecución y descarga el Artifact `reporte-ventas-csv`.
8. Realiza las capturas descritas en `docs/evidencias/README.md`.

> Importante: para estas pruebas SQL Server vive **solo durante la ejecución del workflow**. Al finalizar se elimina la máquina temporal. El segundo workflow crea una nueva instancia y repite los datos de prueba antes de generar el CSV. No es un servidor de producción persistente.

## Cómo comprobar que funciona

- El workflow 01 debe mostrar: `PRUEBAS CORRECTAS: 5 ventas, 5 auditorias e inventario actualizado.`
- Ventas: Laptop (3), Monitor (5), Laptop (2), Monitor (1), Mouse (4).
- Auditorías: 5 registros, uno por cada venta.
- Inventario final: Laptop 5, Monitor 6, Mouse 16.
- El workflow 02 debe publicar `reporte-ventas-csv`, que contiene `reporte_ventas.csv` con 1 encabezado y 5 ventas.

## Programación del segundo workflow

En `.github/workflows/reporte.yml` se usa:

```yaml
schedule:
  - cron: '17 14 * * 1'
```

Esto solicita una ejecución semanal, los lunes a las 14:17 **UTC**. GitHub puede iniciar trabajos programados con retraso; además solo los ejecuta desde la rama predeterminada. Para la evidencia, es más práctico probarlo manualmente mediante `workflow_dispatch`.

## Seguridad

El nombre del Secret es **MSSQL_SA_PASSWORD**. Usamos esa variable en Docker porque Microsoft desaconseja el antiguo nombre de variable `SA_PASSWORD` dentro del contenedor. `ACCEPT_EULA=Y` y `MSSQL_PID=Developer` se establecen en los workflows. Las contraseñas no se suben al repositorio ni deben aparecer en las capturas.

## Documentación y evidencias

Explicación de GitHub, Actions, Docker, SQL Server, Secret, `inserted`, tipo tabla, procedimientos, conjuntos, inventario y reportes: [`docs/documento_tecnico.md`](docs/documento_tecnico.md). PDF de entrega: [`docs/documento_tecnico.pdf`](docs/documento_tecnico.pdf). Guía de capturas: [`docs/evidencias/README.md`](docs/evidencias/README.md).

## Relación con la referencia del docente

El repositorio de referencia es `jesusrevilla/T41A-P16` (PostgreSQL). Mantenemos la lógica general de **repositorio + README + GitHub Actions + pruebas**, pero nuestra implementación usa exclusivamente **SQL Server en Docker**, archivos `.sql`, Secrets, trigger set-based, inventario y CSV programado. No necesitamos `requirements.txt` ni `pytest` de PostgreSQL.

## Fuentes técnicas

- [SQL Server en contenedores - Microsoft](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
- [Eventos programados en Actions - GitHub](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
- [Table-valued parameters - Microsoft](https://learn.microsoft.com/en-us/sql/relational-databases/tables/use-table-valued-parameters-database-engine)
