import json
import logging

from database_handler import DatabaseHandler, NoCustomerInDBException

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DEFAULT_REGION = "eu-central-1"


def lambda_handler(event, context):
    logger.info(f"Received event: {event}")

    headers = event.get("headers", {})
    x_api_key = headers.get("x-api-key")

    authorizer = RequestAuthorizer()
    return authorizer.authorize_request(x_api_key)


class RequestAuthorizer:

    def __init__(self):
        self.database_handler = DatabaseHandler(DEFAULT_REGION)

    def authorize_request(self, x_api_key):
        try:
            customer_info = (self.database_handler
                             .get_customer_by_x_api_key(x_api_key))
        except NoCustomerInDBException as e:
            logger.error(f"Error while authorizing request: {e}")
            return self.generate_policy("Unauthorized", "Deny")

        logger.info(f"API Key:{x_api_key} verified.")
        return self.generate_policy("Authorized", "Allow")

        #db_customer_x_api_key = customer_info.get('x_api_key')

        #if db_customer_x_api_key == x_api_key:
            #logger.info(f"API Key:{x_api_key} verified for customer with Billing Metering Point Number:"
             #           f"{billing_metering_pint_number}")

    def generate_policy(self, principal_id, effect):
        return {
            "principalId": principal_id,
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [{
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": "*"
                }]
            }
        }
