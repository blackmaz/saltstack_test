{% import 'common/firewall.sls' as firewall with context %}
{% set mysql_root_pwd = pillar['db_server']['root_password'] %}
{% set mysql = salt['grains.filter_by'] ({
  'Ubuntu': {
    'server': 'mysql-server',
    'client': 'mysql-client',
    'python': 'python-mysqldb',
    'service': 'mysql'
  },
  'CentOS': {
    'server': 'mariadb-server',
    'client': 'mariadb',
    'python': 'MySQL-python',
    'service': 'mariadb'
  },
  'default': 'Ubuntu',
}, grain='os') %}

mysql:
  pkg.installed:
    - pkgs:
      - {{ mysql.server }}
      - {{ mysql.client }}
      - {{ mysql.python }}
  service.running:
    - name: {{ mysql.service }}
    - enable: True
    - watch:
      - pkg: mysql
  mysql_user.present:
    - name: root
    - password: {{ mysql_root_pwd }}
    - require:
      - service: mysql

{{ firewall.firewall_open('3306', require='service: mysql') }}

#add_port_3306:
#  module.run:
#    - name: firewalld.add_port
#    - zone: public
#    - port: 3306/tcp
#    - require:
#      - service: maria
#
#reload_firewall_rule:
#  module.run:
#    - name: firewalld.reload_rules
#    - require:
#      - module: add_port_3306
