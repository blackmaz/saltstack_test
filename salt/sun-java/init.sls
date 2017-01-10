{%- from 'sun-java/settings.sls' import java with context %}

{#- require a source_url - there is no default download location for a jdk #}

{%- if java.source_url is defined %}

  {%- set tarball_file = java.prefix + '/' + java.source_url.split('/') | last %}
  {%- set salt_dir = '/root/saltstack_test/salt' %}
  {%- set tarball_temp_file = salt_dir + '/sun-java/files/' + java.source_url.split('/') | last %}

java-install-dir:
  file.directory:
    - name: {{ java.prefix }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

download-jdk-tarball:
  cmd.run:
    - name: curl {{ java.dl_opts }} -o '{{ tarball_temp_file }}' '{{ java.source_url }}'
    - unless: test -d {{ java.java_real_home }} || test -f {{ tarball_temp_file }}
    - require:
      - file: java-install-dir
unpack-jdk-tarball:
  archive.extracted:
    - name: {{ java.prefix }}
    - source: salt://sun-java/files/jdk-8u111-linux-x64.tar.gz
    {%- if java.source_hash %}
    - source_hash: sha256={{ java.source_hash }}
    {%- endif %}
    - archive_format: tar
    - tar_options: zxvf
    - user: root
    - group: root
    - if_missing: {{ java.java_real_home }}
    - onchanges:
      - cmd: download-jdk-tarball
create-java-home:
  alternatives.install:
    - name: java-home
    - link: /opt/java/jdk1.8.0_111/bin/java
    - path: /usr/bin/java
    - priority: 30
    - require:
      - archive: unpack-jdk-tarball
remove-jdk-tarball:
  file.absent:
    - name: {{ tarball_file }}
{%- endif %}

