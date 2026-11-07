# Evidencias que debes capturar en TU cuenta de GitHub

No se adjuntan capturas falsas. Toma estas capturas cuando ejecutes los workflows:

1. **Repositorio completo:** pestaña Code con .github/, sql/, scripts/, docs/ y README.md.
2. **Secret configurado:** Settings > Secrets and variables > Actions. Captura solo el NOMBRE MSSQL_SA_PASSWORD; nunca muestres su valor.
3. **Workflow 01 en verde:** Actions > 01 - Desplegar y probar SQL Server > ejecución con marca verde.
4. **Pruebas SQL:** abre la ejecución > desplegar > Probar ventas, trigger, auditoria e inventario; muestra el mensaje 'PRUEBAS CORRECTAS' y los resultados.
5. **Workflow 02 en verde:** Actions > 02 - Reporte programado de ventas CSV > ejecución.
6. **Artifact:** parte inferior de la ejecución del workflow 02, sección Artifacts, con 'reporte-ventas-csv'.
7. **CSV:** captura el archivo 'reporte_ventas.csv' abierto en un editor o Excel/Sheets y sus cinco ventas.

Guardar las imágenes aquí si deseas incluirlas en el repositorio. Evita nombres, contraseñas o datos privados que no correspondan a la entrega.
