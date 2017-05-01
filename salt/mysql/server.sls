{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}


{% if grains['os_family'] == 'Debian'%}
mysql-debconf:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'string', 'value': '{{ root_pwd }}'}
        'mysql-server/root_password_again': {'type': 'string', 'value': '{{ root_pwd }}'}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

mysql_comment:
  file.comment:
    - name: {{ mysql.cfg }}
    - regex: ^bind-address
    - require:
      - pkg: mysql

mysql_append:
  file.append:
    - name: {{ mysql.cfg }}
    - text: lower_case_table_names = 1
    - require:
      - file: mysql_comment
{% endif %}

{% if grains['os_family'] == 'RedHat'%}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

mysql_service:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - require:
      - pkg: mysql

mysql_root_password:
  module.run:
    - name: mysql.user_chpass
    - user: root
    - host: localhost
    - password: {{ root_pwd }}
    - require:
      - service: mysql_service

{% endif %}

{{ firewall.firewall_open('3306', require='service: mysql_service') }}
