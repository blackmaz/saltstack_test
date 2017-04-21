{%- set company = salt['pillar.get']('company','default') %}
{%- set system  = salt['pillar.get']('system','default') %}
{%- set tomcat_home = salt['pillar.get'](company+':'+system+':software:tomcat:install:home') %}
{%- set s3_key = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:key') %}
{%- set s3_keyid = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:keyid') %}
{%- set s3_region = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:region') %}
{%- set s3_bucket = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:bucket') %}
{%- set s3_downloadDir = salt['pillar.get'](company+':'+system+':apps:petclinic:s3:downloadDir') %}
{%- set s3_filename = salt['pillar.get'](company+':'+system+':apps:petclinic:deploy:filename') %}

s3_filedownload:
  cmd.run:
    - name: aws s3 cp s3://{{ s3_bucket }}/{{ s3_filename }} {{ s3_downloadDir }}/{{ s3_filename }} --region={{ s3_region }}

deploy-sample-war:
  cmd.run:
    - name: cp {{ s3_downloadDir }}/{{ s3_filename }} {{ tomcat_home }}/webapps/{{ s3_filename }}
    - unless: test -f {{ tomcat_home }}/webapps/{{ s3_filename }}
