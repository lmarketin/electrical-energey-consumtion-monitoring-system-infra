resource "aws_dynamodb_table" "customers" {
  name           = "customers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "x_api_key"

  attribute {
    name = "x_api_key"
    type = "S"
  }


/*  attribute {
    name = "billing_metering_point_number"
    type = "N"
  }
  attribute {
    name = "active"
    type = "S"
  }
  attribute {
    name = "name"
    type = "S"
  }
  attribute {
    name = "county"
    type = "S"
  }
  attribute {
    name = "address"
    type = "S"
  }
  attribute {
    name = "type"
    type = "S"
  }
  attribute {
    name = "email"
    type = "S"
  }
*/

  global_secondary_index {
    name           = "customers"
    hash_key       = "x_api_key"
    write_capacity = 10
    read_capacity  = 10
    projection_type = "KEYS_ONLY"
    non_key_attributes = []
  }
}
