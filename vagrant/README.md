# Vagrant + Vbox를 이용한 Test환경 구성
saltstack를 테스트하기 위해서 Virtualbox와 vagrant를 이용하여 테스트 환경을 구성하는 방법을 설명하고 있다.
vagrant는 가상머신의 생성과 삭제 등을 코드로 구현 할수 있도록 해주고, 여러 종류의 하이퍼바이저와 클라우드 프로바이더를 지원하지만 로컬 PC에서 테스트하기에 가장 적합한 virtualbox를 선택했다.(무료, 테스트케이스가 가장 많이 통용됨)

## VBox
VirtualBox는 엔터프라이즈와 가정용으로 사용할 수 있는 x86 및 AMD64/인텔64 가상화 제품이다. 엔터프라이즈 고객을 위해 풍부한 기능과 고성능을 제공하고 GNU General Public License (GPL) 버전 2의 조건에 따라 오픈 소스 소프트웨어로 자유롭게 사용할 수 있는 유일한 전문 솔루션이다.
VBox는 윈도우, 리눅스, 맥, 솔라리스를 호스트 OS로 사용할 수 있으며, 많은 수의 Guest OS를 지원하고 있다. https://www.virtualbox.org/wiki/Guest_OSes

### 설치
다운로드 페이지 https://www.virtualbox.org/wiki/Downloads 에서 플랫폼에 맞는 설치 패키지를 다운받을수 있으며, 각 OS별 표준 설치 절차에 따라 설치한다. 

### 네트워킹
* NAT
 * VBox의 기본 네트워크 모드
 * 별다른 설정 없이 가상머신이 외부 네트워크로 엑세스
 * 가상시스템 간 통신이 불가능하며, 외부 네트워크에서 가상머신으로 접속이 불가능함 
* NAT Network
 * 가정용 라우터(공유기)와 비슷한 방식으로 작동
 * 네트워크를 그룹화 하여 외부에서 가상머신으로 접속은 방지하지만 내부 시스템간 통신이 가능함
* Brideged Networking
 * 호스트 OS의 네트워크 장치와 직접 연결
 * 가상머신은 실제 호스트 OS와 연결된 물리적인 네트워크와 직접 연결된 것 처럼 보임
 * 호스트 OS에 Bridge된 NIC와 동일한 IP 대역을 사용
* Internal Networking
 * 호스트 OS내부의 다른 가상머신과 통신이 가능한 네트워크
* Host-only Networking
 * 호스트 OS에 가상의 네트워크 인터페이스를 생성하고 호스트와 가상머신간 통신을 지원


## vagrant
Vagrant는 단일 워크 플로에서 가상 컴퓨터 환경을 만들고 관리하기 위한 도구다. 사용하기 쉬운 워크플로우와 자동화에 초점을 맞춰 개발 환경 설정 시간을 단축한다. Vagrant는 산업 표준 기술을 기반으로 구성되고 재사용이 가능하며 이동이 간편한 작업 환경을 제공한다. 일관된 단일 워크 플로로 제어되므로 생산성과 유연성을 극대화 할 수 있다. 머신은 VirtualBox, VMware, AWS 또는 기타 다른 공급 업체에 프로비저닝 된다. 쉘 스크립트, Chef 또는 Puppet과 같은 업계 표준 프로비저닝 도구를  이용하여 가상 시스템에 소프트웨어를 자동으로 설치하고 구성 할 수 있다.
* Vagrant가 지원하는 가상화 기술
 * VirtualBox
 * VMware
 * KVM
 * Linux Container(LXC)
 * Docker
  
### 설치
다운로드 페이지 https://www.vagrantup.com/downloads.html 에서 플랫폼에 해당하는 설치 프로그램 또는 패키지를 얻을수 있으며, 운영 체제에 맞는 표준 절차를 사용하여 패키지를 설치한다. 설치 프로그램이 vagrant를 시스템 경로에 자동으로 추가하여 터미널에서 명령을 사용할 수 있다. 명령을 찾을수 없을 경우 시스템에서 로그 아웃하고 다시 로그인한다.(Windows의 경우가 특히 필요할 수 있음)

* Rubygem으로 설치
 * 1.0.x는 지원하였으나 더이상 지원하지 않음
 * 새로운 버전을 설치하기 전에 Rubygem으로 설치한 버전을 삭제할 것

* Repositoy를 이용한 설치
 * 종속성 설치가 빠져있거나 오래된 버전의 Vagrant가 설치됨
 * 권장하지 않음

* 소스를 받아서 설치할 경우 (권장하지 않음)
 * Ruby(2.2 이상) 설치
 * Vagrant 설치

<pre><code>
$ git clone https://github.com/mitchellh/vagrant.git
$ cd /path/to/your/vagrant/clone
$ bundle install
</code></pre>

### 용어
* Providers: 가상 환경을 말함 (VirtualBox와 VM Ware, EC2 등)
* Provisioning: 미들웨어의 구성과 설치를 하는 도구 도구 (쉘 스크립트, Chef (chef-solo, chef-client) Puppet 등)
* Boxes: 가상 머신 시작시 기반이되는 이미지 파일, 가상 환경을 만드는데 필요함, 일반적으로 OS 이미지에서 작성
* Vagrantfile: 

### 기본 명령

* Box 관리 명령
 * 가상머신 시작시 기반이 되는 이미지 파일(box)를 다운로드 받음
 * https://app.vagrantup.com/boxes/search 에서 box이미지를 검색하여 사용이 가능함
<pre><code>
$ vagrant box add NAME
</code></pre>
 * 내 서버에 존재하는 Box의 목록
<pre><code>
$ vagrant box list
</code></pre>
 * 내 서버에 존재하는 Box 중 버전이 변경된 경우 새로운 버전으로 갱신
<pre><code>
$ vagrant box update
</code></pre>
 * 새로운 버전으로 갱신된 box 중 이전 버전을 모두 삭제
<pre><code>
$ vagrant box prune
</code></pre>
 * box 제거
<pre><code>
$ vagrant box remove
</code></pre>
* VM 생성 및 관리
 * Vagrantfile을 자동으로 생성, box의 이름을 지정하면 해당 box를 지정하여 파일이 생성됨
<pre><code>
$ vagrant init [box-name]
</code></pre>
 * Vagrnatfile을 이용하여 가상머신을 부팅
<pre><code>
$ vagrant up
</code></pre>
 * 가상머신 재부팅
<pre><code>
$ vagrant reload
</code></pre>
 * 가상머신 재부팅 + 프로비저닝 재실행 
  * 프로비저닝은 최초 up할때 한번만 수행되며 그 이후에 프로비저닝 쉘이 변경되어 재수행 할 경우에는 명시적으로 이 명령을 이용해야 함
<pre><code>
$ vagrant provision
</code></pre>
 * 가상머신에 ssh 접속, 여러 서버를 구성했을 경우에는 접속대상 서버의 명을 지정해줌
<pre><code>
$ vagrant ssh [name]
</code></pre>
 * 가상머신 종료, OS의 작업 상태는 유지되면서 서버 shutdown한것과 동일함
<pre><code>
$ vagrant halt
</code></pre>
 * 가상머신 제거, OS를 날려버리는 것
<pre><code>
$ vagrant destroy
</code></pre>
* 상태 보기
<pre><code>
$ vagrant status
$ vagrant global-status
</code></pre>
* 프로비저닝까지 된 가상머신을 box로 패키징
<pre><code>
$ vagrant package
</code></pre>

### 공유 디렉토리

### 네트워크 설정

### 여러 서버 동시에 구성하기

