
{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set t       = salt['pillar.get'](company+':'+system+':software:tomcat',{}) %}
{%- from 'tomcat/map.jinja' import tomcat with context %}

include:
  - java.{{ t.jdk }}
  - tomcat.install
{%- if t.get('server','null') != 'null' %}
  - tomcat.server
{%- if t.server.get('deploy_file','null') != 'null' %}
  - tomcat.deploy_{{ t.server.name }}
{%- endif %}

{%- endif %}
# 바로 서비스 시작
startup-tomcat:
  cmd.run:
    - name: {{ t.install.insthome }}/{{ tomcat.dirname }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | grep -v grep | awk '{print $2}'`
