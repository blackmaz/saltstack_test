###################################
# apache-tomcat install sls
###################################
{%- import 'common/firewall.sls' as firewall with context %}
{%- set install = salt['pillar.get']('software:tomcat:install') %}
{%- from 'tomcat/map.jinja' import tomcat with context %}
{%- set server = salt['pillar.get']('software:tomcat:server') %}

# install home 존재 여부를 확인하고 없으면 생성
create_inst_home:
  file.directory:
    - name: {{ install.insthome }}
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True

# 다운로드 및 압축 해제
# stable 2016.11.3 버전으로 업그래이드 시에 에러가 발생한다.
# stable 2016.11.2 버전으로 유지 해야 함
unpack-tomcat-tar:
  archive.extracted:
    - name: {{ install.insthome }}
    - source:  {{ tomcat.downloadurl }}
#    - source_hash: sha1={{ tomcat.downloadhash }}
    - archive_format: tar
    - tar_option: zxvf
    - skip_verify: True
#    - if_missing: {{ install.home }}
    - keep: False

# WAS 서버를 web 서버와 분리할 경우 방화벽 제어가 필요할수 있으니 정의해 두고
# 사용여부에 따라서 선택적으로 사용할 수 있도록 변경하자
{{ firewall.firewall_open('8080') }}
{{ firewall.firewall_open('8009') }}

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

# 설정된 Context의 Docbase 만들기
# Docbase가 생성되어 있지 않으면 tomcat 부팅시 에러가 발생함
{%- for id, context in server.Contexts.items() %}
docbase-{{ id }}:
  file.directory:
    - name: {{ install.home }}/{{ server.appBase }}/{{ context.docBase }}
    - user: root
    - group: root
    - dir_mode: 755

# 동작여부를 확인하기 위한 sample page... 나중에는 삭제해도 됨
sample-{{ id }}:
  file.append:
    - name: {{ install.home }}/{{ server.appBase }}/{{ context.docBase }}/sample.jsp
    - text: This is sample page of {{ context.docBase }} 

{%- endfor %}

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

