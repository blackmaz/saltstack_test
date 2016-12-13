nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
    - watch:
      - pkg: nginx

firewalld_nginx:
  firewalld.present:
    - name: public
    - masquerade: False
    - services:
      - http
    - ports:
      - 8080/tcp
    - require: 
      - service: nginx
  service.running:
    - name: firewalld
    - watch:
      - firewalld: firewalld_nginx

