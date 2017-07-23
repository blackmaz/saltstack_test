{%- import 'common/firewall.sls' as firewall with context %}

{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set t       = salt['pillar.get'](company+':'+system+':software:tomcat',{}) %}
{%- set ctx = salt['pillar.get'](company+':'+system+':software:tomcat:contexts',{}) %}
{%- from 'tomcat/map.jinja' import tomcat with context %}

# 설정파일 업데이트
sever-xml:
  file.managed:
    - source: salt://tomcat/conf/server.xml_ozr
    - name: {{ t.install.insthome }}/{{ tomcat.dirname }}/conf/server.xml
    - user: root
    - group: root
    - mode: '640'
    - template: jinja
    - context:
        cfg: {{ t.server }}
    - require:
      - archive: unpack-tomcat-tar

# 설정된 Context의 Docbase 만들기
# Docbase가 생성되어 있지 않으면 tomcat 부팅시 에러가 발생함
# t에서 items추출시 에러발생하여 ctx추가
{%- for id, context in ctx.items() %}
docbase-{{ id }}:
  file.directory:
    - name: {{ t.install.insthome }}/{{ tomcat.dirname }}/{{ t.server.app_base }}/{{ context.doc_base }}
    - user: root
    - group: root
    - dir_mode: 755

# 동작여부를 확인하기 위한 sample page... 나중에는 삭제해도 됨
sample-{{ id }}:
  file.append:
    - name: {{ t.install.insthome }}/{{ tomcat.dirname }}/{{ t.server.app_base }}/{{ context.doc_base }}/sample.jsp
    - text: This is sample page of {{ context.doc_base }}

{%- endfor %}

# WAS 서버를 web 서버와 분리할 경우 방화벽 제어가 필요할수 있으니 정의해 두고
# 사용여부에 따라서 선택적으로 사용할 수 있도록 변경하자
{{ firewall.firewall_open(t.server.http_port) }}
{{ firewall.firewall_open(t.server.ajp_port) }}
