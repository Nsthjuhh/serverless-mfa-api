
/*
 * Create IAM user for Serverless framework to use to deploy the lambda function
 */
module "serverless-user" {
  count   = var.app_environment == "staging" ? 1 : 0
  source  = "silinternational/serverless-user/aws"
  version = "0.1.3"

  app_name           = "mfa-api"
  aws_region         = var.aws_region
  enable_api_gateway = true

  extra_policies = [
    jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb:DescribeGlobalTableSettings",
              "dynamodb:DescribeGlobalTable"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:global-table/mfa-api_*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb:BatchWriteItem",
              "dynamodb:CreateTable",
              "dynamodb:CreateTableReplica",
              "dynamodb:DeleteItem",
              "dynamodb:DescribeContinuousBackups",
              "dynamodb:DescribeContributorInsights",
              "dynamodb:DescribeKinesisStreamingDestination",
              "dynamodb:DescribeTable",
              "dynamodb:DescribeTimeToLive",
              "dynamodb:GetItem",
              "dynamodb:ListTagsOfResource",
              "dynamodb:PutItem",
              "dynamodb:Query",
              "dynamodb:Scan",
              "dynamodb:TagResource",
              "dynamodb:UntagResource",
              "dynamodb:UpdateItem",
              "dynamodb:UpdateTable"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:table/mfa-api_*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb:Scan",
              "dynamodb:Query"
            ],
            "Resource" : "arn:aws:dynamodb:*:*:table/mfa-api_*/index/*"
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "iam:CreateServiceLinkedRole",
              "iam:TagRole",
              "iam:UntagRole"
            ],
            "Resource" : "arn:aws:iam::*:role/*"
          }
        ]
      }
    )
  ]
}


/*
 * Manage DynamoDB tables used by the functions.
 */

resource "aws_dynamodb_table" "api_keys" {
  name             = "mfa-api_${var.app_env}_api-key_global"
  hash_key         = "value"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "value"
    type = "S"
  }

  replica {
    region_name = var.aws_region_secondary
  }

  lifecycle {
    ignore_changes = [replica]
  }
}

resource "aws_dynamodb_table" "totp" {
  name             = "mfa-api_${var.app_env}_totp_global"
  hash_key         = "uuid"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "uuid"
    type = "S"
  }

  replica {
    region_name = var.aws_region_secondary
  }

  lifecycle {
    ignore_changes = [replica]
  }
}

resource "aws_dynamodb_table" "u2f" {
  name             = "mfa-api_${var.app_env}_u2f_global"
  hash_key         = "uuid"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "uuid"
    type = "S"
  }

  replica {
    region_name = var.aws_region_secondary
  }

  lifecycle {
    ignore_changes = [replica]
  }
}
