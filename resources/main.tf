module "sample" {
  source      = "../modules/s3_bucket"
  name_prefix = "dummy-"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      module.sample.arn
    ]
  }
}

module "lambda" {
  source = "../modules/lambda"
  function_name = "test"
  handler_name  = "app.handler"
  description   = "Test function"
  resource_policy = data.aws_iam_policy_document.json
} 