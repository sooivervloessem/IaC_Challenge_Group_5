# Generate the secrets manager for our team
resource "aws_secretsmanager_secret" "team5-secretsmanager-gitlab-credentials" {
  name = "team5-secretsmanager-gitlab-credentials"

  lifecycle {
    prevent_destroy = true
  }
}

# Put the gitlab credentials in the secrets manager
resource "aws_secretsmanager_secret_version" "team5-secretsmanager-gitlab-credentials" {
  secret_id     = aws_secretsmanager_secret.team5-secretsmanager-gitlab-credentials.id
  secret_string = jsonencode(
    {
      "username": var.gitlab_deploy_token_username,
      "password": var.gitlab_deploy_token_token
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Allow the ECS task to read the secrets manager
data "aws_iam_policy_document" "team5-data-policy-document" {
  statement {
    sid    = "EnableAnotherAWSAccountToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.team5-current.account_id}:role/LabRole"]
    }

    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = ["*"]
  }

  depends_on = [ data.aws_caller_identity.team5-current ]
}

# Allow the secrets manager to be read by the ECS task
resource "aws_secretsmanager_secret_policy" "team5-secret-policy" {
  secret_arn = aws_secretsmanager_secret.team5-secretsmanager-gitlab-credentials.arn
  policy     = data.aws_iam_policy_document.team5-data-policy-document.json

  depends_on = [ data.aws_iam_policy_document.team5-data-policy-document, aws_secretsmanager_secret.team5-secretsmanager-gitlab-credentials ]
}
