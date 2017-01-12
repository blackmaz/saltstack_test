{%- from 'tomcat/settings.sls' import tomcat with context %}

download-tomcat-tarball:
  cmd.run:
    - name: curl -s -L -o '/root/saltstack_test/salt/tomcat/files/apache-tomcat-8.5.9.tar.gz' 'http://mirror.navercorp.com/apache/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz'
    - unless: test -f '/root/saltstack_test/salt/tomcat/files/apache-tomcat-8.5.9.tar.gz'
    - require:
      - file: tomcat-install-dir

unpack-tomcat-tarball:
  archive.extracted:
    - name: {{ tomcat.install_dir }}
    - source: salt://tomcat/files/apache-tomcat-8.5.9.tar.gz
    - archive_format: tar
    - tar_options: zxvf
    - onchanges:
      - cmd: download-tomcat-tarball

/app/tomcat/apache-tomcat-8.5.9/conf/context.xml:
  file.managed:
    - source: salt://tomcat/files/context.xml
    - user: root
    - group: root
    - mode: '640'
    - template: jinja

