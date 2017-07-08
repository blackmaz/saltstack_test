###################################
# apache-tomcat uninstall sls
###################################
{%- set company    = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set t          = salt['pillar.get'](company+':'+system+':software:tomcat') %}
{%- from 'tomcat/map.jinja' import tomcat with context %}


# 서비스가 기동중이면 종료, kill java process
stop-tomcat:
  cmd.run:
    - name: kill $(ps -ef | grep java | grep -v grep | awk '{print $2}')
    - unless: test -n `ps -ef | grep java | grep -v grep | awk '{print $2}'`

# install home 존재 여부를 확인하고 있으면 삭제
delete_inst_home:
  file.absent:
    - name: {{ t.install.insthome }}
