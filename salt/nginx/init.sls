{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set a = salt['pillar.get'](company+':'+system+':software:nginx',{}) %}

{%- from 'nginx/map.jinja' import nginx with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - nginx.install
{%- if a.get('vhosts') != {} %}
  - nginx.vhost
{%- endif %}
#{%- if a.get('modjk') != {} %}
#  - nginx.modjk
#{%- endif %}
{%- if a.get('openssl') == True %}
  - nginx.openssl
{%- endif %}

{{ service.service_restart(nginx.service) }}


