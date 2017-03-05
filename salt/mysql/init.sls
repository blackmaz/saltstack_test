{%- set m = salt['pillar.get']('software:mysql',{}) %}
{%- from 'mysql/map.jinja' import mysql with context %}

include:
  - mysql.server
{%- if m.get('root') != {} %}
  - mysql.root
{%- endif %}
{%- if m.get('databases') != {} %}
  - mysql.databases
{%- endif %}

restart_{{ mysql.service }}:
  module.run:
    - name: service.restart
    - m_name: {{ mysql.service }}
