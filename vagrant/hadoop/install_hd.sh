#ntp로 서버간 시간 동기화

#마스터의 ssh-key로 slave에 접속 가능하도록 처리
# ssh-keygetn -t rsa 
# ssh-copy-id ubuntu@slave-server
# passwd입력은 sshpass 명령 이용
# sshpass -p "remote password" ssh-copy-id ubuntu@slave-server

#호스트파일에 클러스터에 포함될 서버들 등록
# 127.0.0.1 로 호스트명이 설정되는 경우에 마스터가 로컬에서만 리스닝을 하므로 확인 필

#환경변수 잡아줌요
#cat /vagrant/hadoop_bashrc >> /home/ubuntu/.profile

#자바 설치
#cp -r /vagrant/jdk1.8.0_131 /home/ubuntu

#하둡 설치
#cp -r /vagrant/hadoop-2.8.0 /home/ubuntu

#하둡 컨피그 
# 파일의 위치 : hadoop_home/etc/hadoop/
# 수정대상 파일들
# core-site.xml
# hdfs-site.xml
# mapred-site.xml
# yarn-site.xml
# hadoop-env.sh
# yarn-env.sh
# slaves

# 하둡 실행
# start-all.sh

# 하둡 종료
# stop-all.sh
