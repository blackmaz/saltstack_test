# NFS Client 구성 state

# pillar/nfs.sls
{%- set mountdir = pillar['nfs-client']['mount-dir'] %}
{%- set fstabopt = pillar['nfs-client']['fstab-opts'] %}
{%- set serverip = pillar['nfs-server']['server-ip'] %}
{%- set shareddir= pillar['nfs-server']['exports-dir'] %}

# nfs 설정
{%- set nfs = salt['grains.filter_by']({
  'Debian': {
    'pkg': 'nfs-common'
  },
  'RedHat': {
    'pkg': 'nfs-utils'
  },
})
%}
# pkg install
nfs-client-install:
  pkg.installed:
    - name: {{ nfs.pkg }}

# mount directore 생성
{{ mountdir }}:
  file.directory:
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

#mount
mount-{{ mountdir }}:
  mount.mounted:
    - name: {{mountdir}}
    - device: {{serverip}}:{{shareddir}}
    - fstype: nfs
    - opts: {{fstabopt}}


