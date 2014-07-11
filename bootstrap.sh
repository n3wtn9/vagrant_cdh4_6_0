#! /bin/sh

cd /home/vagrant/

yum install -y curl which tar sudo openssh-server openssh-clients rsync

curl -LO 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm' -H 'Cookie: oraclelicense=accept-securebackup-cookie'
rpm -i jdk-7u51-linux-x64.rpm
rm jdk-7u51-linux-x64.rpm

echo "Add Cloudera repositories"
touch /etc/yum.repos.d/cloudera-cdh4.repo
echo "[cloudera-cdh4]" >> /etc/yum.repos.d/cloudera-cdh4.repo
echo "name=Cloudera's Distribution for Hadoop, Version 4.6.0" >> /etc/yum.repos.d/cloudera-cdh4.repo
echo "baseurl=http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/4.6.0/" >> /etc/yum.repos.d/cloudera-cdh4.repo
echo "gpgkey = http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera" >> /etc/yum.repos.d/cloudera-cdh4.repo
echo "gpgcheck = 1" >> /etc/yum.repos.d/cloudera-cdh4.repo
yum update -y

echo "Install Hadoop with 0.20"
yum install -y hadoop-0.20-conf-pseudo

echo "Format the NameNode."
sudo -u hdfs hdfs namenode -format


echo "Start HDFS"
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done


echo "Create a new /tmp directory and set permissions:"
sudo -u hdfs hadoop fs -mkdir /tmp
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp

echo "Create MapReduce Directories:"
sudo -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred

echo "Start MapReduce:"
for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo service $x start ; done

echo "Create Hadoop user:"
sudo -u hdfs hadoop fs -mkdir /user/$USER 
sudo -u hdfs hadoop fs -chown $USER /user/$USER
