###################################
# ozr web application deploy sls
###################################
{% set tomcat_home = pillar['tomcat']['tomcat_home'] %}
{% set service_ip = pillar['application']['service_ip'] %}
{% set deploy_tar = pillar['application']['deploy_tar'] %}
{% set deploy_downloadurl = pillar['application']['deploy_downloadurl'] %}
{% set datasource_url = pillar['application']['datasource_url'] %}
{% set db_user = pillar['application']['db_user'] %}
{% set db_password = pillar['application']['db_user_password'] %}

# 현재 application 압축 포맷이 zip이므로 설치
install-unzip:
  pkg.installed:
    - pkgs:
      - unzip

#download application 파일
download-sample-tar:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ deploy_tar }} {{ deploy_downloadurl }}
    - unless: test -f '/tmp/'{{ deploy_tar }}

{{ tomcat_home }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

deploy-sample-tar:
  cmd.run:
    - name: cp '/tmp/'{{ deploy_tar }} {{ tomcat_home }}
    - unless: test -f {{ tomcat_home }}/{{ deploy_tar }}

# unpack - 현재 zip
unpack-sample-tar:
  cmd.run:
    - name: cd {{ tomcat_home }};mv webapps webapps_origin;unzip {{ deploy_tar }}

# application 설정파일 업데이트
# system.properties
# service_ip는 외부에 열려있는 서비스IP를 의미
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

# quartz.properties
# db 접속 설정이 존재
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

