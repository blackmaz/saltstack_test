{%- set tomcat_home = '/www/nest/tomcat7' %}
{%- set deploy_tar = 'webapps_ozr.zip' %}
{%- set deploy_downloadurl = 'https://www.dropbox.com/s/y257ychikv0gwz1/webapps_ozr.zip?dl=0' %}

install-unzip:
  pkg.installed:
    - pkgs:
      - unzip

download-sample-tar:
  cmd.run:
    - name: curl -s -L -o '/tmp/'{{ deploy_tar }} {{ deploy_downloadurl }}
    - unless: test -f '/tmp/'{{ deploy_tar }}

deploy-sample-tar:
  cmd.run:
    - name: cp '/tmp/'{{ deploy_tar }} {{ tomcat_home }}
    - unless: test -f {{ tomcat_home }}/{{ deploy_tar }}

unpack-sample-tar:
  cmd.run:
    - name: cd {{ tomcat_home }};mv webapps webapps_origin;unzip {{ deploy_tar }}
