{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set service_port = salt['pillar.get'](company+':'+system+':software:mysql:service_port','3306') %}
{%- set root_pwd = salt['pillar.get'](company+':'+system+':software:mysql:root:pwd','') %}

{%- if grains['os_family'] == 'Debian' %}
mysql-debconf:
  debconf.set:
    - name: {{ mysql.server }}
    - data:
        'mysql-server/root_password': {'type': 'string', 'value':'{{root_pwd}}'}
        'mysql-server/root_password_again': {'type':'string', 'value':'{{root_pwd}}'}
{%- endif %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

mysql_cfg:
  file.managed:
    - name: {{ mysql.cfg }}
    - source: salt://mysql/conf/my.cnf.{{ grains['os'] }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
      company: {{company}}
      system: {{system}}
      service_port: {{service_port}}

mysql_service:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
      - file: mysql_cfg

{{ firewall.firewall_open(service_port, require='service: mysql_service') }}


