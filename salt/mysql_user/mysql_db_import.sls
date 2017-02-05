{% set mysql_root_pwd = pillar['db_server']['root_password'] %}

/tmp/dbdump.sql:
  file.managed:
    - source: salt://mysql_user/ozr_dbdump.sql
    - user: root
    - group: root
    - mode: 644

mysql_db_import:
  cmd.run:
    - name: mysql -u root -p'{{ mysql_root_pwd|replace("'", "'\"'\"'") }}' <  /tmp/dbdump.sql
    - require:
      - file: /tmp/dbdump.sql
