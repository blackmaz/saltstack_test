{%- set company    = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set t          = salt['pillar.get'](company+':'+system+':software:tomcat') %}

stop-tomcat:
  cmd.run:
    - name: kill $(ps -ef | grep java | grep -v grep | awk '{print $2}')
    - onlyif: test -n `ps -ef | grep java | grep -v grep | awk '{print $2}'`

delete_inst_home:
  file.absent:
    - name: {{ t.install.insthome }}
