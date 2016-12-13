redis:
  pkg.installed:
    - pkgs:
      - redis
  service.running:
    - name: redis
    - enable: True
    - watch: 
      - pkg: redis

firewalld_redis:
  firewalld.present:
    - name: public
    - ports:
      - 6379/tcp
    - require:
      - service: redis
  service.running:
    - name: firewalld
    - watch:
      - firewalld: firewalld_redis

