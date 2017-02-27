# 
{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'apache/map.jinja' import apache with context %}
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
    - require:
      - service: apache

sites-available:
  file.directory:
    - name: {{ apache.siteavailable }}
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: config_file

sites-enabled:
  file.directory:
    - name: {{ apache.siteenabled }}
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: config_file

default_site:
  file.managed:
    - source: salt://apache/conf/_{{ apache.configsitefile }}
    - name: {{ apache.siteavailable }}/{{ apache.configsitefile }}
    - template: jinja
    - context:
      doc_root: {{ apache.doc_root }}
      log_root: {{ apache.log_root }}
    - require:
      - file: sites-available
      - file: sites-enabled

default_site_enabled:
  file.symlink:
    - target: {{ apache.siteavailable }}/{{ apache.configsitefile }}
    - name: {{ apache.siteenabled }}/{{ apache.configsitefile }}
    - require:
      - file: default_site

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






