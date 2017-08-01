{%- import 'common/firewall.sls' as firewall with context %}

{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- from 'mysql/map.jinja' import mysql with context %}

# mysql service stop
stop_mysql_service:
  service.dead:
    - name: {{ mysql.service }}
    - enable: True

# remove mysql, and config files
purge_mysql:
  pkg.purged:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}
      - mysql-common

{%- if grains['os_family'] == 'Debian' %}
/etc/mysql:
  file.absent:
    - name: /etc/mysql

/var/lib/mysql:
  file.absent:
    - name: /var/lib/mysql

/var/lib/mysql-keyring:
  file.absent:
    - name: /var/lib/mysql-keyring

/var/lib/mysql-upgrade:
  file.absent:
    - name: /var/lib/mysql-upgrade

/var/log/mysql:
  file.absent:
    - name: /var/log/mysql
{%- endif %}

