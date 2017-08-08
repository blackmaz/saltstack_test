###################################
# web application deploy sls
###################################
{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set t          = salt['pillar.get'](company+':'+system+':software:tomcat') %}

{%- if t.server.deploy_file == 'petclinic.war' %}

shutdown-tomcat-fordeploy:
  cmd.run:
    - name: kill $(ps -ef | grep java | grep -v grep | awk '{print $2}');sleep 5

{{ t.install.home }}/webapps/petclinic.war:
  file.managed:
    - source: https://s3.ap-northeast-2.amazonaws.com/itsbox/apps/{{ t.server.name }}/{{ t.server.deploy_file }}
    - mode: 755
    - skip_verify: true

start-tomcat-fordeploy:
  cmd.run:
    - name: {{ t.install.home }}/bin/startup.sh;sleep 5

{{ t.install.home }}/{{ t.server.app_base }}/petclinic/WEB-INF/classes/spring/data-access.properties:
  file.managed:
    - source: salt://apps/petclinic/conf/_data-access.properties
    - mode: 755
    - template: jinja
    - context:
        datasource_ip: {{ t.server.datasource_ip }}

shutdown-tomcat-afterdeploy:
  cmd.run:
    - name: kill $(ps -ef | grep java | grep -v grep | awk '{print $2}');sleep 5

start-tomcat-afterdeploy:
  cmd.run:
    - name: {{ t.install.home }}/bin/startup.sh;sleep 5

{%- endif %}
