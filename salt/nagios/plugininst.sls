nagios_plugin_install:
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

download_naigos_plugins:
  archive.extracted:
    - name: /root/nagios
    - source: http://nagios-plugins.org/download/nagios-plugins-2.1.4.tar.gz
    - skip_verify: True

group_create:
  group.present:
    - name: nagcmd

user_create:
  user.present:
    - name: nagios
    - groups:
      - nagcmd

install_nagios_plugins:
  cmd.run:
    - name: |
        cd /root/nagios/nagios-plugins-2.1.4
        ./configure --with-nagios-user=nagios --with-nagios-group=nagios
        make
        make install
    - cwd: /root/nagios/nagios-plugins-2.1.4
    - unless: test -x /usr/local/nagios/libexec/check_apt

/usr/local/nagios:
  file.directory:
    - user: nagios
    - group: nagios

/usr/local/nagios/libexec:
  file.directory:
    - user: nagios
    - group: nagios
    - recurse:
      - user
      - group
