{%- set s3_key = salt['pillar.get']('s3.key') %}
{%- set s3_keyid = salt['pillar.get']('s3.keyid') %}
{%- set s3_region = salt['pillar.get']('s3.region') %}
{%- set s3_bucket = salt['pillar.get']('s3.bucket') %}
{%- set s3_filename = salt['pillar.get']('s3.filename') %}

install_awscli:
  pkg:
    - installed
    - name: awscli

awscli-config-dir:
  file.directory:
    - name: ~/.aws
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

make_s3_credential1:
   environ.setenv:
     - name: AWS_SECRET_ACCESS_KEY
     - value: {{ s3_key }}
     - update_minion: True

make_s3_credential2:
   environ.setenv:
     - name: AWS_ACCESS_KEY_ID
     - value: {{ s3_keyid }}
     - update_minion: True

s3_filedownload:
  cmd.run:
    - name: aws s3 cp s3://my-bucket-for-fileserver/petclinic.war ./petclinic.war --region={{ s3_region }}
