CUSTOMER_NAME="somecustomer"
VPC_CIDR="10.101.24.0/24"
subnet_bits=1
region = "us-west-1"
aws_profile = "testing"
authenticated_networks = ["1.1.1.1", "2.2.2.2"]
instances = {
    app = {
      create = true
      instance_name = "App"
      ami           = "ami-06fe18c7144382cfb"
      instance_type = "t2.micro"
      private_ip    = "10.101.24.36"
      security_group = "sg_app"
      volume_size = 50
    }
    engine = {
      create = true
      instance_name = "Engine"
      ami           = "ami-06fe18c7144382cfb"
      instance_type = "t2.micro"
      private_ip    = "10.101.24.37"
      security_group = "sg_engine"
      volume_size = 50
    }
    db = {
      create = true
      instance_name = "DB"
      ami           = "ami-06fe18c7144382cfb"
      instance_type = "t2.micro"
      private_ip    = "10.101.24.38"
      security_group = "sg_db"
      volume_size = 100
    }
}
