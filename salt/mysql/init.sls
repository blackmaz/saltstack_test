{% import 'common/firewall.sls' as firewall with context %}
{% set mysql = salt['grains.filter_by'] ({
  'Ubuntu': {
    'server': 'mysql-server',
    'client': 'mysql-client',
    'python': 'python-mysqldb',
    'service': 'mysql',
    'cfg': '/etc/mysql/mysql.conf.d/mysqld.cnf'
  },
  'CentOS': {
    'server': 'mariadb-server',
    'client': 'mariadb',
    'python': 'MySQL-python',
    'service': 'mariadb',
    'cfg': '/etc/my.cnf.d/server.cnf'
  },
  'default': 'Ubuntu',
}, grain='os') %}
{% set mysql_root_pwd = pillar['db_server']['root_password'] %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}
{% if grains['os'] == 'Ubuntu'%}
  file.comment:
    - name: {{ mysql.cfg }}
    - regex: ^bind-address
{% endif %}
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
{% if grains['os'] == 'Ubuntu'%}
      - file: mysql
{% endif %}

{{ firewall.firewall_open('3306', require='service: mysql') }}

mysql_root_password:
  cmd.run:
    - name: mysqladmin --user root password '{{ mysql_root_pwd|replace("'", "'\"'\"'") }}'
    - unless: mysql --user root --password='{{ mysql_root_pwd|replace("'", "'\"'\"'") }}' --execute="SELECT 1;"
    - require:
      - service: mysql
