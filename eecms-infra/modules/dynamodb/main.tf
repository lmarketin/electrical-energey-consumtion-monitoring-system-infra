resource "aws_dynamodb_table" "customers" {
  name           = "customers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "billing_metering_point_number"

  attribute {
    name = "billing_metering_point_number"
    type = "N"
  }


  global_secondary_index {
    name           = "customers"
    hash_key       = "billing_metering_point_number"
    write_capacity = 10
    read_capacity  = 10
    projection_type = "KEYS_ONLY"
    non_key_attributes = []
  }
}

/*
{
"billing_metering_point_number": {
"N": ""
},
"x_api_key": {
"S": ""
},
"type": {
"S": ""
},
"active": {
"BOOL": ""
},
"name": {
"S": ""
},
"address": {
"S": ""
},
"city": {
"S": ""
},
"county": {
"S": ""
},
"email": {
"S": ""
}
}
*/
