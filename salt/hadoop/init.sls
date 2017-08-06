{% set user = 'hadoop' %}

time_sync:
  # ntp 설치하고, master를 ntp 서버로 설정하고 slave는 client 설정

create_user:
  # hadoop user 생성

ssh-key-exchange:
  # master에서 ssh-key를 생성하고 public key를 salve로 전송

install_java:

install_hadoop:
  http://mirror.navercorp.com/apache/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz
  http://mirror.apache-kr.org/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz


set_profile_{{ user }}:
  # 환경변수 설정


export JAVA_HOME=/home/ubuntu/jdk1.8.0_131
export HADOOP_HOME=/home/ubuntu/hadoop-2.8.0
export PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export CLASS_PATH=$JAVA_HOME/lib:$CLASS_PATH


set_hadoop_config:

# core-site.xml
# hdfs-site.xml
# mapred-site.xml
# yarn-site.xml
# hadoop-env.sh
# yarn-env.sh
# slaves

start_hadoop:
