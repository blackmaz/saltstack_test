site_disalbe:
  module.run:
    - name: file.remove
    - path: /etc/nginx/sites-enabled/www.petclinic.kr.conf
    - onlyif: test -f /etc/nginx/sites-enabled/www.petclinic.kr.conf
