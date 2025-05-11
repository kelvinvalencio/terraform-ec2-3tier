# terraform-ec2-3tier
Provisions 3-tier web-app in AWS by configuring EC2, EBS, Key Pair, VPC, Subnet, Route Table, Security Groups, and Internet Gateway

# Set Up
1. Create a key-pair under ~/.ssh/ called deployer.pem & deployer.pub
```bash
ssh-keygen
```

2. Create AWS CLI profile
```bash
aws configure --profile testing
```

3. Run
```bash
terraform init
terraform plan
terraform apply
```
