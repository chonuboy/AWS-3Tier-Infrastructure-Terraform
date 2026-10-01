module "vpc" {
  source   = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "subnet" {
  source = "../modules/subnet"
  vpc_id = module.vpc.vpc_id
  subnets = {
    public_a = {
      cidr_block              = "10.0.1.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = true
      tier                    = "public"
    }

    public_b = {
      cidr_block              = "10.0.2.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = true
      tier                    = "public"
    }

    private_app_a = {
      cidr_block              = "10.0.3.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = false
      tier                    = "private-app-a"
    }

    private_app_b = {
      cidr_block              = "10.0.4.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = false
      tier                    = "private-app-b"
    }

    private_db_a = {
      cidr_block              = "10.0.5.0/24"
      availability_zone       = "ap-south-1a"
      map_public_ip_on_launch = false
      tier                    = "private-db-a"
    }

    private_db_b = {
      cidr_block              = "10.0.6.0/24"
      availability_zone       = "ap-south-1b"
      map_public_ip_on_launch = false
      tier                    = "private-db-b"
    }
  }
}

module "route_tables" {
  source = "../modules/networking"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = {
    public_a = module.subnet.subnet_ids["public_a"]
    public_b = module.subnet.subnet_ids["public_b"]
  }
  private_subnet_app_ids = {
    private_app_a = module.subnet.subnet_ids["private_app_a"]
    private_app_b = module.subnet.subnet_ids["private_app_b"]
  }
  private_subnet_db_ids = {
    private_db_a = module.subnet.subnet_ids["private_db_a"]
    private_db_b = module.subnet.subnet_ids["private_db_b"]
  }
  nat_subnet_id = module.subnet.subnet_ids["public_a"]
}

module "security_groups" {
  source      = "../modules/security-groups"
  vpc_id      = module.vpc.vpc_id
  alb_sg_name = "alb-sg"
  app_sg_name = "app-sg"
  db_sg_name  = "db-sg"
}

module "iam" {
  source    = "../modules/iam"
  role_name = "my-ec2-role"
}


module "alb" {
  source   = "../modules/alb"
  alb_name = "my-alb"
  vpc_id   = module.vpc.vpc_id
  public_subnet_ids = {
    public_a = module.subnet.subnet_ids["public_a"]
    public_b = module.subnet.subnet_ids["public_b"]
  }
  alb_security_group_id = module.security_groups.alb_security_group_id
}


module "launch_template" {
  source                = "../modules/launch-template"
  lt-name               = "my-launch-template"
  security-group-id     = module.security_groups.app_security_group_id
  instance_type         = "t3.micro"
  user_data             = file("${path.module}/../scripts/app-user-data.sh")
  instance_profile_name = module.iam.instance_profile_name
}


module "asg" {
  source                  = "../modules/asg"
  asg_name                = "my-asg"
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.launch_template_version
  private_subnet_ids = {
    private_app_a = module.subnet.subnet_ids["private_app_a"]
    private_app_b = module.subnet.subnet_ids["private_app_b"]
  }
  target_group_arns = [module.alb.target_group_arn]
  min_size          = 2
  max_size          = 4
  desired_capacity  = 2
}

module "rds" {
  source = "../modules/rds"

  identifier = "three-tier-mysql"

  database_name = "appdb"

  username = var.db_username
  password = var.db_password

  subnet_ids = {
    private_db_a = module.subnet.subnet_ids["private_db_a"]
    private_db_b = module.subnet.subnet_ids["private_db_b"]
  }

  security_group_id = module.security_groups.db_security_group_id
}

