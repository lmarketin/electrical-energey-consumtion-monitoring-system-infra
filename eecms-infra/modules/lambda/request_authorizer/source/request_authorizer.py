import logging

from database_handler import DatabaseHandler, NoCustomerInDBException

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DEFAULT_REGION = "eu-central-1"


def lambda_handler(event, context):
    logger.info(f"Lambda triggered with event: {event}")

    authorizer = RequestAuthorizer()

    headers = event.get("headers", {})
    x_api_key = headers.get("x-api-key")

    path = event.get("path", "")
    health_check = (path == "/actuator/health")
    parts = path.strip("/").split("/")
    billing_metering_point_number = parts[-1] if parts else None

    return authorizer.authorize_request(health_check ,billing_metering_point_number, x_api_key)


class RequestAuthorizer:

    def __init__(self):
        self.database_handler = DatabaseHandler(DEFAULT_REGION)

    def authorize_request(self, health_check, billing_metering_point_number, x_api_key):
        if health_check:
            return self.generate_policy("Authorized", "Allow")#TODO

        try:
            customer_info = (self.database_handler
                             .get_customer_by_billing_metering_point_number(billing_metering_point_number))
        except NoCustomerInDBException as e:
            logger.info(f"API Key:{x_api_key} unverified for customer with Billing Metering Point Number: "
                        f"{billing_metering_point_number}, not found in DB")
            return self.generate_policy("Unauthorized", "Deny")

        db_customer_x_api_key = customer_info.get('x_api_key')

        if db_customer_x_api_key == x_api_key:
            logger.info(f"API Key:{x_api_key} verified for customer with Billing Metering Point Number: "
                        f"{billing_metering_point_number}")
            return self.generate_policy("Authorized", "Allow")

        logger.info(f"API Key:{x_api_key} unverified for customer with Billing Metering Point Number: "
                    f"{billing_metering_point_number} and DB API Key:{db_customer_x_api_key}")
        return self.generate_policy("Unauthorized", "Deny")

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
