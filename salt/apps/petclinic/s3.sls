{%- set company = salt['pillar.get']('company','sample') %}
{%- set system  = salt['pillar.get']('system','petclinic') %}
{%- set s3 = salt['pillar.get'](company+':'+system+':apps:petclinic:source:s3') %}

install_awscli:
  pkg:
    - installed
    - name: awscli

make_s3_credential1:
   environ.setenv:
     - name: AWS_SECRET_ACCESS_KEY
     - value: {{ s3.key }}
     - update_minion: True

make_s3_credential2:
   environ.setenv:
     - name: AWS_ACCESS_KEY_ID
     - value: {{ s3.keyid }}
     - update_minion: True

