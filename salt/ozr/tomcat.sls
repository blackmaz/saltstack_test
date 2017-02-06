{%- set tomcat_insthome = '/www/nest' %}
{%- set tomcat_dir = 'tomcat7' %}
{%- set tomcat_home = tomcat_insthome+'/'+tomcat_dir %}
{%- set tomcat_version = 'apache-tomcat-7.0.75' %}
{%- set tomcat_tar = tomcat_version + '.tar.gz' %}
{%- set tomcat_downloadurl = 'http://apache.mirror.cdnetworks.com/tomcat/tomcat-7/v7.0.75/bin/'+tomcat_tar %}
{%- set tomcat_downloadhash = '1373d27e7e9cd4c481b4b17c6b2c36aff157b66e' %}
{%- set java_opts = '-server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC' %}

download-tomcat-tar:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ tomcat_tar }} {{ tomcat_downloadurl }}
    - unless: test -f '/tmp/'{{ tomcat_tar }}

unpack-tomcat-tar:
  archive.extracted:
    - name: {{ tomcat_insthome }}
    - source:  file:///tmp/{{ tomcat_tar }}
    - source_hash: sha1={{ tomcat_downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

rename-tomcat-dir:
  cmd.run:
    - name: cd {{ tomcat_insthome }};mv {{ tomcat_version }} {{ tomcat_dir }}
    - unless: test -d {{ tomcat_home }}


{{ tomcat_home }}/conf/server.xml:
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

{{ tomcat_home }}/bin/catalina.sh:
    file.managed:
        - source: salt://ozr/conf/catalina.sh_ozr
        - user: root
        - group: root
        - mode: '750'
        - template: jinja
        - context:
            java_opts: {{ java_opts }}

{{ tomcat_insthome }}/start.sh:
    file.managed:
        - source: salt://ozr/conf/start.sh_ozr
        - user: root
        - group: root
        - mode: '750'
{{ tomcat_insthome }}/stop.sh:
    file.managed:
        - source: salt://ozr/conf/stop.sh_ozr
        - user: root
        - group: root
        - mode: '750'


startup-tomcat:
  cmd.run:
    - name: {{ tomcat_home }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | awk '{print $2}'`

