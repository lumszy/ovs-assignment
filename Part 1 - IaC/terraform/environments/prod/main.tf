module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security_groups" {
  source = "../../modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  private_subnet_ids    = module.vpc.private_subnet_ids
  db_security_group_id  = module.security_groups.db_security_group_id
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  password              = var.db_password
}

module "secretmanager" {
  source = "../../modules/secretmanager"

  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  app_bucket_name = module.storage.bucket_name
  db_username     = module.database.db_username
  db_password     = var.db_password
  db_host         = module.database.db_endpoint
  db_port         = module.database.db_port
  db_name         = module.database.database_name
}

module "app" {
  source = "../../modules/app"

  project_name                      = var.project_name
  environment                       = var.environment
  vpc_id                            = module.vpc.vpc_id
  public_subnet_ids                 = module.vpc.public_subnet_ids
  private_subnet_ids                = module.vpc.private_subnet_ids
  alb_security_group_id             = module.security_groups.alb_security_group_id
  app_security_group_id             = module.security_groups.app_security_group_id
  ami_id                            = var.app_ami_id
  instance_type                     = var.app_instance_type
  min_size                          = var.app_min_size
  desired_capacity                  = var.app_desired_capacity
  max_size                          = var.app_max_size
  target_cpu_utilization            = var.app_target_cpu_utilization
  target_request_count_per_target   = var.app_target_request_count_per_target
  estimated_instance_warmup_seconds = var.app_instance_warmup_seconds
  upload_bucket_arn                 = module.storage.bucket_arn
  app_secret_arn                    = module.secretmanager.app_secret_arn
}
