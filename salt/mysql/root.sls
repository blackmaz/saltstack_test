{%- set root_pwd = salt['pillar.get']('software:mysql:root_pwd') %}

mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ root_pwd }}
