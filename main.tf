resource "aws_efs_file_system" "efs-example" {
   creation_token = "efs-example"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EfsExample"
   }
 }



resource "aws_efs_mount_target" "efs-mt-example" {
   file_system_id  = "${aws_efs_file_system.efs-example.id}"
   subnet_id = "${aws_subnet.subnet-efs.id}"
   security_groups = ["${aws_security_group.ingress-efs.id}"]
 }




resource "aws_vpc" "test-env" {
   cidr_block = "10.0.0.0/16"
   enable_dns_hostnames = true
   enable_dns_support = true
   tags {
     Name = "test-env"
   }
 }

 resource "aws_subnet" "subnet-efs" {
   cidr_block = "${cidrsubnet(aws_vpc.test-env.cidr_block, 8, 8)}"
   vpc_id = "${aws_vpc.test-env.id}"
   availability_zone = "us-east-1a"
 }



resource "aws_security_group" "ingress-efs-test" {
   name = "ingress-efs-test-sg"
   vpc_id = "${aws_vpc.test-env.id}"

   // NFS
   ingress {
     security_groups = ["${aws_security_group.ingress-test-env.id}"]
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
   }

   // Terraform removes the default rule
   egress {
     security_groups = ["${aws_security_group.ingress-test-env.id}"]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }
