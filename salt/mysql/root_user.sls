{% set mysql_root_pwd = pillar['db_server']['root_password'] %}

mysql_root:
  mysql_user.present:
    - name: root
    - password: {{ mysql_root_pwd }}

