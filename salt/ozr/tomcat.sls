{% set tomcat_insthome = pillar['tomcat']['tomcat_insthome'] %}
{% set tomcat_dir = pillar['tomcat']['tomcat_dir'] %}
{% set tomcat_home = pillar['tomcat']['tomcat_home'] %}
{% set tomcat_version = pillar['tomcat']['tomcat_version'] %}
{% set tomcat_tar = tomcat_version + '.tar.gz' %}
{% set tomcat_downloadurl = pillar['tomcat']['tomcat_downloadurl'] %}
{% set tomcat_downloadhash = pillar['tomcat']['tomcat_downloadhash'] %}
{% set java_opts = pillar['tomcat']['tomcat_java_opts'] %}


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

#rename-tomcat-dir:
#  cmd.run:
#    - name: cd {{ tomcat_insthome }};mv {{ tomcat_version }} {{ tomcat_dir }}
#    - unless: test -d {{ tomcat_home }}

rename-tomcat-dir:
    file.copy:
        - source: {{ tomcat_insthome }}/{{ tomcat_version }}
        - name: {{ tomcat_insthome }}/{{ tomcat_dir }}
        - force: True


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

