provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "sa-east-1"

  endpoints {
    s3 = "http://127.0.0.1:4566"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

variable "bucket_names" {
  type    = list(string)
  default = ["raw", "bronze", "silver", "gold", "logs"]
}

resource "aws_s3_bucket" "data_buckets" {
  for_each = toset(var.bucket_names)

  bucket = "eglobo-webmedia-${each.value}"  

  tags = {
    "Environment" = "Local"
    "DataStage"   = each.value
  }
}



output "bucket_names" {
  value = [for bucket in aws_s3_bucket.data_buckets : bucket.bucket]
}
