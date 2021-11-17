# Introduction 
Rolling Dice Simulator Project.
One AWS Lambda for Rolling Dice Processor that also saves the data in AWS S3. Another AWS Lambda for Retrieving the Data saved in AWS S3. This lambda will process Percetage and  request counter.
Both two lambdas is Integrated in AWS API Gateway as the way of invoking and retrieving the data.
Terraform was use as Infrastructure as Code to orchestrate the AWS Service involve nad building the whole process.


# DeploymenT and Project Dependencies
1. AWS CLI
2. Boto3
3. Terraform
4. Pycharm-CE (optional as for IDE)

# Publishing the REST API's
a. How would you publish the API?
=> As integrated in this Project, AWS API Gateway is one of the best way I publish the API's. AWS API Gateway serves as the bridge to connect in the lambda function invoking the processes.

b. How would you pen-test/secure the API?
=> Single Sign On (SSO) or AWS SAML can be use to secure the API's.

c. How would you test the quality of the API?
=> Using Postman or SwaggerHub as the Test Tool for API is a great help. It can be automated or manually running the calls

d. How would you monitor the Lambda functions?
=> AWS Lambda Functions can be monitor in difference AWS Services like ClaoudWatch, AWS X-ray. It can give you Service Map and Traces to check all the processes of the Lambda Function.