provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
  ecr_repo_url = module.ecr.ecr_repo_url
  region = "eu-central-1"
  vpc_id = module.vpc.vpc_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  alb_sg_id = module.alb.alb_sg_id
  lb_target_group_arn = module.alb.lb_target_group_arn
  lb_listener = module.alb.lb_listener.arn
}

module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  ecs_sg_id = module.ecs.ecs_sg_id
  exporter_lambda_sg_id = module.exporter_lambda.postgres_db_exporter_lambda_sg_id
}

module "api_gateway" {
  source = "./modules/api_gateway"
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  lb_listener_arn        = module.alb.lb_listener_arn
  request_authorizer_lambda_arn = module.request_authorizer_lambda.request_authorizer_lambda_arn
}

module "request_authorizer_lambda" {
  source   = "./modules/lambda/request_authorizer"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
}

module "dynamodb" {
  source   = "./modules/dynamodb"
}

module "s3" {
  source   = "./modules/s3"
}

module "exporter_lambda" {
  source   = "./modules/lambda/postgres_db_exporter"
  vpc_id = module.vpc.vpc_id
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
}

module "enricher_lambda" {
  source   = "./modules/lambda/consumption_data_enricher"
}

module "alerting_lambda" {
  source   = "./modules/lambda/not_received_consumption_data_alert"
  sns_topic_email_arn = module.sns.sqs_topic_email_arn
  sqs_alerting_queue_arn = module.sqs.sqs_alerting_queue_arn
}

module "sns" {
  source   = "./modules/sns"
}

module "sqs" {
  source   = "./modules/sqs"
}

module "step_function" {
  source     = "./modules/step_function"
  exporter_lambda_arn = module.exporter_lambda.postgres_db_exporter_lambda_arn
  enricher_lambda_arn = module.enricher_lambda.consumption_data_enricher_lambda_arn
  alerting_lambda_arn = module.alerting_lambda.not_received_consumption_data_alert_lambda_arn
}

module "cloudwatch" {
  source   = "./modules/cloudwatch"
  consumption_data_pipeline_arn = module.step_function.consumption_data_pipeline_arn
}