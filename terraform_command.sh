#!/bin/bash

if [ "$1" == "validate" ]; then
  terraform validate || exit 1
elif [ "$1" == "plan" ]; then
  terraform plan \
  -var="aws_access_key=$AWS_ACCESS_KEY" \
  -var="aws_secret_key=$AWS_SECRET_KEY" \
  -var="aws_token=$AWS_TOKEN" \
  -var="aws_db_username=$AWS_DB_USERNAME" \
  -var="aws_db_password=$AWS_DB_PASSWORD" \
  -var="aws_db_database=$AWS_DB_DATABASE" \
  -var="docker_sock=$DOCKER_SOCK" \
  -var="gitlab_username=$GITLAB_USERNAME" \
  -var="gitlab_access_token=$GITLAB_ACCESS_TOKEN" \
  -var="gitlab_deploy_token_username=$GITLAB_DEPLOY_TOKEN_USERNAME" \
  -var="gitlab_deploy_token_token=$GITLAB_DEPLOY_TOKEN_TOKEN" \
  || exit 1
elif [ "$1" == "apply" ]; then
  terraform apply -auto-approve \
  -var="aws_access_key=$AWS_ACCESS_KEY" \
  -var="aws_secret_key=$AWS_SECRET_KEY" \
  -var="aws_token=$AWS_TOKEN" \
  -var="aws_db_username=$AWS_DB_USERNAME" \
  -var="aws_db_password=$AWS_DB_PASSWORD" \
  -var="aws_db_database=$AWS_DB_DATABASE" \
  -var="docker_sock=$DOCKER_SOCK" \
  -var="gitlab_username=$GITLAB_USERNAME" \
  -var="gitlab_access_token=$GITLAB_ACCESS_TOKEN" \
  -var="gitlab_deploy_token_username=$GITLAB_DEPLOY_TOKEN_USERNAME" \
  -var="gitlab_deploy_token_token=$GITLAB_DEPLOY_TOKEN_TOKEN" \
  || exit 1
elif [ "$1" == "destroy" ]; then
  terraform destroy -auto-approve \
  -var="aws_access_key=$AWS_ACCESS_KEY" \
  -var="aws_secret_key=$AWS_SECRET_KEY" \
  -var="aws_token=$AWS_TOKEN" \
  -var="aws_db_username=$AWS_DB_USERNAME" \
  -var="aws_db_password=$AWS_DB_PASSWORD" \
  -var="aws_db_database=$AWS_DB_DATABASE" \
  -var="docker_sock=$DOCKER_SOCK" \
  -var="gitlab_username=$GITLAB_USERNAME" \
  -var="gitlab_access_token=$GITLAB_ACCESS_TOKEN" \
  -var="gitlab_deploy_token_username=$GITLAB_DEPLOY_TOKEN_USERNAME" \
  -var="gitlab_deploy_token_token=$GITLAB_DEPLOY_TOKEN_TOKEN" \
  -target="aws_ecs_task_definition.team5-task" \
  -target="aws_ecs_cluster.team5-cluster" \
  -target="aws_ecs_service.team5-service" \
  -target="aws_lb.team5-aws-lb" \
  -target="aws_lb_target_group.team5-aws-lb-target-group" \
  -target="aws_lb_listener.team5-aws-lb-listener" \
  || exit 1
else
  echo "Invalid Terraform command"
  exit 1
fi