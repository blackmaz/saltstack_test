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
remove_mysql:
  pkg.removed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}
  pkg.purged:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}
