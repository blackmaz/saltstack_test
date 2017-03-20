{% set salt_master_ip = salt['pillar.get']('salt_master:ip_address')  %}

reg_salt_master:
  host.present:
    - name: salt
    - ip: {{ salt_master_ip }}

install_curl:
  pkg.installed:
    - name: curl
    - require:
      - host: reg_salt_master

install_pyyaml:
  pip.removed:
    - name: PyYAML
    - require:
      - host: reg_salt_master
      
salt_minion:
  cmd.run:
    - name: |
        curl -L https://bootstrap.saltstack.com -o install_salt.sh
        sh install_salt.sh -P stable 2016.11.2
    - unless: test -x /usr/bin/salt-minion
    - require:
      - pkg: install_curl

# openssl 설치시 x509와 종속성이 있는 패키지
{%- if grains['os_family']=="Debian" %}
m2crypto:
  pkg.installed:
    - name: m2crypto
    - require: 
      - cmd: salt_minion
{%- elif grains['os_family']=='RedHat' %}
python-pip:
  pkg.installed:
    - pkgs:
      - python2-pip
      - gcc
      - python-devel
      - openssl-devel
    - require:
      - cmd: salt_minion

m2crypto:
  pip.installed:
    - name: m2crypto
    - require:
      - pkg: python-pip
{%- endif %}
