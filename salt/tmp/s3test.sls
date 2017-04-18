# S3파일 다운로드를 위한 state
# deploy될 application 및 data등을 포함
# 인증 정보는 pillar에서 가져오도록 하며, 보안을 위해 xxxx로 표시
{%- set s3_key = salt['pillar.get']('software:common:s3:key') %}
{%- set s3_keyid = salt['pillar.get']('software:common:s3:keyid') %}
{%- set s3_region = salt['pillar.get']('software:common:s3:region') %}
{%- set s3_bucket = salt['pillar.get']('software:common:s3:bucket') %}
{%- set s3_filename = "petclinic.war" %}

# ubuntu,debian 계열의 경우
{% if grains['os_family']=="Debian" %}

install_awscli:
  pkg:
    - installed
    - name: awscli

{% endif %}
# centos, redhat 계열의 경우
# yum repository에 awscli가 없어서, pip를 통해 설치
{% if grains['os_family']=="RedHat" %}

install_devtools:
  pkg.group_installed:
    - name: "Development Tools"

install_epelrepo:
  cmd.run:
    - name: rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

install_pip:
  pkg:
    - installed
    - name: python-pip

install_awscli:
  cmd.run:
    - name: pip install awscli

{% endif %}

# aws s3 accesskey, secretkey 설정 - AWS IAM에서 권한 설정 후 이용
# 방법은 여러 가지가 있으나, 환경변수에 set하도록 함
make_s3_credential1:
   environ.setenv:
     - name: AWS_ACCESS_KEY_ID
     - value: {{ s3_keyid }}
     - update_minion: True

make_s3_credential2:
   environ.setenv:
     - name: AWS_SECRET_ACCESS_KEY
     - value: {{ s3_key }}
     - update_minion: True

# cp 명령으로 s3에서 파일 다운로드
# 차후 바뀌는 정도라면(파일 업데이트 시) sync로 고려할 것
s3_filedownload:
  cmd.run:
    - name: aws s3 cp s3://{{ s3_bucket }}/{{ s3_filename }} ./{{ s3_filename }} --region={{ s3_region }}
