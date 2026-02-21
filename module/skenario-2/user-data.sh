#!/bin/bash
apt update -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx

cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AWS VPC Security Lab - Sabrina</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body { background-color: #f8f9fa; color: #333; }
    .hero-bg { background-color: #343a40; color: white; padding: 50px 0; border-bottom: 4px solid #0d6efd; }
    .card-tujuan { border-left: 5px solid #0d6efd; background-color: #fff; transition: 0.3s; }
    .card-tujuan:hover { box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important; }
    .footer { background-color: #212529; color: white; padding: 25px 0; margin-top: 50px; }
    .point-list { text-align: left; list-style-position: inside; padding-left: 0; }
    .point-list li { margin-bottom: 8px; }
  </style>
</head>
<body>
  <div class="hero-bg text-center">
    <div class="container">
      <h2 class="fw-bold mb-2">Endpoint Testing Environment!</h2>
      <p class="lead opacity-75">Analisa Perancangan dan Implementasi Keamanan Jaringan dengan Virtual Private Cloud (VPC) pada Infrastruktur Cloud AWS</p>
    </div>
  </div>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <div class="col-md-9">
        <div class="card card-tujuan p-4 shadow-sm mb-4">
          <h4 class="text-primary mb-3">Tujuan Website</h4>
          <p>
            Website ini berfungsi sebagai <b>Endpoint Testing</b> untuk memvalidasi arsitektur jaringan yang telah dirancang. Digunakan sebagai objek pengujian aksesibilitas dan ketahanan infrastruktur terhadap simulasi gangguan keamanan.
          </p>
          <p class="fw-bold mb-2">Penelitian ini bertujuan untuk:</p>
          <ul class="point-list">
            <li>Merancang dan mengimplementasikan arsitektur VPC yang aman pada platform AWS.</li>
            <li>Menganalisis efektivitas VPC & membandingkan performa <i>Public Subnet</i> dan <i>Private Subnet</i>.</li>
            <li>Menganalisa parameter konfigurasi dan faktor yang memengaruhi performa serta ketahanan keamanan jaringan VPC.</li>
          </ul>
          <p class="fw-bold mb-2">Peneliti: Sabrina Zulfa Wahidah</p>
          <p class="fw-bold mb-2">NIM: 220401070413</p>
        </div>
      </div>
    </div>
  </div>
  <footer class="footer text-center">
    <div class="container">
      <small>© 2026 | PJJ Informatika - Universitas Siber Asia | Tugas Akhir - Network Specialist</small>
    </div>
  </footer>
</body>
</html>
EOF

## UPDATE NGINX CONFIG
cd /etc/nginx && sudo tee nginx.conf<<EOF
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;
events{}

http {
  include /etc/nginx/conf.d/*.conf;
  client_max_body_size 128M;
  sendfile on;
  send_timeout 600s;
  keepalive_timeout 300;
  server {
      listen 80;
      server_name _;

      location /health {
          access_log off;
          return 200 "OK\n";
          add_header Content-Type text/plain;
      }

      location / {
          root /var/www/html;
          index index.html;
      }
  }
}
EOF
sudo nginx -t
sudo systemctl restart nginx
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Setup memory metrics

wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb
apt-get update -y && apt-get install collectd -y

cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
        "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "cwagent"
        },
        "metrics": {
                "metrics_collected": {
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        }
                }
        }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json