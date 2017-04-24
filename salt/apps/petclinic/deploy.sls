{%- set company = salt['pillar.get']('company','sample') %}
{%- set system  = salt['pillar.get']('system','petclinic') %}
{%- set s3      = salt['pillar.get'](company+':'+system+':apps:petclinic:source:s3') %}
{%- set tmp     = salt['pillar.get'](company+':'+system+':apps:petclinic:tmp') %}
{%- set tomcat  = salt['pillar.get'](company+':'+system+':apps:petclinic:target:tomcat') %}

s3_filedownload:
  cmd.run:
    - name: aws s3 cp s3://{{ s3.bucket }}/{{ s3.filename }} {{ tmp }}/{{ s3.filename }} --region={{ s3.region }}

deploy-sample-war:
  cmd.run:
    - name: cp {{ tmp }}/{{ s3.filename }} {{ tomcat.home }}/{{tomcat.appBase}}/{{ s3.filename }}
    - unless: test -f {{ tomcat.home }}/{{tomcat.appBase}}/{{ s3.filename }}
