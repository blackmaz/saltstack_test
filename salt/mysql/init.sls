{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set m             = salt['pillar.get'](company+':'+system+':software:mysql','') %}
{%- from 'mysql/map.jinja' import mysql with context %}
{%- import 'common/service.sls' as service with context %}

include:
  - mysql.server
{%- if m.get('root','null') != 'null' %}
  - mysql.root
{%- endif %}
{%- if m.get('databases','null') != 'null' %}
  - mysql.databases
{%- endif %}

{{ service.service_restart(mysql.service) }}
