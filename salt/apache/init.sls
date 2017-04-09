
{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set a = salt['pillar.get'](company+':'+system+':software:apache',{}) %}

{%- from 'apache/map.jinja' import apache with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - apache.install
{%- if a.get('vhosts','null') != 'null' %}
  - apache.vhost
{%- endif %}
{%- if a.get('modjk','null') != 'null' %}
  - apache.modjk
{%- endif %}
{%- if a.get('openssl',False) == True %}
  - apache.openssl
{%- endif %}

{{ service.service_restart(apache.service) }}


