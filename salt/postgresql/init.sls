{%- set company = salt['pillar.get']('company','default') %}
{%- set system = salt['pillar.get']('system','default') %}
{%- set m = salt['pillar.get'](company+':'+system+':software:postgresql',{}) %}

{%- from 'postgresql/map.jinja' import postgresql with context %}

include:
  - postgresql.server

restart_{{ postgresql.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ postgresql.service }}
