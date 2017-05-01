# 서버의 Hostname을 변경
# 초기 세팅시에 사용이 가능함
# minion이 설치된 경우 : minion id가 캐싱되어 있어 변경전의 hostname으로 올라온다. 
# salt-ssh를 사용하는 경우 : ip가 변경되어 명령이 정상적으로 종료되지 않는다.

# hostname 변경
{%- set hostname = salt['pillar.get']('hostname') %}
system:
  network.system:
    - enabled: True
    - hostname: {{ hostname }}
    - apply_hostname: True
    - require_reboot: True

