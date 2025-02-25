#!/bin/bash

# עדכון מערכת והתקנת כלים בסיסיים
sudo apt-get update
sudo apt-get install -y ca-certificates curl git
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# הוספת מאגר Docker והתקנתו
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# התקנת Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# חיבור ווליום EBS והכנת תיקיות
sudo mkfs.ext4 /dev/nvme1n1
sudo mkdir -p /mnt/ebs
sudo mount /dev/nvme1n1 /mnt/ebs
sudo chown -R ubuntu:ubuntu /mnt/ebs
sudo chmod -R 777 /mnt/ebs
sudo mkdir -p /mnt/ebs/catalog-data /mnt/ebs/prometheus-data /mnt/ebs/grafana-data /mnt/docker


# יצירת קובץ Prometheus configuration
cat << EOF > /home/ubuntu/prometheus.yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'availability-agent'
    static_configs:
      - targets: ['availability-agent:8081']
EOF

# יצירת קובץ Nginx configuration
cat << EOF > /home/ubuntu/nginx.conf
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;  # תואם למיפוי "8080:80" ב-docker-compose
        location / {
            proxy_pass http://netflix-frontend:3000;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

# שיבוט מאגר Git והעתקת קבצים למיקום הנכון
sudo git clone https://github.com/lidorbashari/NetflixInfra.git
cd NetflixInfra
sudo cp /home/ubuntu/prometheus.yaml /mnt/docker/prometheus.yaml
sudo cp /home/ubuntu/nginx.conf /mnt/docker/nginx.conf
sudo cp /home/ubuntu/NetflixInfra/provisioning/datasources/prometheus-data.yaml /mnt/docker/grafana/provisioning/datasources/prometheus-data.yaml


# הורדת קובץ Docker Compose והפעלתו
sudo curl -L "https://raw.githubusercontent.com/lidorbashari/NetflixInfra/main/docker-compose.yaml" -o /mnt/docker/docker-compose.yaml
cd /mnt/docker
sudo docker-compose up -d