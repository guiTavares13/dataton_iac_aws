provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

variable "databases" {
  type    = list(string)
  default = ["raw", "bronze", "silver", "gold"]
}

variable "tables" {
  type = map(list(object({
    name           = string
    columns        = list(object({ name = string, type = string }))
    partition_keys = list(object({ name = string, type = string }))
    location       = string
  })))
  default = {
    raw = [
      {
        name           = "b_eglobo_users"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/raw/"
      }
    ],
    bronze = [
      {
        name           = "b_itens_webmedia"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/bronze/"
      }
    ],
    silver = [
      {
        name           = "s_eglobo_users"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/silver/"
      },
      {
        name           = "s_itens_filtered_webmedia"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/silver/"
      },
      {
        name           = "s_itens_webmedia"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/silver/"
      }
    ],
    gold = [
      {
        name           = "g_general_recommended"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/gold/"
      },
      {
        name           = "g_news_processes"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/gold/"
      },
      {
        name           = "g_recommendation"
        columns        = [{ name = "column1", type = "string" }, { name = "column2", type = "int" }]
        partition_keys = [{ name = "partition_column", type = "string" }]
        location       = "s3://dataton_challenge_bucket/gold/"
      }
    ]
  }
}

resource "aws_glue_catalog_database" "databases" {
  for_each = toset(var.databases)

  name = "dataton-challenge-bucket-${each.value}"
}

resource "aws_glue_catalog_table" "table" {
  for_each = { for db, tbls in var.tables : "${db}-${join("-", [for tbl in tbls : tbl.name])}" => {
    database_name = aws_glue_catalog_database.databases[db].name
    tables        = tbls
  }}

  name          = split("-", each.key)[1]
  database_name = each.value.database_name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = each.value.tables[0].location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    compressed    = false

    dynamic "columns" {
      for_each = each.value.tables[0].columns
      content {
        name = columns.value.name
        type = columns.value.type
      }
    }
  }

  dynamic "partition_keys" {
    for_each = each.value.tables[0].partition_keys
    content {
      name = partition_keys.value.name
      type = partition_keys.value.type
    }
  }
}


output "database_names" {
  value = [for db in aws_glue_catalog_database.databases : db.name]
}

output "table_names" {
  value = { for db, tbls in var.tables : db => [for table in tbls : table.name] }
}