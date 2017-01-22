{%- from 'tomcat/settings.sls' import tomcat with context %}

download-sample-war:
  cmd.run:
    - name: curl -s -L -o {{ tomcat.salt_tomcat_filedir }}/{{ tomcat.deploy_war }} {{ tomcat.deploy_downloadurl }}
    - unless: test -f {{ tomcat.salt_tomcat_filedir }}/{{ tomcat.deploy_war }}

deploy-sample-war:
  cmd.run:
    - name: cp {{ tomcat.salt_tomcat_filedir }}/{{ tomcat.deploy_war }} {{ tomcat.tomcat_home }}/webapps/{{ tomcat.deploy_war }}
    - unless: test -f {{ tomcat.tomcat_home }}/webapps/{{ tomcat.deploy_war }}

remove-sample-war:
  file.absent:
    - name: {{ tomcat.salt_tomcat_filedir }}/{{ tomcat.deploy_war }}
