{%- set m = salt['pillar.get']('software:postgresql',{}) %}
{%- from 'postgresql/map.jinja' import postgresql with context %}

include:
  - postgresql.server

restart_{{ postgresql.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ postgresql.service }}
