{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'mysql/map.jinja' import mysql with context %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

{% if grains['os'] == 'Ubuntu'%}
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

mysql_service:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
{% if grains['os'] == 'Ubuntu'%}
      - file: mysql_append
{% endif %}

{{ firewall.firewall_open('3306', require='service: mysql_service') }}

restart_{{ mysql.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ mysql.service }}
    - require:
      - service: mysql_service

