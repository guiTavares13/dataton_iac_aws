provider "aws" {
  region     = "us-east-1"
  profile = "default"
}

variable "dynamodb_table_names" {
  type    = list(string)
  default = ["users", "admins"]
}

resource "aws_dynamodb_table" "data_tables" {
  for_each = toset(var.dynamodb_table_names)

  name           = "dataton-${each.value}" 
  hash_key       = "id"  
  read_capacity  = 5     
  write_capacity = 5     
  billing_mode   = "PROVISIONED" 

  attribute {
    name = "id"
    type = "S" 
  }

  attribute {
    name = "username"
    type = "S"  
  }

  global_secondary_index {
    name               = "username-index"
    hash_key           = "username"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

  tags = {
    "Environment" = "Local"
    "TableName"   = each.value
  }
}

output "dynamodb_table_names" {
  value = [for table in aws_dynamodb_table.data_tables : table.name]
}
