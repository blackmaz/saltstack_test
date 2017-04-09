{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set a = salt['pillar.get'](company+':'+system+':software:nginx',{}) %}

{%- from 'nginx/map.jinja' import nginx with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - nginx.install
{%- if a.get('vhosts','null') != 'null' %}
  - nginx.vhost
{%- endif %}
#{%- if a.get('modjk','null') != 'null' %}
#  - nginx.modjk
#{%- endif %}
{%- if a.get('openssl',False) == True %}
  - nginx.openssl
{%- endif %}

{{ service.service_restart(nginx.service) }}


