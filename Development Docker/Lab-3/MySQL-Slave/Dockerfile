# Use the latest MySQL image from Docker Hub
FROM mysql:8.0

# Set the environment variables for the MySQL slave
ENV MYSQL_ROOT_PASSWORD=12345
ENV MYSQL_DATABASE=Test 
ENV MYSQL_USER=ReplicationUser
ENV MYSQL_PASSWORD=12345

# Configure MySQL for replication
CMD ["--server-id=2", "--log-bin=mysql-bin", "--binlog-format=row"]
