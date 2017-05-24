apache_mod:
  user.present:
    - name: apache
    - groups:
      - nagcmd

# Nagios Core 다운로드 및 컴파일 설치
download_naigos_core:
  archive.extracted:
    - name: /root/nagios
    - source: http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.2.4.tar.gz
    - skip_verify: True
    - require: 
      - user: apache_mod

install_nagios_core:
  cmd.run:
    - name: |
        cd /root/nagios/nagios-4.2.4
        ./configure --with-command-group=nagcmd
        make all
        make install
        make install-init
        make install-config
        make install-commandmode
        make install-webconf
    - cwd: /root/nagios/nagios-4.2.4
    - unless: test -x /usr/local/nagios/bin/nagios
    - require:
      - archive: download_naigos_core

copy_eventhandlers:
  file.copy:
    - name: /usr/local/nagios/libexec/eventhandlers
    - source: /root/nagios/nagios-4.2.4/contrib/eventhandlers
    - subdir: True
    - user: nagios
    - group: nagios
    - require:
      - cmd: install_nagios_core

# nagios 서비스 등록 및 기동
nagios_service_running:
  cmd.run:
    - name: "systemctl enable nagios"
    - require:
      - cmd: install_nagios_core
  service.running:
    - name: nagios
    - require:
      - cmd: install_nagios_core


