{%- set salt_master = salt['pillar.get']('salt_master')  %}

# salt master가 ip를 사용하는 경우 host파일에 ip를 등록함
{%- if salt_master.get('ip_address',False) != False %}
reg_salt_master:
  host.present:
    - name: salt
    - ip: {{ salt_master.ip_address }}
{%- endif %}

install_curl:
  pkg.installed:
    - name: curl

install_pyyaml:
  pip.removed:
    - name: PyYAML
    - require:
      - pkg: install_pyyaml

#        sh install_salt.sh -P stable 2016.11.2      
#        sh install_salt.sh -P -> latest
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
# 0.26.0 설치시 _parse_subject에서 null을 리턴할 경우 에러 발생
# https://github.com/saltstack/salt/issues/40490
m2crypto:
  pip.installed:
    - name: m2crypto == 0.25.1
    - require:
      - pkg: python-pip
{%- endif %}

# mysql returner 지정을 위한 python mysql 라이브러리 설치
{%- if grains['os_family']=="Debian" %}
mysql_returner:
  pkg.installed:
    - name: python-mysqldb
{%- elif grains['os_family']=='RedHat' %}
mysql_returner:
  pkg.installed:
    - name: MySQL-python
{%- endif %}

# salt master가 url을 사용하는 경우 minion 설정파일에 url을 등록함
{%- if salt_master.get('url',False) != False %}
salt_master:
  file.line:
    - name: /etc/salt/minion
    - content: 'master: {{ salt_master.url }}'
    - mode: ensure
    - after: '#master: salt'
{%- endif %}

# 미니언 설정 파일에 기본 리터너 지정
salt_returner:
  file.line:
    - name: /etc/salt/minion
    - content: "return: syslog"
    - mode: ensure
    - after: '#  - slack'

# 미니언 재시작
restart_salt:
  module.run:
    - name: service.restart
    - m_name: salt-minion
    - require:
      - file: salt_returner

  
