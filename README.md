# sandboxmaker
aws sandbox environment maker

Terraform scripts to create a sandbox environment in AWS
![Architecture Diagram](https://s3.amazonaws.com/fortunecookiezen/github/images/Sandbox+Design.png)

Scripts create the following:
1. Public /28 subnet to contain an elastic ip, an Internet Gateway, and a NAT Gateway
2. Private /24 subnet A with S3 and SSM endpoints and a default route pointing at the NAT Gateway
3. Private /24 subnet B with S3 and SSM endpoints and no Internet Access
4. A t2.micro EC2 Linux instance in subnet A with an EC2 role and an SSM policy attached to it
5. A managed default security group
5. A private S3 bucket
