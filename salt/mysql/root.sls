{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}

mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ root_pwd }}
#  module.run:
#    - name: mysql.query
#    - database: mysql
#    - query: alter user 'root'@'localhost' identified with mysql_native_password by 'manager365'
#    - default-auth: mysql_native_password
    - connection_user: root
    - connection_pass: manager365
    - connection_host: localhost
