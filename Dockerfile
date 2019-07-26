FROM python:3.6
ENV SUDOFILE /etc/sudoers
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
Run apt-get update -y &&\
    apt-get -y install \
           rsyslog \
           systemd \
           passwd \
           openssh-client \
           openssh-server \
           sudo \
           wget \
           git \
           openssl \
           sed \
           locales \
           nginx \
           vim \
           nodejs \
           dstat &&\
           apt-get clean all

RUN pip install --upgrade pip setuptools ansible virtualenv circus tox passlib
## setup sshd and generate ssh-keys by init script
RUN mkdir -p /var/run/sshd &&\
    ssh-keygen -A &&\
    useradd -m -s /bin/bash vagrant &&\
    echo -e "vagrant:vagrant" | (passwd -dq vagrant) &&\
    echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant &&\
    chmod 440 /etc/sudoers.d/vagrant &&\
    mkdir -p /home/vagrant/.ssh &&\
    chmod 700 /home/vagrant/.ssh &&\
    systemctl enable nginx

ADD https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub /home/vagrant/.ssh/authorized_keys
ADD run.sh /home/vagrant/run.sh
#RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LC_CTYPE ja_JP.UTF-8
RUN chmod 600 /home/vagrant/.ssh/authorized_keys &&\
    chown -R vagrant:vagrant /home/vagrant/.ssh &&\
    chmod u+w ${SUDOFILE} &&\
    echo '%sudo   ALL=(ALL:ALL) NOPASSWD: ALL' >> ${SUDOFILE} &&\
    chmod u-w ${SUDOFILE} &&\
    locale-gen ja_JP.UTF-8 && \
    localedef -f UTF-8 -i ja_JP ja_JP.utf8 &&\
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&\
    chmod +x /home/vagrant/run.sh &&\
    /home/vagrant/run.sh
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
