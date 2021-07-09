resource "aws_iam_role" "execution" {
  name               = "execution-${local.resource_name}"
  tags               = data.ns_workspace.this.tags
  assume_role_policy = data.aws_iam_policy_document.execution-assume.json
}

data "aws_iam_policy_document" "execution-assume" {
  statement {
    sid     = "AllowECSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "execution-managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// Create policy to pass the execution role to ECS
resource "aws_iam_policy" "execution" {
  name_prefix = "execution-${local.resource_name}"
  policy      = data.aws_iam_policy_document.execution.json
}

data "aws_iam_policy_document" "execution" {
  statement {
    sid       = "AllowPassRoleToECS"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.execution.arn]
  }

  dynamic "statement" {
    for_each = signum(length(local.capabilities.secrets))
    
    content {
      sid = "AllowReadSecrets"
      effect = "Allow"
      resources = [for secret in local.capabilities.secrets : secret.valueFrom]

      actions = [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ]
    }
  }
}
