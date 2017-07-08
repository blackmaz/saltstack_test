{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}

{%- if grains['os_family'] == 'RedHat' %}
mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ root_pwd }}
    - password_hash: 'hash'
    - connection_user: root
{%- endif %}
