{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_sunjava_filedir = salt_home + '/sun-java/files' %}
{%- set java_tar = 'jdk-8u111-linux-x64.tar.gz' %}
{%- set java_downloadurl = 'http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz' %}
{%- set java_downloadhash  = '187eda2235f812ddb35c352b5f9aa6c5b184d611c2c9d0393afb8031d8198974' %}
{%- set tarball_file = salt_sunjava_filedir + '/' + java_tar %}
{%- set java_insthome = '/opt/java' %}
{%- set java_version = 'jdk1.8.0_111' %}
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
    - source: salt://sun-java/files/{{ java_tar }}
    - archive_format: tar
    - tar_option: zxvf
    - if_missing: {{ java_home }}

set-jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://sun-java/conf/_java_path.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ java_home }}

update-jdk-config:
  cmd.run:
    - name: sh /etc/profile.d/java.sh

remove-jdk-tarball:
  file.absent:
    - name: {{ tarball_file }}
