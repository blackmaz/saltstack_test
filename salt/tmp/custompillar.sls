
{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set t       = salt['pillar.get'](company+':'+system+':software:tomcat',{}) %}
{%- from 'tomcat/map.jinja' import tomcat with context %}

test_pillar:
  cmd.run:
    - name: ls -l {{ company }}

test_pillar_2:
  cmd.run:
    - name: ls -l {{ system }}
