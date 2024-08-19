#!/bin/bash

# Variables de configuración
NETWORK_NAME="mysql-replication"
MASTER_CONTAINER_NAME="mysql-master"
SLAVE_CONTAINER_NAME="mysql-slave"
MYSQL_ROOT_PASSWORD="rootpassword"
MYSQL_REPLICATION_USER="repl_user"
MYSQL_REPLICATION_PASSWORD="repl_password"
MYSQL_DATABASE="mydatabase"
MYSQL_IMAGE="mysql:8.0"

# Eliminar contenedores anteriores si existen
docker rm -f $MASTER_CONTAINER_NAME $SLAVE_CONTAINER_NAME

# Eliminar la red Docker si existe
docker network rm $NETWORK_NAME

# Crear la red Docker
docker network create $NETWORK_NAME

# Iniciar el contenedor Maestro
docker run -d --name $MASTER_CONTAINER_NAME \
  --network $NETWORK_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  $MYSQL_IMAGE

# Esperar a que el contenedor Maestro inicie
echo "Esperando a que el contenedor Maestro inicie..."
sleep 30

# Obtener información del binlog del Maestro
MASTER_STATUS=$(docker exec $MASTER_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G")
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

# Verificar que las variables se capturaron correctamente
if [ -z "$MASTER_LOG_FILE" ] || [ -z "$MASTER_LOG_POS" ]; then
  echo "Error: No se pudo obtener la información del binlog del maestro."
  exit 1
fi

# Iniciar el contenedor Esclavo
docker run -d --name $SLAVE_CONTAINER_NAME \
  --network $NETWORK_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  $MYSQL_IMAGE

# Esperar a que el contenedor Esclavo inicie
echo "Esperando a que el contenedor Esclavo inicie..."
sleep 30

# Configurar la replicación en el Esclavo
docker exec $SLAVE_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CHANGE MASTER TO MASTER_HOST='$MASTER_CONTAINER_NAME', MASTER_USER='$MYSQL_REPLICATION_USER', MASTER_PASSWORD='$MYSQL_REPLICATION_PASSWORD', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS, GET_MASTER_PUBLIC_KEY=1;"
docker exec $SLAVE_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "START SLAVE;"

# Verificar la replicación
SLAVE_STATUS=$(docker exec $SLAVE_CONTAINER_NAME mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SHOW SLAVE STATUS\G")

echo "Replicación configurada. Estado del esclavo:"
echo "$SLAVE_STATUS"
