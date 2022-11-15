data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#
# Encryption key
#

module key {
  source = "../kms"
  description = "KMS key for the ${var.project_name} CodeBuild project"
  alias = "codebuild/${var.project_name}"
  key_policy = data.aws_iam_policy_document.policy.json
}

#
# Key access policy
#
data "aws_iam_policy_document" "policy" {
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints"
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.${data.aws_region.current.name}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}