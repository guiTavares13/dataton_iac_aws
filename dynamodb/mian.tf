provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "sa-east-1"

  # Endpoints do LocalStack para DynamoDB
  endpoints {
    dynamodb = "http://127.0.0.1:4566"
  }

  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

# Variável para os nomes das tabelas DynamoDB
variable "dynamodb_table_names" {
  type    = list(string)
  default = ["users", "admins"]
}

# Recurso para criar as tabelas DynamoDB
resource "aws_dynamodb_table" "data_tables" {
  for_each = toset(var.dynamodb_table_names)

  name           = "dataton-${each.value}" 
  hash_key       = "id"  # Chave primária da tabela
  read_capacity  = 5     # Capacidade de leitura provisionada
  write_capacity = 5     # Capacidade de gravação provisionada
  billing_mode   = "PROVISIONED"  # Pode ser "PAY_PER_REQUEST" se não precisar provisionar a capacidade

  # Definição dos atributos da chave primária
  attribute {
    name = "id"
    type = "S"  # Tipo da chave primária: String
  }

  # Definindo outras colunas necessárias para a tabela
  # Se quiser pode adicionar colunas extras para os dados dos usuários
  # Exemplo: username e password
  attribute {
    name = "username"
    type = "S"  # Tipo: String
  }

  # Índice global para pesquisa de username
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

# Saída para os nomes das tabelas DynamoDB
output "dynamodb_table_names" {
  value = [for table in aws_dynamodb_table.data_tables : table.name]
}
