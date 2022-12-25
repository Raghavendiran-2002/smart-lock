#Download base image ubuntu 20.04
FROM ubuntu:20.04
# Update Ubuntu Software repository
RUN apt update
RUN apt -y upgrade
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
RUN apt-get install gnupg
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
RUN apt-get update
RUN apt-get install -y mongodb-org
RUN systemctl start mongod


# RUN apt install wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release
# RUN curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg
# RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
# RUN wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
# RUN dpkg -i ./libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
# RUN apt update
# RUN apt install -y mongodb-org
# RUN systemctl enable --now mongod
# RUN ufw allow 1883
RUN mkdir raghav
RUN add-apt-repository ppa:mosquitto-dev/mosquitto-ppa -y
RUN apt install -y mosquitto mosquitto-clients
RUN ufw allow 1883
RUN apt install -y net-tools
RUN nano /etc/mosquitto/mosquitto.conf
