# 서버의 Network 설정과 Hostname을 변경
# 초기 세팅시에 사용이 가능함
# minion이 설치된 경우 : minion id가 캐싱되어 있어 변경전의 hostname으로 올라온다. 
# salt-ssh를 사용하는 경우 : ip가 변경되어 명령이 정상적으로 종료되지 않는다.

# hostname 변경
{%- set net = salt['pillar.get']('net') %}
system:
  network.system:
    - enabled: True
    - hostname: {{ net.hostname }}
    - apply_hostname: True
    - require_reboot: True

# 이더넷 설정 변경
{%- for id, dev in net.devs.items() %}
{{ id }}:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: {{ dev.ip }} 
    - prefix: 24
    - gateway: {{ dev.gw }}
    - dns:
{%- for ns in dev.ns %}
      - {{ ns }}
{%- endfor %}
    - defroute: yes
    - ipv4_failure_fatal: no
    - ipv6init: no
    - autoconnect_priority: -999
{%- endfor %}
