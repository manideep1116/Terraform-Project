#!bin/bash

yum install httpd -y
echo "<h1>deployed by terraform <h1>" >/var/www/html/index.html
chkconfig httpd on
service httpd start
