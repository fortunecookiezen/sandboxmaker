#iam role for ec2 instances
resource "aws_iam_role" "ec2_role" {
  name       = "SandboxEC2Role"
  assume_role_policy = "${file("assume-role-policy.json")}"
}

resource "aws_iam_policy_attachment" "sb" {
  name       = "SandboxPolicy"
  roles      = ["${aws_iam_role.ec2_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name      = "SandboxEC2Profile"
  role      = "${aws_iam_role.ec2_role.name}"
}
# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name    = "vpctestkeypair"
  public_key  = "${file("${var.key_path}")}"
}

# Define instance inside the private subnet
resource "aws_instance" "tf_private" {
   ami  = "${var.ami}"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet-a.id}"
   vpc_security_group_ids = ["${aws_default_security_group.default.id}"]
   iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.name}"
   source_dest_check = false
   user_data = "${file("install.sh")}"

  tags {
    Name = "sandbox host"
    Environment = "Sandbox"
  }
}

# Create sandbox S3 bucket
resource "aws_s3_bucket" "sandbox" {
  bucket_prefix = "${var.sandbox_name}-sandbox-"
  acl    = "private"

  tags {
    Name        = "Sandbox"
    Environment = "sandbox"
  }
}
