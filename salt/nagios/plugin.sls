# Nagios Plugin 다운로드 및 설치
download_naigos_plugins:
  archive.extracted:
    - name: /root/nagios
    - source: http://nagios-plugins.org/download/nagios-plugins-2.1.4.tar.gz
    - skip_verify: True

install_nagios_plugins:
  cmd.run:
    - name: |
        cd /root/nagios/nagios-plugins-2.1.4
        ./configure --with-nagios-user=nagios --with-nagios-group=nagios
        make
        make install
    - cwd: /root/nagios/nagios-plugins-2.1.4
    - unless: test -x /usr/local/nagios/libexec/check_apt
    - require: 
      - archive: download_naigos_plugins

/usr/local/nagios:
  file.directory:
    - user: nagios
    - group: nagios
    - require: 
      - cmd: install_nagios_plugins

/usr/local/nagios/libexec:
  file.directory:
    - user: nagios
    - group: nagios
    - recurse:
      - user
      - group
    - require: 
      - cmd: install_nagios_plugins
