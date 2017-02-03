{% set p  = salt['pillar.get']('java', {}) %}
{% set g  = salt['grains.get']('java', {}) %}

{%- set salt_home = '/root/saltstack_test/salt' %}
{%- set salt_tomcat_filedir = salt_home + '/tomcat/files' %}
<<<<<<< HEAD
=======
{%- set java_home = '/opt/java/jdk1.8.0_111' %}
>>>>>>> 653c76582ecbde694a15a5fbf120ce784aaaba2e
{%- set tomcat_home = '/app/tomcat' %}
{%- set tomcat_version = 'apache-tomcat-8.5.9' %}
{%- set tomcat_tar = tomcat_version + '.tar.gz' %}
{%- set tomcat_downloadurl = 'http://mirror.navercorp.com/apache/tomcat/tomcat-8/v8.5.9/bin/' + tomcat_tar %}
{%- set tomcat_downloadhash = '3c800e7affdf93bf4dbcf44bd852904449b786f6' %}
<<<<<<< HEAD
{%- set java_opts = '-server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC' %}
=======
{%- set java_opts = '-server -Xms512m -Xmx512m -XX:MaxPermSize=128m -XX:+DisableExplicitGC' %}
>>>>>>> 653c76582ecbde694a15a5fbf120ce784aaaba2e
{%- set tomcat = {} %}
{%- do tomcat.update( { 'version'   : tomcat_version,
                      'downloadurl'     : tomcat_downloadurl,
                      'downloadhash'    : tomcat_downloadhash,
<<<<<<< HEAD
=======
                      'java_home'       : java_home,
>>>>>>> 653c76582ecbde694a15a5fbf120ce784aaaba2e
                      'java_opts'       : java_opts,
                      'tomcat_insthome'      : tomcat_home,
                      'tomcat_home'  : tomcat_home+"/"+tomcat_version,
                      'tomcat_tar'      : tomcat_tar,
                      'salt_home'       : salt_home,
                      'salt_tomcat_filedir' : salt_tomcat_filedir,
                    } ) %}
