# 서버의 Hostname을 변경
# 초기 세팅시에 사용이 가능함

# hostname 변경
{%- set hostname = salt['pillar.get']('hostname') %}
system:
  network.system:
    - enabled: True
    - hostname: {{ hostname }}
    - apply_hostname: True
    - require_reboot: True

