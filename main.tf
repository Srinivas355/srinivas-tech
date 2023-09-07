module "srini_vpc" {
  source       = "./module/networking"
  subnet_count = 3
  pub_cidrs    = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  pri_cidrs    = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  ami          = "ami-06f621d90fa29f6d0"
  vpc_tags = {
    Name     = "srini-vpc"
    Location = "Banglore"
  }
}

# Create RDS
module "srini_rds" {
  source  = "./module/rds"
  sub_ids = module.srini_vpc.pri_sub_ids
  vpc_id  = module.srini_vpc.vpc_id
  rds_ingress_rules = {
    "app1" = {
      port            = 3306
      protocol        = "tcp"
      cidr_blocks     = []
      description     = "allow ssh within organization"
      security_groups = [module.webapp.security_group_id]
    }
  }
}

# Launch Instance into public subnet
module "webapp" {
  source     = "./module/ec2"
  ec2_count  = 2
  ami        = "ami-06f621d90fa29f6d0"
  key_name   = "vasu"
  subnet_ids = module.srini_vpc.pub_sub_ids
  vpc_id     = module.srini_vpc.vpc_id
  web_ingress_rules = {
    "22" = {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow ssh within organization"
    },
    "80" = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow 80 everywhere"
    }
  }
}
module "myappalb" {
  source     = "./module/alb"
  vpc_id     = module.srini_vpc.vpc_id
  subnet_ids = module.srini_vpc.pub_sub_ids
  alb_ingress_rules = {
    "80" = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow 80 everywhere"
    }
  }
  instance_ids = module.webapp.instance_ids
}
