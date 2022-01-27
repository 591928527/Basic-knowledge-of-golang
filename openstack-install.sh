#关闭安全性功能

systemctl stop firewalld
systemctl disable firewalld    ##永久性关闭
 
setenforce 0
vi /etc/sysconfig/selinux    ##永久性关闭
SELINUX=disabled

关闭NetworkManager服务
systemctl disable NetworkManager 
systemctl stop NetworkManager

##删除原有的源
cd /etc/yum.repos.d/
rm -rf *

##配置YUM源
vim CentOS-Base.repo

[openstack-train]
name=openstack-train
baseurl=https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-train/
enabled=1
gpgcheck=0
 
#[openstack-ocata]
#name=openstack-ocata
#baseurl=https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-ocata/
#enabled=1
#gpgcheck=0
 
#[openstack-rocky]
#name=openstack-rocky
#baseurl=https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-rocky/
#enabled=1
#gpgcheck=0
 
[kvm-common]
name=kvm-common
baseurl=https://mirrors.aliyun.com/centos/7/virt/x86_64/kvm-common/
enabled=1
gpgcheck=0
 
 
[base]
name=CentOS-$releasever - Base - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
baseurl=http://mirrors.163.com/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
 
#released updates
[updates]
name=CentOS-$releasever - Updates - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
baseurl=http://mirrors.163.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
baseurl=http://mirrors.163.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
name=CentOS-$releasever - Updates - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
baseurl=http://mirrors.163.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
baseurl=http://mirrors.163.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7

删除原有的缓存，建立新的缓存
[root@localhost yum.repos.d]# yum clean all
[root@localhost yum.repos.d]# yum makecache

同步阿里云的时间
[root@control ~]# yum -y install ntpdate
[root@control ~]# ntpdate ntp.aliyun.com
 
##创建计划性任务表，每两分钟更新一次时钟
[root@control ~]# crontab -e 
*/2 * * * * /usr/sbin/ntpdate ntp.aliyun.com >>/var/log/ntpdate.log
[root@control ~]# systemctl restart crond
[root@control ~]# systemctl enable crond
[root@control ~]# tail -f /var/log/ntpdate.log    ###动态查看更新日志文件，这条命令可以不敲

安装OpenStack T版
[root@OpenStack ~]# yum -y install centos-release-openstack-train

安装OpenStack-packstack软件包
[root@OpenStack ~]# yum -y install openstack-packstack 

安装OpenStack-Train

packstack --allinone 
 
##出现如下界面则安装成功
 
**** Installation completed successfully ******

查看密码
cat keystonerc_admin

登录http://192.168.43.104/dashboard/ 测试，账户为admin，密码为ccd4412cb85a4667