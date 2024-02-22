#!/bin/bash

#Install apache 
apt update
apt install -y apache2

#Get Instance ID
INSTANCE_ID = $(curl -s http://169.254.169.254/latest/meta-data/instance-id)

#Create index.html file
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>

<h1>Terraform project Server 1 </h1>
<h2>Instance ID: <span style="color:green">$INSTANCE_ID</span></h2>
<p>This is website running in ec2 instance $INSTANCE_ID </p>

</body>
</html>
EOF

#Start apache2 service and enable it
systemctl start apache2
systemctl enable apache2