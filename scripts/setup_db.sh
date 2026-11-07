#!/usr/bin/env bash
# GitHub Actions ejecuta este script en una máquina Ubuntu con Docker instalado.
set -euo pipefail

if [[ -z "${MSSQL_SA_PASSWORD:-}" ]]; then
  echo '::error::Falta el secret MSSQL_SA_PASSWORD en GitHub Actions.'
  exit 1
fi

CONTENEDOR="empresa-sqlserver"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"

echo 'Iniciando SQL Server 2022 Developer mediante Docker...'
docker run --detach \
  --name "$CONTENEDOR" \
  --env ACCEPT_EULA \
  --env MSSQL_PID \
  --env MSSQL_SA_PASSWORD \
  --publish 127.0.0.1:1433:1433 \
  mcr.microsoft.com/mssql/server:2022-latest

listo=0
for intento in $(seq 1 90); do
  if docker exec \
      -e "SQLCMDPASSWORD=$MSSQL_SA_PASSWORD" \
      "$CONTENEDOR" "$SQLCMD" \
      -S localhost -U sa -C -b -Q 'SELECT 1;' >/dev/null 2>&1; then
    listo=1
    break
  fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTENEDOR")" == 'false' ]]; then
    echo '::error::El contenedor SQL Server se detuvo.'
    docker logs "$CONTENEDOR" 2>&1 | tail -n 100
    exit 1
  fi
  sleep 2
done

if [[ "$listo" -ne 1 ]]; then
  echo '::error::SQL Server no respondió antes del tiempo límite.'
  docker logs "$CONTENEDOR" 2>&1 | tail -n 100
  exit 1
fi

echo 'SQL Server listo. Creando base de datos, tablas y lógica de negocio...'

for archivo in \
  sql/create_database.sql \
  sql/create_tables.sql \
  sql/create_procedure.sql \
  sql/create_trigger.sql \
  sql/test_data.sql; do
  echo "Ejecutando: $archivo"
  docker exec -i \
    -e "SQLCMDPASSWORD=$MSSQL_SA_PASSWORD" \
    "$CONTENEDOR" "$SQLCMD" \
    -S localhost -U sa -C -b -d master -i /dev/stdin < "$archivo"
done

echo 'Base de datos EmpresaDB configurada correctamente.'
