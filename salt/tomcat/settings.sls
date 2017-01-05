{% set p  = salt['pillar.get']('java', {}) %}
{% set g  = salt['grains.get']('java', {}) %}

{%- set install_dir       = '/app/tomcat' %}

{%- set tomcat = {} %}
{%- do tomcat.update( { 'version_name'   : version_name,
                      'install_dir'     : install_dir,
                      'source_hash'    : source_hash,
                    } ) %}

