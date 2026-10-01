#!/bin/bash

set -e

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>3-Tier AWS Application</title>
</head>
<body>
    <h1>Hello World from $(hostname -f)</h1>
    <h2>3-Tier AWS Infrastructure</h2>
    <p>Application server is running successfully.</p>
    <p>Managed by Terraform + Auto Scaling Group.</p>
</body>
</html>
EOF