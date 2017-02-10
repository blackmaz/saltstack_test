{%- set tomcat_home = '/www/nest/tomcat7' %}
{%- set service_ip = '192.168.10.10' %}
{%- set deploy_tar = 'webapps_ozr.zip' %}
{%- set deploy_downloadurl = 'https://www.dropbox.com/s/y257ychikv0gwz1/webapps_ozr.zip?dl=0' %}
{%- set datasource_url = 'jdbc:mysql://localhost:3306/nest_dev' %}
{%- set db_user = 'root' }
{%- set db_password = '' %}

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
            db_user: {{ db_user }}
            db_password: {{ db_password }}

