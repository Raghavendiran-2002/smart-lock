sudo apt-get update
sudo apt-get -y upgrade
sudo apt install wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release
curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
sudo dpkg -i ./libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable --now mongod
# sudo nano /etc/mongod.conf  # 127.0.0.1 => 0.0.0.0
sudo systemctl restart mongod
sudo systemctl stop mongod.service
rm -r libssl1.1_1.1.1f-1ubuntu2.16_amd64.deb
sudo ufw allow 27017
sudo systemctl stop mongod.service
sudo mkdir -p /newdata/mongo
sudo chown -R mongodb:mongodb  /newdata/mongo
sudo rsync -av /var/lib/mongodb  /newdata/mongo
sudo mv /var/lib/mongodb /var/lib/mongodb.bak
sudo ln -s /newdata/mongo /var/lib/mongodb
sudo systemctl daemon-reload
sudo systemctl start mongod

sudo add-apt-repository ppa:mosquitto-dev/mosquitto-ppa -y
sudo apt install -y mosquitto mosquitto-clients
sudo ufw allow 1883
sudo apt install -y net-tools
sudo nano /etc/mosquitto/mosquitto.conf # listener 1883
                                        # allow_anonymous true
sudo service mosquitto restart

