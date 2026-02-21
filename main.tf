module "Networking" {
  source                    = "./module/vpc-attacker"
  name                      = "VPC-Attacker"
  availability_zones        = ["${local.region}a"]
  vpc_cidr_block            = "172.32.0.0/16"
  public_subnets_cidr_block = ["172.32.1.0/24"]
}

module "Networking-default" {
  source                             = "./module/vpc-default"
  name                               = "VPC-Default"
  availability_zones                 = ["${local.region}a", "${local.region}b"]
  vpc_default_id                     = local.vpc_default_id
  internet_gateway_default           = local.igw_id
  public_subnet_defaults_cidr_block  = ["172.31.48.0/24", "172.31.49.0/24"]
  private_subnet_defaults_cidr_block = ["172.31.50.0/24", "172.31.51.0/24"]
}

module "Skenario-1" {
  count         = 0
  source        = "./module/skenario-1"
  ami_id        = local.ami_ubuntu
  volume_size   = "8"
  volume_type   = "gp3"
  instance_type = "t3.micro"
  project_name  = "server-public"
  vpc_id        = local.vpc_default_id
  iam_instance_profile = module.Skenario-2.instance_profile
  subnet_id     = flatten(module.Networking-default.public_subnets_id)[0]
}

module "Skenario-2" {
  source                 = "./module/skenario-2"
  aws_ami                = local.ami_ubuntu
  volume_size            = "8"
  volume_type            = "gp3"
  instance_type          = "t3.micro"
  project_name           = "server-private"
  vpc_id                 = local.vpc_default_id
  vpc_public_subnets_id  = module.Networking-default.public_subnets_id
  vpc_private_subnets_id = module.Networking-default.private_subnets_id
  desired_capacity       = 0
  min_capacity           = 0
  max_capacity           = 1
  on_demand_percentage   = 0
  capacity_rebalance     = false
}

module "ec2-attacker" {
  source                 = "./module/ec2-attacker"
  aws_ami                = local.ami_kali
  volume_size            = "25"
  volume_type            = "gp3"
  instance_type          = "t3.medium"
  project_name           = "attacker-instance"
  vpc_id                 = module.Networking.vpc_id
  vpc_public_subnets_id  = module.Networking.public_subnets_id
  vpc_private_subnets_id = module.Networking.public_subnets_id
  desired_capacity       = 0
  min_capacity           = 0
  max_capacity           = 0
  on_demand_percentage   = 0
  capacity_rebalance     = true
}