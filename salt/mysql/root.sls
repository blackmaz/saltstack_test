{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}

{%- if grains['os_family'] == 'Debian' %}
#mysql_root_password:
#  module.run:
#    - name: mysql.query
#    - database: mysql
#    - query: alter user 'root'@'localhost' identified with mysql_native_password by '{{root_pwd}}'
#    - connection_user: root
#    - connection_pass: {{ root_pwd }}
{%- else %}
mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ root_pwd }}
    - password_hash: 'hash'
    - connection_user: root
{%- endif %}
