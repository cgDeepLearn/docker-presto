FROM centos:7

# copy source files
COPY . /opt

RUN \
  curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo && \
  curl -so /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo && \
  yum makecache && \
  yum install -y git gcc g++ make libffi-dev openssl-dev python2-pip python2-devel && \
  # 如果环境利用到pg数据库则需安装postgresql-devel
  yum install -y sudo net-tools openssh-server java-1.8.0-openjdk python3 python3-pip python3-devel postgresql-devel && \
  echo "**** SSH Configuration ****" && \
  echo 'root:root' | chpasswd && \
  ssh-keygen -t dsa -P '' -f /etc/ssh/ssh_host_dsa_key && \
  ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key && \
  ssh-keygen -t ecdsa -P '' -f /etc/ssh/ssh_host_ecdsa_key && \
  ssh-keygen -t ed25519 -P '' -f /etc/ssh/ssh_host_ed25519_key && \
  ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && \
  /usr/sbin/sshd && \
  echo "**** Installing Presto ****" && \
  # 先下好presto-admin到当前目录
  # git clone https://github.com/prestodb/presto-admin.git && \ 
  cd /opt/presto-admin && \
  # 安装 presto-amdin依赖的python2环境包
  pip install -r requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple && \
  python setup.py develop && \
  mkdir -p /root/.prestoadmin && \
  mv config.json /root/.prestoadmin/ && \
   # 先下好presto-server-rpm-0.243.1.rpm到当前目录
  presto-admin server install /opt/presto-server-rpm-0.243.1.rpm && \ 
  sed -i '/GB/d' /etc/presto/config.properties && \
  rm -f /opt/prestoadmin/packages/presto-server-rpm-0.243.1.rpm && \
  echo "**** install pip packages ****" && \
  cd /opt && \
  pip3 install -r requirements.txt -i https://mirrors.cloud.tencent.com/pypi/simple && \
  echo "**** Installing s6-overlay ****" && \
  /opt/s6-overlay-amd64-installer / && \
  echo "**** clean up ****" && \
  yum clean all && \
  rm -f /opt/presto-server-rpm-0.243.1.rpm /opt/s6-overlay-amd64-installer

# copy local files
COPY root/ /

ENTRYPOINT ["/init"]
