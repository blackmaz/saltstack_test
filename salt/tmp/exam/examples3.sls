Make sure the mysql service is running:
  pkg.installed:
    - name: mariadb
    - name: mariadb-server
  service.running:
    - name: mariadb

