{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'nginx/map.jinja' import nginx with context %}
{%- set os = grains['os'] %}
{%- set selinux_enabled = salt['grains.get']('selinux:enabled') %}

nginx:
  pkg.installed:
    - name: {{ nginx.server }} 
  service.running:
    - name: {{ nginx.service }}
    - enable: True
    - watch:
      - pkg: nginx

{{ firewall.firewall_open('80', require='service: nginx') }}

config_file: 
  file.managed:
    - source: salt://nginx/conf/_{{ nginx.configfile }}.{{ os }}
    - name : {{ nginx.configdir }}/{{ nginx.configfile }} 
    - user: root
    - group: root
    - mode: '640'
    - template: jinja
    - require:
      - service: nginx

sites-available:
  file.directory:
    - name: {{ nginx.siteavailable }}
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: config_file

sites-enabled: 
  file.directory:
    - name: {{ nginx.siteenabled }}
    - user: root
    - group: root
    - dir_mode: 755
    - require:
      - file: config_file

default_site:
  file.managed:
    - source: salt://nginx/conf/_{{ nginx.configsitefile }}.{{ os }}
    - name: {{ nginx.siteavailable }}/{{ nginx.configsitefile }}
    - template: jinja
    - context:
      doc_root: {{ nginx.doc_root }}
      log_root: {{ nginx.log_root }}
    - require:
      - file: sites-available
      - file: sites-enabled

default_site_enabled:
  file.symlink:
    - target: {{ nginx.siteavailable }}/{{ nginx.configsitefile }}
    - name: {{ nginx.siteenabled }}/{{ nginx.configsitefile }}
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


