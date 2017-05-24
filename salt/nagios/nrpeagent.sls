{% import 'common/firewall.sls' as firewall with context %}
{%- set nagios = salt['grains.filter_by']({
  'Debian': {
    'nrpe_option': '--with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu/'
  },
  'RedHat': {
    'nrpe_option': ''
  }
} ) %}

nrpe_nrpe_install:
  pkg.installed:
    - pkgs:
      - xinetd

download_naigos_nrpe:
  archive.extracted:
    - name: /root/nagios
    - source: http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
    - skip_verify: True
    - require:
      - pkg: nrpe_nrpe_install

install_nagios_nrpe:
  cmd.run:
    - name: |
        cd /root/nagios/nrpe-2.15
        ./configure {{ nagios.nrpe_option }}
        make all
        make install-plugin
        make install-daemon
        make install-daemon-config
        make install-xinetd
    - cwd: /root/nagios/nrpe-2.15
    - unless: test -f /usr/local/nagios/etc/nrpe.cfg
    - require:
      - archive: download_naigos_nrpe

/etc/xinetd.d/nrpe:
  file.line:
    - match: 'only_from       = 127.0.0.1'
    - content: 'only_from       = 127.0.0.1 localhost 192.168.10.93'
    - mode: replace
    - require:
      - cmd: install_nagios_nrpe

/etc/services:
  file.append:
    - text:
      - "nrpe            5666/tcp                # NRPE nagios\n"
    - require:
      - cmd: install_nagios_nrpe

restart_xinetd:
  service.running:
    - name: xinetd
    - enable: True
    - require:
      - cmd: install_nagios_nrpe

{{ firewall.firewall_open('5666') }}

