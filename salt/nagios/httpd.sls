# Nagios Master Node에 Web UI를 구동하기 위해 Apache+PHP를 설치한다.
# wget, unzip은 파일 다운로드와 압축 해제에 필요하다.
{%- import 'common/firewall.sls' as firewall with context %}
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

nagios_pre_install:
  pkg.installed:
    - pkgs:
      - {{ nagios.http_server }}
      - {{ nagios.php_server }}
{%- if grains['os_family']=="Debian" %}
      - libapache2-mod-php
{%- endif %}

{%- if grains['os_family']=="Debian" %}
install-proxy-module:
  cmd.run:
    - name: a2enmod rewrite;a2enmod cgi;
{%- endif %}


{{ firewall.firewall_open('80', require='pkg: nagios_pre_install') }}

httpd_service_running:
  service.running:
    - name: {{ nagios.http_server }}
    - enable: True
    - require:
      - pkg: nagios_pre_install
