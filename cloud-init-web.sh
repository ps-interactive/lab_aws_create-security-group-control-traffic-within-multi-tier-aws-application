#!/bin/bash
yum -y install httpd
echo "<html><head><title>Web Server</title></head><h1>Web X</h1><p>This is the web X server.</p></html>" > /var/www/html/index.html
chmod 644 /var/www/index.html
chown apache.apache /var/www/html/index.html
systemctl enable httpd.service
systemctl start httpd.service