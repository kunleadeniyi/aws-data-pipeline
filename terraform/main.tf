terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "mytfbackend-3695"
    region = "eu-west-2"
    key = "key/terraform.tfstate"
  }
}
# resource "aws_s3_bucket" "S3-storage-bucket" {
#   bucket = "my-tf-test-bucket-20240212"
# }


# resource "aws_kinesis_stream" "kinesis_data_stream" {
#   name             = "my-data-stream"
#   shard_count      = 1  # You can adjust shard count based on expected throughput
# }




# resource "aws_glue_crawler" "data_crawler" {
#   name = "my-data-crawler"
#   role = "arn:aws:iam::123456789012:role/glue_role"
#   database_name = "my_database"
#   targets = {
#     s3_targets {
#       path = "s3://my-bucket/raw-data/"
#     }
#   }
# }


# resource "aws_glue_job" "data_job" {
#   name          = "my-data-job"
#   role_arn      = "arn:aws:iam::123456789012:role/glue_role"
#   command {
#     name        = "glueetl"
#     script_location = "s3://path/to/your/script.py"
#   }
#   default_arguments = {
#     "--job-language" = "python"
#     "--enable-metrics" = ""
#   }
# }

# resource "aws_redshift_cluster" "redshift_cluster" {
#   cluster_identifier         = "my-redshift-cluster"
#   node_type                  = "dc2.large"
#   cluster_type               = "single-node"
#   master_username            = "admin"
#   master_password            = "your_password"
#   iam_roles                  = ["arn:aws:iam::123456789012:role/redshift_role"]
# }


# # api 
# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_execution_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_policy_attachment" "lambda_execution" {
#   name       = "lambda_execution"
#   roles      = [aws_iam_role.lambda_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   output_path = "${path.module}/lambda_function.zip"
#   source_dir  = "${path.module}/lambda_function"
# }

# resource "aws_lambda_function" "publish_to_kinesis" {
#   filename      = data.archive_file.lambda_zip.output_path
#   function_name = "publish_to_kinesis_lambda"
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "lambda_function.lambda_handler"
#   runtime       = "python3.8"
# }

# locals {
#   lambda_permission_statement = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       },
#       "Action": "lambda:InvokeFunction",
#       "Resource": "${aws_lambda_function.publish_to_kinesis.arn}",
#       "Condition": {
#         "ArnLike": {
#           "AWS:SourceArn": "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
#         }
#       }
#     }
#   ]
# }
# EOF
# }

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.publish_to_kinesis.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = aws_api_gateway_rest_api.api.execution_arn
# }


# resource "aws_api_gateway_rest_api" "api" {
#   name        = "my_api_gateway"
# }

# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "publish"
# }

# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.resource.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.method.http_method
#   integration_http_method = "POST"
#   type        = "AWS_PROXY"
#   uri         = aws_lambda_function.publish_to_kinesis.invoke_arn
# }

# resource "aws_api_gateway_method_response" "response" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.method.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }
# }

# resource "aws_api_gateway_integration_response" "integration_response" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.resource.id
#   http_method = aws_api_gateway_method.method.http_method
#   status_code = aws_api_gateway_method_response.response.status_code

#   response_templates = {
#     "application/json" = ""
#   }
# }


# workflow
# Api to kinesis stream to kinesis firehose to s3 to glue crawler to glue job to redshift
resource "aws_kinesis_stream" "kinesis_data_stream" {
  name             = "my-data-stream"
  # only set shard_count when in PROVISIONED stream mode
  # shard_count      = 1  # You can adjust shard count based on expected throughput 
  retention_period = 24

  # there is a charge for enhanced shard-level metrics
  # https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
  shard_level_metrics = [ 
    "IncomingBytes",
    "IncomingRecords",
    "OutgoingBytes",
    "OutgoingRecords"
  ]

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "test"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "data_firehose" {
  name = "firehose_delivery"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_data_stream.arn
    role_arn = aws_iam_role.firehose_role.arn
  }
  
  extended_s3_configuration {
    # role_arn = 
    # bucket_arn = 
    role_arn       = aws_iam_role.firehose_role.arn
    bucket_arn     = aws_s3_bucket.data-s3-storage-bucket.arn
    buffering_interval = 60
    buffering_size = 64
    dynamic_partitioning_configuration {
      enabled = true
    }

    # Example prefix using partitionKeyFromQuery, applicable to JQ processor
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{partitionKeyFromQuery:table_name}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"

  processing_configuration {
      enabled = "true"
      # JQ processor example
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{table_name:.table_name}"
        }
      }
    }
  }
  tags = {
    Environment = "test"
  }
}

resource "aws_s3_bucket" "data-s3-storage-bucket" {
  bucket = "data-bucket-20240212"
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com", "kinesis.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# resource "aws_iam_role" "firehose_kinesis_role" {
#   name               = "firehose_kinesis_role"
#   assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
# }

# data "aws_iam_policy_document" "kinesis_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["firehose.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }