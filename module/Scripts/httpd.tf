#!/bin/bash
yum install httpd -y
echo "<h2>srini ATP Project Successful</h2>"
systemctl start httpd
systemctl enable httpd
