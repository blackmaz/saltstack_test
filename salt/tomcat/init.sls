{%- from 'tomcat/settings.sls' import tomcat with context %}

tomcat-install-dir:
  file.directory:
    - name: {{ tomcat.install_dir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

download-tomcat-tarball:
  cmd.run:
    - name: curl -s -L -o '/app/tomcat/apache-tomcat-8.5.9.tar.gz' 'http://mirror.navercorp.com/apache/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz'
    - unless: test -f '/app/tomcat/apache-tomcat-8.5.9.tar.gz'
    - require:
      - file: tomcat-install-dir

unpack-tomcat-tarball:
  archive.extracted:
    - name: /app/tomcat2/
    - source: file:///app/tomcat/apache-tomcat-8.5.9.tar.gz
    - archive_format: tar
    - tar_options: zxvf
    - user: root
    - group: root
#    - onchanges:
#      - cmd: download-tomcat-tarball
