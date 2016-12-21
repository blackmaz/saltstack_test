nagios_pre_install:
  pkg.installed:
    - pkgs:
      - gcc
      - glibc
      - glibc-common
      - gd
      - gd-devel
      - make
      - net-snmp
      - openssl-devel

create_working_dir:
  file.directory:
    - name: /root/nagios
    - user: root
    - group: root

download_naigos_core:
  archive.extracted:
    - name: /root/nagios
    - source: http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-4.2.4.tar.gz
    - skip_verify: True

group_create:
  group.present:
    - name: nagcmd

user_create:
  user.present:
    - name: nagios
    - groups:
      - nagcmd

user_mod:
  user.present:
    - name: apache
    - groups:
      - nagcmd

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

copy_eventhandlers:
  file.copy:
    - name: /usr/local/nagios/libexec/eventhandlers
    - source: /root/nagios/nagios-4.2.4/contrib/eventhandlers
    - subdir: True
    - user: nagios
    - group: nagios

nagios_service_running:
  service.running:
    - name: nagios
    - enable: True

httpd_passwd:
  webutil.user_exists:
    - name: nagiosadmin
    - password: ehrtnfl5
    - htpasswd_file: /usr/local/nagios/etc/htpasswd.users

