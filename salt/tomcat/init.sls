
{%- set company = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set t               = salt['pillar.get'](company+':'+system+':software:tomcat',{}) %}

include:
  - java.{{ t.jdk }}
  - tomcat.install
{%- if t.get('server') != {} %}
  - tomcat.server
{%- endif %}

# 바로 서비스 시작
startup-tomcat:
  cmd.run:
    - name: {{ t.install.home }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | awk '{print $2}'`

