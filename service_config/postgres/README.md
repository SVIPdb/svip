This folder is mapped to /docker-entrypoint-initdb.d within the postgres container. On the first execution of the container, any .sql, .sql.gz, or .sh files inside the folder will be executed.
