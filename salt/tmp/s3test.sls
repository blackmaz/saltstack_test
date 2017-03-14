{%- set s3_key = salt['pillar.get']('s3.key') %}
{%- set s3_keyid = salt['pillar.get']('s3.keyid') %}
{%- set s3_region = salt['pillar.get']('s3.region') %}
{%- set s3_bucket = salt['pillar.get']('s3.bucket') %}
{%- set s3_filename = "petclinic.war" %}

install_awscli:
  pkg:
    - installed
    - name: awscli

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
    - name: aws s3 cp s3://{{ s3_bucket }}/{{ s3_filename }} ./{{ s3_filename }} --region={{ s3_region }}