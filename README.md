![Screenshot 2025-02-14 at 03 30 08](https://github.com/user-attachments/assets/f85746fa-520a-4cd7-9709-4ec4792431b2)


**Electrical Energy Consumption Monitoring System Infrastructure**

This project contains AWS setup for Electrical Energy Consumption Monitoring System.
Infrastructure setup is defined with Terraform (IaaS).
For Lambda Functions programming Python is used.
The system is used to receive data on electrical energy consumption from customers, prepare data for analysis and raise alarms in the event of incorrect customer consumption reporting.
Storing of data is done by Java Spring Boot Application running by Fargate: https://github.com/lmarketin/ElectricalEnergyConsuptionMonitoringService

System Architecture characteristics:
  - Microservice architecture
  - Distributed system
  - Event driven
  - Scalable system

The system consists of:
  - Api Gateway - Entry point for customers data.
  - Request Authorizer Lambda - By DynamoDB authorizing x-api-key from client request.
  - Load Balncer - Esed for balancing traffic between two Fargate instnces.
  - ECS - With two Fargate instances.
  - ECR - For Docker image storing.
  - RDS - Postgres. Used for storing customer consumption data.
  - DynamoDB - Used for storing general data about customers.
  - Event Bridge - Used to trigger Step Function.
  - Step Function - Used to orchestrating Lambda Functions exections:
                          1) Data Exporter
                          2) Data Enricher
                          3) Alerting
  - S3 Buckets:
            1) Expored Data - Contains data exported on daily base from Postgre DB.
            2) Enriched Data - Contains exported data enriched with data from DynamoDB, which makes data prepared for detailed analysis.
  - SNS - Used to send email to admin.
  - SQS - Can be used as entry point for customers alerting.
  - Cloudwatch - Contains log of Fargate instances, Api Gateway and Lambda Functions.
  - IAM - Roles/Policies/Permissions.
  - VPC - Consists of two private and two public networks.
