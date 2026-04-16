FROM ubuntu:24.04
RUN apt-get update && apt-get install -y ssh python3 sudo
RUN id ubuntu || useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
RUN echo 'ubuntu:ubuntu' | chpasswd
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN service ssh start
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
