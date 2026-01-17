# =============================================================================
# MAIN - Integração de todos os módulos
# =============================================================================

# Módulo Networking
module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Módulo Security Groups
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id

  depends_on = [module.networking]
}

# Módulo IAM
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# Módulo Database
module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  db_security_group_id = module.security_groups.db_sg_id
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password

  depends_on = [module.networking, module.security_groups]
}

# Módulo EFS
module "efs" {
  source = "./modules/efs"

  project_name          = var.project_name
  environment           = var.environment
  private_subnet_ids    = module.networking.private_subnet_ids
  efs_security_group_id = module.security_groups.efs_sg_id

  depends_on = [module.networking, module.security_groups]
}

# Módulo Compute (Launch Template)
module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  app_security_group_id = module.security_groups.app_sg_id
  instance_profile_name = module.iam.instance_profile_name
  efs_dns_name          = module.efs.efs_dns_name
  db_endpoint           = module.database.db_address
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password

  depends_on = [module.efs, module.database, module.iam]
}

# Módulo Load Balancing (ALB + ASG)
module "load_balancing" {
  source = "./modules/load-balancing"

  project_name            = var.project_name
  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  public_subnet_ids       = module.networking.public_subnet_ids
  private_subnet_ids      = module.networking.private_subnet_ids
  alb_security_group_id   = module.security_groups.alb_sg_id
  launch_template_id      = module.compute.launch_template_id
  launch_template_version = module.compute.launch_template_latest_version

  depends_on = [module.compute]
}
