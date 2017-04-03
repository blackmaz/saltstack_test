# url에서 자동으로 받는 것들은 버전업이 되면 링크가 막히거나 다운로드가 안되는 경우가 발생함
# 그때그때 다운로드 받아서 등록한 것을 이용하도록 해야 할 듯
# http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz
{%- set java_version = 'jdk1.8.0_121' %}
{%- set java_tar = 'jdk-8u121-linux-x64.tar.gz' %}
{%- set java_downloadurl = 'download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/'+java_tar %}

# 설치에 필요한 디렉토리 정보
{%- set java_insthome = '/opt/java' %}
{%- set tarball_file = '/tmp/' + java_tar %}
{%- set java_home = java_insthome+'/' + java_version  %}

java-install-dir:
  file.directory:
    - name: {{ java_insthome }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

download-jdk-tarball:
  cmd.run:
    - name: curl -b oraclelicense=accept-securebackup-cookie -s -L -o '{{ tarball_file }}' '{{ java_downloadurl }}' 
    - unless: test -f {{ tarball_file }} 
    - require:
      - file: java-install-dir

unpack-jdk-tarball:
  archive.extracted:
    - name: {{ java_insthome }}
    - source: file://{{ tarball_file }}
    - archive_format: tar
    - tar_option: zxvf
    - if_missing: {{ java_home }}
    - require:
      - cmd: download-jdk-tarball

set-jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://java/conf/_java_path.sh
    - template: jinja
    - mode: 755
    - user: root
    - group: root
    - context:
      java_home: {{ java_home }}
    - require:
      - archive: unpack-jdk-tarball

update-jdk-config:
  cmd.run:
    - name: sh /etc/profile.d/java.sh
    - require:
      - file: set-jdk-config

