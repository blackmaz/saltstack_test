{%- set admin = 'nagiosadmin' %}
{%- set admin_pwd = 'ehrtnfl5' %}
{%- set nagios = salt['grains.filter_by']({
  'Debian': {
    'http_server': 'apache2',
    'php_server': 'php'
  },
  'RedHat': {
    'http_server': 'httpd',
    'php_server': 'php'
  }
} ) %}

# Nagios Master Node

include:
  - nagios.httpd
  - nagios.require
  - nagios.core
  - nagios.plugin
  - nagios.nrpemaster

nagios_restart:
  module.run:
    - name: service.restart
    - m_name: nagios

httpd_restart:
  module.run:
    - name: service.restart
    - m_name: {{ nagios.http_server }}
    - require:
      - module: nagios_restart

# Web Access를 위한 기본 사용자 생성
httpd_passwd:
  webutil.user_exists:
    - name: {{ admin }} 
    - password: {{ admin_pwd }} 
    - htpasswd_file: /usr/local/nagios/etc/htpasswd.users
    - require:
      - module: httpd_restart

