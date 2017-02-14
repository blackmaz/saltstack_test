{% set tomcat_home = pillar['tomcat']['tomcat_home'] %}
{% set service_ip = pillar['application']['service_ip'] %}
{% set deploy_tar = pillar['application']['deploy_tar'] %}
{% set deploy_downloadurl = pillar['application']['deploy_downloadurl'] %}
{% set datasource_url = pillar['application']['datasource_url'] %}
{% set db_password = pillar['db_server']['root_password'] %}

install-unzip:
  pkg.installed:
    - pkgs:
      - unzip

download-sample-tar:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ deploy_tar }} {{ deploy_downloadurl }}
    - unless: test -f '/tmp/'{{ deploy_tar }}

deploy-sample-tar:
  cmd.run:
    - name: cp '/tmp/'{{ deploy_tar }} {{ tomcat_home }}
    - unless: test -f {{ tomcat_home }}/{{ deploy_tar }}

unpack-sample-tar:
  cmd.run:
    - name: cd {{ tomcat_home }};mv webapps webapps_origin;unzip {{ deploy_tar }}

{{ tomcat_home }}/webapps/WEB-INF/classes/config/properties/system.properties:
    file.managed:
        - source: salt://ozr/conf/system.properties_ozr
        - user: root
        - group: root
        - mode: '740'
        - template: jinja
        - context:
            tomcat_home: {{ tomcat_home }}
            service_ip: {{ service_ip }}

{{ tomcat_home }}/webapps/WEB-INF/classes/config/properties/quartz.properties:
    file.managed:
        - source: salt://ozr/conf/quartz.properties_ozr
        - user: root
        - group: root
        - mode: '740'
        - template: jinja
        - context:
            datasource_url: {{ datasource_url }}
            db_user: root
            db_password: {{ db_password }}

