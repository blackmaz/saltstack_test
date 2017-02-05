base:
  '*':
    - base.repo
  'vm83,vm93':
    - match: list
    - mysql
#    - mysql.root_user
    - mysql_user.petclinic
  'vm84,vm94':
    - match: list
    - sun-java
    - tomcat
    - tomcat.deploy
    - apache

