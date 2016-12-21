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
        make install-daemon
    - cwd: /root/nagios/nrpe-2.15
    - unless: test -f /usr/local/nagios/etc/nrpe.cfg

/usr/local/nagios/etc/hosts.cfg:
  file.managed:
    - source: salt://nagios/hosts.cfg.templet

/usr/local/nagios/etc/services.cfg:
  file.managed:
    - source: salt://nagios/services.cfg.templet

/usr/local/nagios/etc/nagios.cfg:
  file.append:
    - text: 
      - "cfg_file=/usr/local/nagios/etc/hosts.cfg"
      - "cfg_file=/usr/local/nagios/etc/services.cfg"

/usr/local/nagios/etc/objects/commangds.cfg:
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

nagios_restart:
  service.running:
    - name: nagios
    - enable: True
