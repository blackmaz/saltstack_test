###################################
# ozr web application deploy sls
###################################
{%- set server = salt['pillar.get']('software:tomcat:server',{}) %}
{%- set home   = salt['pillar.get']('software:tomcat:install:home','') %}

{%- for id, Context in server.Contexts.items() %}
# 다운로드 및 압축 해제
unpack-app-tar-{{ id }}:
  archive.extracted:
    - name: /tmp
    - source:  {{ Context.downloadurl }}
    - archive_format: tar
    - tar_option: zxvf

copy-app-{{ id }}:
  file.copy:
    - name: {{ home }}/{{ server.appBase }}/{{ Context.docBase }}
    - source: /tmp/{{ Context.filename }}
    - require:
      - archive: unpack-app-tar-{{ id }}

# application 설정파일 업데이트
# system.properties
# service_ip는 외부에 열려있는 서비스IP를 의미
system-properties-{{ id }}:
  file.managed:
    - source: salt://tomcat/conf/system.properties_ozr
    - name: {{ home }}/{{ server.appBase }}/{{ Context.docBase }}/WEB-INF/classes/config/properties/system.properties
    - user: root
    - group: root
    - mode: '740'
    - template: jinja
    - context:
        tomcat_home: {{ home }}
        service_ip: {{ Context.service_ip }}
    - require:
      - file: copy-app-{{ id }}

# quartz.properties
# db 접속 설정이 존재
quartz-properties-{{ id }}:
  file.managed:
    - source: salt://tomcat/conf/quartz.properties_ozr
    - name: {{ home }}/{{ server.appBase }}/{{ Context.docBase }}/WEB-INF/classes/config/properties/quartz.properties
    - user: root
    - group: root
    - mode: '740'
    - template: jinja
    - context:
        datasource_url: {{ Context.use_database.software }}
        db_user: {{ Context.db_user }}
        db_password: {{ Context.db_password }}
    - require:
      - file: copy-app-{{ id }}

datasource-{{ id }}:
  file.managed:
    - source: salt://tomcat/conf/context-datasource.xml_ozr
    - name: {{ home }}/{{ server.appBase }}/{{ Context.docBase }}/WEB-INF/classes/config/spring/context-datasource.xml
    - user: root
    - group: root
    - mode: '740'
    - template: jinja
    - context:
        datasource_url: {{ Context.datasource_url }}
        db_user: {{ Context.db_user }}
        db_password: {{ Context.db_password }}
    - require:
      - file: copy-app-{{ id }}

{% endfor %}





