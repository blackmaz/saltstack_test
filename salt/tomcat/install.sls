###################################
# apache-tomcat install sls
###################################
{%- set company    = salt['pillar.get']('company','default') %}
{%- set system     = salt['pillar.get']('system','default') %}
{%- set install    = salt['pillar.get'](company+':'+system+':software:tomcat:install') %}
{%- from 'tomcat/map.jinja' import tomcat with context %}

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



