{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set root_pwd= salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}

{% if grains['os_family'] == 'Debian'%}

set_mysql_rootpassword:
  cmd.run:
    - name: sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password {{ root_pwd }}'

set_mysql_rootpassword_again:
  cmd.run:
    - name: sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password {{ root_pwd }}'

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

{% if grains['os_family'] == 'Redhat'%}
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
    - watch:
      - pkg: mysql
      - file: mysql_append
{% endif %}

{{ firewall.firewall_open('3306', require='service: mysql_service') }}
