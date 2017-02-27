###################################
# apache-tomcat install sls
###################################
{%- set tomcat = salt['pillar.get']('software:tomcat:config') %}

# 다운로드 및 압축 해제
unpack-tomcat-tar:
  archive.extracted:
    - name: {{ tomcat.insthome }}
    - source:  {{ tomcat.downloadurl }}
    - source_hash: sha1={{ tomcat.downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

# 개발서버와 동일하게 경로 변경
rename-tomcat-dir:
    file.copy:
        - source: {{ tomcat.insthome }}/{{ tomcat.version }}
        - name: {{ tomcat.home }}
        - force: True

# 설정파일 업데이트
{{ tomcat.home }}/conf/server.xml:
    file.managed:
        - source: salt://ozr/conf/server.xml_ozr
        - user: root
        - group: root
        - mode: '640'
        - template: jinja
        - defaults:
            server_port: "8080"
            domain_name: "www.nestfunding.kr"
        - context:
            max_threads: 100

{{ tomcat.home }}/bin/catalina.sh:
    file.managed:
        - source: salt://ozr/conf/catalina.sh_ozr
        - user: root
        - group: root
        - mode: '750'
        - template: jinja
        - context:
            java_opts: {{ tomcat.java_opts }}

# 개발서버와 동일하게 시작,종료 쉘 생성
{{ tomcat.insthome }}/start.sh:
    file.managed:
        - source: salt://ozr/conf/start.sh_ozr
        - user: root
        - group: root
        - mode: '750'
{{ tomcat.insthome }}/stop.sh:
    file.managed:
        - source: salt://ozr/conf/stop.sh_ozr
        - user: root
        - group: root
        - mode: '750'

# 바로 서비스 시작
startup-tomcat:
  cmd.run:
    - name: {{ tomcat.home }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | awk '{print $2}'`

