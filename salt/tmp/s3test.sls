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

#s3_credentials:
#  file.managed:
#    - source: salt://tmp/_s3_credentials
#    - name: ~/.aws/credentials
#    - user: root
#    - group: root
#    - mode: '600'
#    - template: jinja
#    - context:
#        s3_key: {{ s3_key }}
#        s3_keyid: {{ s3_keyid }}

make-s3-credentials:
  cmd.run:
    - name: export AWS_SECRET_ACCESS_KEY={{ s3_key }};export AWS_ACCESS_KEY_ID={{ s3_keyid }};export AWS_DEFAULT_REGION={{ s3_region }}

s3_config:
  file.managed:
    - source: salt://tmp/_s3_config
    - name: ~/.aws/config
    - user: root
    - group: root
    - mode: '600'
    - template: jinja
    - context:
        s3_region: {{ s3_region }}

#s3test:
#  file.managed:
#    - name: /root/petclinic.war
#    - source: s3://my-bucket-for-fileserver/petclinic.war
#    - source_hash: md5=ca347e8e20321d1573e0a1d42ad2c48c
