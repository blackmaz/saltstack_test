{% import 'common/firewall.sls' as firewall with context %}

nrpe_nrpe_install:
  pkg.installed:
    - pkgs:
      - xinetd

create_working_dir:
  file.directory:
    - name: /root/nagios
    - user: root
    - group: root

download_naigos_nrpe:
  archive.extracted:
    - name: /root/nagios
    - source: http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
    - skip_verify: True

install_nagios_nrpe:
  cmd.run:
    - name: |
        cd /root/nagios/nrpe-2.15
        ./configure 
        make all
        make install-plugin
        make install-daemon
        make install-daemon-config
        make install-xinetd
    - cwd: /root/nagios/nrpe-2.15
    - unless: test -f /usr/local/nagios/etc/nrpe.cfg 

/etc/xinetd.d/nrpe:
  file.line:
    - match: 'only_from       = 127.0.0.1'
    - content: 'only_from       = 127.0.0.1 localhost 192.168.10.86'
    - mode: replace

/etc/services:
  file.append:
    - text:
      - "nrpe            5666/tcp                # NRPE nagios\n"

restart_xinetd:
  service.running:
    - name: xinetd
    - enable: True

{{ firewall.firewall_open('5666') }}

