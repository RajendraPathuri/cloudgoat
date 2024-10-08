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
