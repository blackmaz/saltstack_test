{%- from 'tomcat/settings.sls' import tomcat with context %}

tomcat-install-dir:
  file.directory:
    - name: {{ tomcat.install_dir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

