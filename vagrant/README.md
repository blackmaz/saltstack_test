Vagrant + Vbox를 이용한 Test환경 구성
=====================================
VBox
-------


vagrant
-------
Vagrant는 단일 워크 플로에서 가상 컴퓨터 환경을 만들고 관리하기 위한 도구다. 사용하기 쉬운 워크플로우와 자동화에 초점을 맞춰 개발 환경 설정 시간을 단축한다. Vagrant는 산업 표준 기술을 기반으로 구성되고 재사용이 가능하며 이동이 간편한 작업 환경을 제공한다. 일관된 단일 워크 플로로 제어되므로 생산성과 유연성을 극대화 할 수 있다. 머신은 VirtualBox, VMware, AWS 또는 기타 다른 공급 업체에 프로비저닝 된다. 쉘 스크립트, Chef 또는 Puppet과 같은 업계 표준 프로비저닝 도구를  이용하여 가상 시스템에 소프트웨어를 자동으로 설치하고 구성 할 수 있다.
* Vagrant가 지원하는 가상화 기술
  * VirtualBox
  * VMware
  * KVM
  * Linux Container(LXC)
  * Docker
  
# 설치
다운로드 페이지 https://www.vagrantup.com/downloads.html 에서 플랫폼에 해당하는 설치 프로그램 또는 패키지를 얻을수 있으며, 운영 체제에 맞는 표준 절차를 사용하여 패키지를 설치한다. 설치 프로그램이 vagrant를 시스템 경로에 자동으로 추가하여 터미널에서 명령을 사용할 수 있다. 명령을 찾을수 없을 경우 시스템에서 로그 아웃하고 다시 로그인한다.(Windows의 경우가 특히 필요할 수 있음)

* Rubygem으로 설치
  * 1.0.x는 지원하였으나 더이상 지원하지 않음
  * 새로운 버전을 설치하기 전에 Rubygem으로 설치한 버전을 삭제할 것

* Repositoy를 이용한 설치
  * 종속성 설치가 빠져있거나 오래된 버전의 Vagrant가 설치됨
  * 권장하지 않음

* 설치 순서
  * Ruby(2.2 이상) 설치
  * Vagrant 설치
<pre><code>
$ git clone https://github.com/mitchellh/vagrant.git
$ cd /path/to/your/vagrant/clone
$ bundle install
</code></pre>

* 간단한 사용법

# 용어
* 공급자 : 가상 환경을 말함 (VirtualBox와 VM Ware, EC2 등)
* 프로비저닝 : 미들웨어의 구성과 설치를 하는 도구 도구 (쉘 스크립트, Chef (chef-solo, chef-client) Puppet 등)
* Box 파일 : 가상 머신 시작시 기반이되는 이미지 파일, 가상 환경을 만드는데 필요함, 일반적으로 OS 이미지에서 작성

# 설치

# Vagrant 를 사용할 때 최소한의 설정 조건
 - Vagrant 사용자
 - sshd 시작
 - 프로비저닝 도구
 - Vagrantfile
가상 머신의 사양이나 프로비저닝 도구의 지정 등 가상 머신의 구성
Ruby 기반으로 작성
기본적으로 파일과 프로비저닝 도구 설정로 2개의 파일이 있으면 동일한 환경을 구성할 수 있음

# 기본 명령어
버전 확인
<pre><code>
$ vagrant -v

도움말

$ vagrant -h

가상 환경의 기반이되는 Box 파일을 준비
다음의 명령으로 box를 받아서 로컬에 추가한다.
Vagrantfile의 config.vm.box 디렉토리로 지정

$ vagrant box add NAME URL
$ vagrant box add centos64 http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box

Box 목록 확인

$ vagrant box list
'''
# Vagrantfile
'''
$ vagrant init BOX_NAME
$ vagrant init centos64
'''
Vagrantfile 설정
'''
$ Vagrant.configure (VAGRANTFILE_API_VERSION) do | config |
     config.vm.box = "centos64"

     // 네트워크 설정
     config.vm.network : private_network, ip : "192.168.33.10"

     // GUI 모드의 설정
     config.vm.provider : virtualbox do | vb |
         vb.gui = true
     end
end
'''
호스트 온리 네트워크
호스트 OS와 게스트 OS간에서만 통신을 할 수있는 네트워크.
예시에서는 게스트에 192.168.33.10 (선택)을 할당
가상 머신의 시작

Vagrantfile과 같은 디렉토리에서 실행
$ vagrant up

GUI 모드라면 VirtualBox를 시작할 때 id / pass를 모두 "vagrant" 로그인
ssh에 로그인
가상 머신에서 sshd가 시작되어 있어야 사용할 수 있음
$ vagrant ssh

일반적인으로 ssh를 사용해서 vagrant를 사용한다.
$ ssh 192.168.33.10

호스트에서 ssh 접속을 위한 설정방법
# ~/.ssh/config
Host 192.168.33. *
IdentityFile ~ / .vagrant.d / insecure_private_key
User vagrant

가상 서버에 ssh 설정을 이용해서 로그인 할 수있다.
$ vagrant ssh-config --host melody
$ vagrant ssh-config --host melody >> ~ / .ssh / config

$ ssh melody

ssh 로그인시 설정 확인
$ vagrant ssh-config

status 확인
$ vagrant status
Current machine states :
default running (virtualbox)
(가상 머신 이름) (status)

가상 머신의 정지
$ vagrant halt

가상 컴퓨터 삭제
$ vagrant destroy

가상 머신 내보내기
$ vagrant package

package.box라는 Box 파일이 생성
이것을 배포 받는 쪽에서는 다음을 입력한다.
$ vagrant box add new_box package.box
