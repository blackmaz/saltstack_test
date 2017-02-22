{% set mysql_root_pwd = pillar['db_server']['root_password'] %}

mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ mysql_root_pwd }}
