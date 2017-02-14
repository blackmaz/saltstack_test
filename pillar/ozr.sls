####################################
### ozr pillar
####################################
# pillar update
#$ salt 'test2' saltutil.refresh_pillar
# pillar select
#$ salt 'test2' pillar.items

db_server:
  root_password: manager365
  database_nm: nest
  
application:
  name: ozr
  db_user: root
  database_name: nest
  db_user_password: manager365
  service_ip: 192.168.10.10
  deploy_tar: webapps_ozr.zip
  deploy_downloadurl: https://www.dropbox.com/s/y257ychikv0gwz1/webapps_ozr.zip?dl=0
  datasource_url: jdbc:mysql://localhost:3306/nest


tomcat:
  tomcat_insthome: /www/nest
  tomcat_dir: tomcat7
  tomcat_home: /www/nest/tomcat7
  tomcat_version: apache-tomcat-7.0.75
  tomcat_downloadurl: http://apache.mirror.cdnetworks.com/tomcat/tomcat-7/v7.0.75/bin/apache-tomcat-7.0.75.tar.gz
  tomcat_downloadhash: 1373d27e7e9cd4c481b4b17c6b2c36aff157b66e
  tomcat_java_opts: -server -Xms512m -Xmx512m -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+DisableExplicitGC
