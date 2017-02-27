{% for key, value in salt['pillar.get']('physical server',{}).items() %}
{% if salt['grains.get']('host') == value.get('hostname') %}
{{ value.get('ip') }}:
  cmd.run:
    - name: id 
{% endif %}
{% endfor %}

{% set ip = ",".join(salt['grains.get']('ipv4')) %}
{{ ip }}:
  cmd.run:
    - name: id 

{% set cc = salt['pillar.get']('logical server',{}).get('db').get('physical server')[0] %}
{% set dd = salt['pillar.get']('physical server',{}).get(cc).get('ip') %}

{{ dd }}:
  cmd.run:
    - name: ls 

{% set tomcat_insthome = pillar['tomcat']['tomcat_insthome'] %}
{% set tomcat_downloadurl = pillar['tomcat']['tomcat_downloadurl'] %}
{% set tomcat_downloadhash = pillar['tomcat']['tomcat_downloadhash'] %}
unpack-tomcat-tar:
  archive.extracted:
    - name: {{ tomcat_insthome }}
    - source:  {{ tomcat_downloadurl }}
    - source_hash: sha1={{ tomcat_downloadhash }}
    - archive_format: tar
    - tar_option: zxvf

{% set deploy_downloadurl = pillar['application']['deploy_downloadurl'] %}
download-sample-tar:
  file.managed:
    - name: {{ tomcat_insthome }}/aaa.zip
    - soruce: {{ deploy_downloadurl }}



