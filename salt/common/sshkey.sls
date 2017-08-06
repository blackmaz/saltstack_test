# cp.push를 사용하여 hadoop master의 pub-key를 salt-master로 전달
# 해당 모듈을 사용하기 위해서는 /etc/salt/master에 "file_recv: True" 설정 필요
# True인 경우 파일은 /var/cache/salt/master/minions/minion-id/files에 생성됨
# master로 push한 파일을 다른 minion에서 사용하기 위해서는 fileserver_backend를 추가
# fileserver_backend:
#  - roots
#  - minion
# 다른 미니언에서 파일 접근시에는 salt://미니언id/file/path/file_name으로 접근
{%- set user_id = 'sungsic' %}
{%- set ssh_master = 'test1' %}
{%- set minion_id = salt['grains.get']('id') %}

{%- if ssh_master == minion_id %}
ssh_keygen_rsa:
  cmd.run:
    - name: ssh-keygen -t rsa -N '' -f /home/{{ user_id }}/.ssh/id_rsa
    - creates: /home/{{ user_id }}/.ssh/id_rsa
    - user: {{ user_id }}

ssh_public_key_exchange:
  module.run:
    - name: cp.push
    - path: /home/{{ user_id }}/.ssh/id_rsa.pub
{%- else %}
ssh_public_key_exchange:
  file.append:
    - name: /home/{{ user_id }}/.ssh/authorized_keys
    - source: salt://{{ ssh_master }}/home/{{ user_id }}/.ssh/id_rsa.pub
{%- endif %}

