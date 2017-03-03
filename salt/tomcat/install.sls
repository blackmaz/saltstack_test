###################################
# apache-tomcat install sls
###################################
{%- set install = salt['pillar.get']('software:tomcat:install') %}
{%- from 'tomcat/map.jinja' import tomcat with context %}
{%- set server = salt['pillar.get']('software:tomcat:server') %}

# 다운로드 및 압축 해제
unpack-tomcat-tar:
  archive.extracted:
    - name: {{ install.insthome }}
    - source:  {{ tomcat.downloadurl }}
    - source_hash: sha1={{ tomcat.downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

# 설정파일 업데이트
sever-xml:
  file.managed:
    - source: salt://tomcat/conf/server.xml_ozr
    - name: {{ install.home }}/conf/server.xml
    - user: root
    - group: root
    - mode: '640'
    - template: jinja
    - context:
        cfg: {{ server }}
    - require:
      - archive: unpack-tomcat-tar

catalina-sh:
  file.managed:
    - source: salt://tomcat/conf/catalina.sh_ozr
    - name: {{ install.home }}/bin/catalina.sh
    - user: root
    - group: root
    - mode: '750'
    - template: jinja
    - context:
        java_opts: {{ install.java_opts }}
    - require:
      - file: sever-xml

# 바로 서비스 시작
startup-tomcat:
  cmd.run:
    - name: {{ install.home }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | awk '{print $2}'`
    - require:
      - archive: unpack-tomcat-tar
      - file: sever-xml
      - file: catalina-sh

