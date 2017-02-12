{%- import 'common/firewall.sls' as firewall with context %}
{%- set apache = salt['grains.filter_by']({
  'Debian': {
    'server': 'apache2',
    'service': 'apache2',
    'configdir': '/etc/apache2',
    'configfile': 'apache2.conf',
    'siteavailable': '/etc/apache2/sites-available',
    'siteenabled': '/etc/apache2/sites-enabled',
    'configsitefile': '000-default.conf',
    'doc_root': '/var/www/html',
    'log_root': '/var/log/apache2'
  },
  'RedHat': {
    'server': 'httpd',
    'service': 'httpd',
    'configdir': '/etc/httpd/conf',
    'configfile': 'httpd.conf',
    'siteavailable': '/etc/httpd/sites-available',
    'siteenabled': '/etc/httpd/sites-enabled',
    'configsitefile': '000-default.conf',
    'doc_root': '/var/www/html',
    'log_root': '/var/log/httpd'
  },
})
%}
{%- set selinux_enabled = salt['grains.get']('selinux:enabled') %}

apache:
  pkg.installed:
    - name: {{ apache.server }}
  service.running:
    - name: {{ apache.service }}
    - enable: True
    - watch:
      - pkg: apache

{{ firewall.firewall_open('80', require='service: apache') }}

{%- if grains['os_family']=="Debian" %}
install-proxy-module:
  cmd.run:
    - name: a2enmod proxy;a2enmod proxy_http;
{% endif %}

config_file:
  file.managed:
    - source: salt://apache/conf/_{{ apache.configfile }}
    - name: {{ apache.configdir }}/{{ apache.configfile }}
    - user: root
    - group: root
    - mode: '640'
    - template: jinja

sites-available:
  file.directory:
    - name: {{ apache.siteavailable }}
    - user: root
    - group: root
    - dir_mode: 755

sites-enabled:
  file.directory:
    - name: {{ apache.siteenabled }}
    - user: root
    - group: root
    - dir_mode: 755

default_site:
  file.managed:
    - source: salt://apache/conf/_{{ apache.configsitefile }}
    - name: {{ apache.siteavailable }}/{{ apache.configsitefile }}
    - template: jinja
    - context:
      doc_root: {{ apache.doc_root }}
      log_root: {{ apache.log_root }}

default_site_enabled:
  file.symlink:
    - target: {{ apache.siteavailable }}/{{ apache.configsitefile }}
    - name: {{ apache.siteenabled }}/{{ apache.configsitefile }}

{%- if selinux_enabled %}
install_policycoreutils:
  pkg.installed:
    - name: policycoreutils-python

selinux_data_haw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_anon_write
    - value: On
    - persist: True

selinux_data_hssaw:
  module.run:
    - name: selinux.setsebool
    - boolean: httpd_sys_script_anon_write
    - value: On
    - persist: True
{%- endif %}

restart_{{ apache.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ apache.service }}




