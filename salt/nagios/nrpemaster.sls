{%- set nagios = salt['grains.filter_by']({
  'Debian': {
    'nrpe_option': '--with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu/'
  },
  'RedHat': {
    'nrpe_option': ''
  }
} ) %}

download_naigos_nrpe:
  archive.extracted:
    - name: /root/nagios
    - source: http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
    - skip_verify: True

install_nagios_nrpe:
  cmd.run:
    - name: |
        cd /root/nagios/nrpe-2.15
        ./configure {{ nagios.nrpe_option }}
        make all
        make install
        make install-daemon
    - cwd: /root/nagios/nrpe-2.15
    - unless: test -f /usr/local/nagios/etc/nrpe.cfg
    - require: 
      - archive: download_naigos_nrpe

/usr/local/nagios/etc/hosts.cfg:
  file.managed:
    - source: salt://nagios/conf/hosts.cfg.templet
    - require: 
      - cmd: install_nagios_nrpe

/usr/local/nagios/etc/services.cfg:
  file.managed:
    - source: salt://nagios/conf/services.cfg.templet
    - require: 
      - cmd: install_nagios_nrpe

/usr/local/nagios/etc/nagios.cfg:
  file.append:
    - text: 
      - "cfg_file=/usr/local/nagios/etc/hosts.cfg"
      - "cfg_file=/usr/local/nagios/etc/services.cfg"
    - require: 
      - cmd: install_nagios_nrpe

/usr/local/nagios/etc/objects/commands.cfg:
  file.append:
    - text: |
        ##########################################################################
        # NRPE CHECK COMMAND
        # Command to use NRPE to check remote host systems
        ##########################################################################
        
        define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
        }
    - require: 
      - cmd: install_nagios_nrpe


