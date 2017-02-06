{%- from 'tomcat/settings.sls' import tomcat with context %}
{%- set deploy_war = 'petclinic.war' %}
{%- set deploy_downloadurl = 'https://www.dropbox.com/s/vjnjxbb921jneet/petclinic.war?dl=0' %}

download-sample-war:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ deploy_war }} {{ deploy_downloadurl }}
    - unless: test -f '/tmp/'{{ deploy_war }}

deploy-sample-war:
  cmd.run:
    - name: cp '/tmp/'{{ deploy_war }} {{ tomcat.tomcat_home }}/webapps/{{ deploy_war }}
    - unless: test -f {{ tomcat.tomcat_home }}/webapps/{{ deploy_war }}

#remove-sample-war:
#  file.absent:
#    - name: {{ tomcat.salt_tomcat_filedir }}/{{ deploy_war }}
