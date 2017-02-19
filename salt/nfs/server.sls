# NFS SERVER 구성 state

# Firewall 
{% import 'common/firewall.sls' as firewall with context %}

# nfs 설정
{%- set nfs = salt['grains.filter_by']({
  'Debian': {
    'pkg': 'nfs-kernel-server',
    'nfs_svc': 'nfs-kernel-server',
    'rpcbind_svc': 'rpcbind'
  },
  'RedHat': {
    'pkg': 'nfs-utils',
    'nfs_svc': nfs,
    'rpcbind_svc': 'rpcbind'
  },
})
%}

# pillar/nfs.sls
{%- set expdir = pillar['nfs-server']['exports-dir'] %}
{%- set allowip = pillar['nfs-server']['nfs-allowed-client-ip'] %}
{%- set opts = pillar['nfs-server']['nfs-opts'] %}

# pkg install
nfs-server-install:
  pkg.installed:
    - name: {{ nfs.pkg }}

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
{%- if grains['os_family'] == "RedHat" %}
{{ firewall.firewall_open_service('nfs') }}
{{ firewall.firewall_open_service('rpc-bind') }}
{{ firewall.firewall_open_service('mountd') }}
{% endif %}

{%- if grains['os_family'] == "Debian" %}
{{ firewall.firewall_open('2049') }}
{% endif %}


# rpcbind service restart
rpc-binds-reload:
  service.running:
    - name: {{ nfs.rpcbind_svc }}
    - reload: True

# nfs-server 기동
nfs-server-start:
  service.running:
    - name: {{ nfs.nfs_svc }}
    - enable: True
    - watch:
      - pkg: {{ nfs.pkg }}

  

