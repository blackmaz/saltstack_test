# NFS SERVER 구성 state

# Firewall 
{% import 'common/firewall.sls' as firewall with context %}

# pillar/nfs.sls
{%- set expdir = pillar['nfs-server']['exports-dir'] %}
{%- set allowip = pillar['nfs-server']['nfs-allowed-client-ip'] %}
{%- set opts = pillar['nfs-server']['nfs-opts'] %}

# pkg install
nfs-server-install:
  pkg.installed:
    - name: nfs-utils

# shared directory 생성
{{ expdir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

# /etc/exports에 shared directory 설정
/etc/exports:
  file.append:
    - text: {{expdir}} {{allowip}}({{opts}})

# firewall 처리
{{ firewall.firewall_open_service('nfs') }}
{{ firewall.firewall_open_service('rpc-bind') }}
{{ firewall.firewall_open_service('mountd') }}

# rpcbind service restart
rpc-binds-reload:
  service.running:
    - name: rpcbind
    - reload: True

# nfs-server 기동
nfs-server-start:
  service.running:
    - name: nfs-server
    - enable: True
    - watch:
      - pkg: nfs-utils

  

