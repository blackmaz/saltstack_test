{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'mysql/map.jinja' import mysql with context %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}

{% if grains['os_family'] == 'Debian'%}
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
mysql_service:
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
      - file: mysql_append
{% endif %}

{{ firewall.firewall_open('3306', require='service: mysql_service') }}



