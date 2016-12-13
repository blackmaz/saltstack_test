maria:
  pkg.installed:
    - pkgs:
      - mariadb
      - mariadb-server
      - MySQL-python
  service.running:
    - name: mariadb
    - enable: True
    - watch:
      - pkg: maria
  mysql_user.present:
    - name: root
    - password: {{ pillar['db_server']['root_password'] }}
    - require:
      - service: maria

firewalld:
  firewalld.present:
    - name: public
    - ports:
      - 3306/tcp
    - require:
      - service: maria
  service.running:
    - watch:
      - firewalld: firewalld

