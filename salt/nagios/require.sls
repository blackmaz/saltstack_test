# Nagios 설치를 위한 기본 패키지와 임시 디렉토리 및 유저 생성
require_install:
  pkg.installed:
    - pkgs:
      - gcc
      - make
      - wget
      - unzip
{%- if grains['os_family'] == 'RedHat' %}
      - glibc
      - glibc-common
      - gd
      - gd-devel
      - net-snmp
      - openssl-devel
{%- elif grains['os_family'] == 'Debian' %}
      - build-essential
      - php-gd
      - libgd2-xpm-dev
      - libssl-dev
{%- endif %}

create_working_dir:
  file.directory:
    - name: /root/nagios
    - user: root
    - group: root
    - require:
      - pkg: require_install

group_create:
  group.present:
    - name: nagcmd
    - require:
      - file: create_working_dir

user_create:
  user.present:
    - name: nagios
    - groups:
      - nagcmd
    - require:
      - group: group_create

