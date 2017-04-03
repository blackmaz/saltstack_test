# 호스트 파일에 신규 서버를 추가한다. 
# master 서버를 간단한 dns 서버로 사용할 수 있도록 설정하는 경우.
# 별도로 dns 등록하는 절차가 있다면 추가해보자
# master 서버의 host에 추가 하는 것이므로 salt-call명령을 이용해서 수행한다.
# salt-call --local state.apply common.host

{%- set net = salt['pillar.get']('net') %}

add_host:
  host.present:
    - name: {{ net.hostname }}
    - ip: {{ net.service_ip }}

restart_dnsmasq:
  module.run:
    - name: service.restart
    - m_name: dnsmasq
