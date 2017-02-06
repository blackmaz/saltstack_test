{%- from 'tomcat/settings.sls' import tomcat with context %}

download-tomcat-tar:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ tomcat.tomcat_tar }} {{ tomcat.downloadurl }}
    - unless: test -f '/tmp/'{{ tomcat.tomcat_tar }}

unpack-tomcat-tar:
  archive.extracted:
    - name: {{ tomcat.tomcat_insthome }}
    - source:  file:///tmp/{{ tomcat.tomcat_tar }}
    - source_hash: sha1={{ tomcat.downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

#remove-tomcat-tar:
#  file.absent:
#    - name: {{ tomcat.salt_tomcat_filedir }}/{{ tomcat.tomcat_tar }}

{{ tomcat.tomcat_home }}/conf/server.xml:
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

{{ tomcat.tomcat_home }}/bin/catalina.sh:
    file.managed:
        - source: salt://tomcat/conf/_catalina.sh
        - user: root
        - group: root
        - mode: '740'
        - template: jinja
        - context:
            java_opts: {{ tomcat.java_opts }}

startup-tomcat:
  cmd.run:
    - env: 
      - JAVA_HOME: "{{ tomcat.java_home }}"
    - name: {{ tomcat.tomcat_home }}/bin/startup.sh
    - unless: test -n `ps -ef | grep java | awk '{print $2}'`

