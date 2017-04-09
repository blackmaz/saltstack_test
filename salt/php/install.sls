{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set php_cfg = salt['pillar.get'](company+':'+system+':software:php:cfg',{}) %}

{%- import 'common/firewall.sls' as firewall with context %}
{%- from 'php/map.jinja' import php with context %}
{%- set os = grains['os'] %}


php:
  pkg.installed:
{% if php.repository != '' %}
    - enablerepo: {{ php.repository }}
{% endif %}
    - pkgs:
      - {{ php.php }}
      - {{ php.fpm }}
      - {{ php.mysql }}
  service.running:
    - name: {{ php.service }}
    - enable: True
    - watch:
      - pkg: php
      - file: {{ php.cfg }}

{{ firewall.firewall_open('9000', require='service: php') }}

{{ php.cfg }}:
  file.managed:
    - source: salt://php/conf/_www.conf.{{ os }} 
    - template: jinja
    - context:
        listen_addr: {{ php_cfg.listen_addr }}
        listen_port: {{ php_cfg.listen_port }}
        listen_allowed_client: {{ php_cfg.allowed_clients }} #listen.allowed_clients = 127.0.0.1



