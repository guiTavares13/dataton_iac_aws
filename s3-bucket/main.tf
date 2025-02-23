provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

variable "bucket_name" {
  type    = string
  default = "dataton_challenge_bucket"
}

variable "folder_names" {
  type    = list(string)
  default = ["raw", "bronze", "silver", "gold", "logs"]
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name

  tags = {
    "Environment" = "Production"
  }
}

resource "aws_s3_bucket_object" "folders" {
  for_each = toset(var.folder_names)

  bucket = aws_s3_bucket.data_bucket.bucket
  key    = "${each.value}/"  

  tags = {
    "Environment" = "Production"
    "DataStage"   = each.value
  }
}

output "bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "folder_names" {
  value = [for folder in aws_s3_bucket_object.folders : folder.key]
}