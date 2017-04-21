{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set tomcat_home = salt['pillar.get'](company+':'+system+':software:tomcat:install:home') %}
{%- set s3_key = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:key') %}
{%- set s3_keyid = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:keyid') %}
{%- set s3_region = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:region') %}
{%- set s3_bucket = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:bucket') %}
{%- set s3_downloadDir = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:downloadDir') %}
{%- set s3_filename = salt['pillar.get'](company+':'+system+':apps:petclinic:deploy:filename') %}

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
