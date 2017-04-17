base:
  '*':
    - base.repo
  'server2':
    - match: list
    - mysql
#    - mysql.root_user
    - apps.petclinic.database
  'server1':
    - match: list
    - java.openjdk
    - tomcat
    - apps.petclinic.deploy

