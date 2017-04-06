{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set tomcat_home = salt['pillar.get'](company+':'+system+':software:tomcat:install:home') %}
{%- set s3_key = salt['pillar.get'](company+':'+system+':software:apps:s3:key') %}
{%- set s3_keyid = salt['pillar.get'](company+':'+system+':software:apps:s3:keyid') %}
{%- set s3_region = salt['pillar.get'](company+':'+system+':software:apps:s3:region') %}
{%- set s3_bucket = salt['pillar.get'](company+':'+system+':software:apps:s3:bucket') %}
{%- set s3_filename = 'petclinic.war' %}

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
    - name: aws s3 cp s3://{{ s3_bucket }}/{{ s3_filename }} /tmp/{{ s3_filename }} --region={{ s3_region }}

deploy-sample-war:
  cmd.run:
    - name: cp '/tmp/'{{ s3_filename }} {{ tomcat_home }}/webapps/{{ s3_filename }}
    - unless: test -f {{ tomcat_home }}/webapps/{{ s3_filename }}
