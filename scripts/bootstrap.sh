#!/bin/bash

echo "Update /etc/apt/sources.list:"
sudo cat > /etc/apt/sources.list <<EOL
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial  main  restricted  universe  multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt xenial  main  restricted  universe  multiverse

deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates  main  restricted  universe  multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates  main  restricted  universe  multiverse

deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports  main  restricted  universe  multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports  main  restricted  universe  multiverse

deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security  main  restricted  universe  multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt xenial-security  main  restricted  universe  multiverse
EOL

echo "Install ssh rsyncwgetopenjdk-8-jdk:"
sudo apt update
sudo apt install ssh rsync wget openjdk-8-jdk -y

echo "Export JVM:"
export  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

echo "Install Hadoop:"
wget http://www.gtlib.gatech.edu/pub/apache/hadoop/common/hadoop-2.9.1/hadoop-2.9.1.tar.gz
tar -zxvf  hadoop-2.9.1.tar.gz
sudo cp -r hadoop-2.9.1 /usr/share/hadoop
export HADOOP_HOME=/usr/share/hadoop

echo "Disable IPV6:"
sudo sed -i "\$anet.ipv6.conf.all.disable_ipv6 =  1" /etc/sysctl.conf
sudo sed -i "\$anet.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf
sudo sed -i "\$anet.ipv6.conf.lo.disable_ipv6 =  1" /etc/sysctl.conf
sudo sysctl -p

echo "Configure Hadoop:"
sudo mkdir -p /etc/hadoop/conf
sudo cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml
sudo sed -i "\$aexport  JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" $HADOOP_HOME/etc/hadoop/hadoop-env.sh
sudo ln -s $HADOOP_HOME/etc/hadoop/* /etc/hadoop/conf/
sudo mkdir $HADOOP_HOME/logs
sudo groupadd hadoop
sudo useradd -g hadoop hdfs
sudo useradd -g hadoop yarn
sudo chgrp -R hadoop /usr/share/hadoop
sudo chmod -R 777 /usr/share/hadoop

echo "Update Hadoop config files:"

sudo sed --follow-symlinks -i "/<configuration>/a <property>\ \n<name>fs.defaultFS</name>\ \n<value>hdfs://0.0.0.0:9000</value>\ \n</property> " /etc/hadoop/conf/core-site.xml
sudo sed --follow-symlinks -i "/<configuration>/a <property>\ \n<name>dfs.replication</name>\ \n<value>1</value>\ \n</property>" /etc/hadoop/conf/hdfs-site.xml
sudo sed --follow-symlinks -i "/<configuration>/a <property>\ \n<name>yarn.resourcemanager.hostname</name>\ \n<value>0.0.0.0</value>\ \n</property>\ \n<property>\ \n<name>yarn.nodemanager.aux-services</name>\ \n<value>mapreduce_shuffle</value>\ \n</property>" /etc/hadoop/conf/yarn-site.xml
sudo sed --follow-symlinks -i "/<configuration>/a <property>\ \n<name>mapreduce.framework.name</name>\ \n<value>yarn</value>\ \n</property>" /etc/hadoop/conf/mapred-site.xml

echo "Format HDFS NameNode:"
sudo -u hdfs $HADOOP_HOME/bin/hdfs namenode -format

echo "Init daemons NameNode and DataNode (HDFS):"
sudo -u hdfs $HADOOP_HOME/sbin/hadoop-daemon.sh start namenode
sudo -u hdfs $HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

echo "Init daemons ResourceManager and NodeManager (YARN):"
sudo -u yarn $HADOOP_HOME/sbin/yarn-daemon.sh start resourcemanager
sudo -u yarn $HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

echo "Config dirs HDFS"
sudo -u hdfs $HADOOP_HOME/bin/hadoop fs -mkdir -p /user/$USER
sudo -u hdfs $HADOOP_HOME/bin/hadoop fs -chown $USER:$USER /user/$USER
sudo -u hdfs $HADOOP_HOME/bin/hadoop fs -mkdir /tmp
sudo -u hdfs $HADOOP_HOME/bin/hadoop fs -chmod 777 /tmp