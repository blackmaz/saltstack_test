{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_tomcat_filedir = salt_home + '/tomcat/files' %}
{%- set tomcat_home = '/app/tomcat' %}
{%- set tomcat_version = 'apache-tomcat-8.5.9' %}
{%- set tomcat_tar = tomcat_version + '.tar.gz' %}
{%- set tomcat_downloadurl = 'http://mirror.navercorp.com/apache/tomcat/tomcat-8/v8.5.9/bin/' + tomcat_tar %}
{%- set tomcat_downloadhash = '3c800e7affdf93bf4dbcf44bd852904449b786f6' %}

download-tomcat-tar:
  cmd.run:
    - name: curl -s -L -o {{ salt_tomcat_filedir }}/{{ tomcat_tar }} {{ tomcat_downloadurl }}
    - unless: test -f {{ salt_tomcat_filedir }}/{{ tomcat_tar }}

unpack-tomcat-tar:
  archive.extracted:
    - name: {{ tomcat_home }}
    - source:  salt://tomcat/files/{{ tomcat_tar }}
    - source_hash: sha1={{ tomcat_downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

remove-tomcat-tar:
  file.absent:
    - name: {{ salt_tomcat_filedir }}/{{ tomcat_tar }}

{{ tomcat_home }}/apache-tomcat-8.5.9/conf/server.xml:
    file.managed:
        - source: salt://tomcat/conf/_server.xml
        - user: root
        - group: root
        - mode: '640'
        - template: jinja
        - defaults:
            server_port: "18080"
            other_var: 123
        - context:
            max_threads: 100

{{ tomcat_home }}/apache-tomcat-8.5.9/bin/catalina.sh:
    file.managed:
        - source: salt://tomcat/conf/_catalina.sh
        - user: root
        - group: root
        - mode: '640'
        - template: jinja
        - context:
            java_opts: "-server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC"
