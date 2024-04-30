variable "ec2_instance_eu_west_2_ami" {
  type        = string
  description = "amazon linux ami for eu_west_2"
  default     = "ami-008ea0202116dbc56"
}

########################################################
# count and count index
variable "envs" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}
resource "aws_iam_user" "admin_users" {
  name  = "${var.envs[count.index]}_admin"
  count = 3
}
########################################################

########################################################
# conditional expressions
variable "is_test" {
  type    = bool
  default = true
}

resource "aws_instance" "dev" {
  ami           = var.ec2_instance_eu_west_2_ami #"ami-00e3eeef0a0a0a117"
  instance_type = "t2.micro"
  count         = var.is_test == true ? 1 : 0

  tags = {
    "team" = "dev"
  }
}

# resource "aws_instance" "prod" {
#   ami           = var.ec2_instance_eu_west_2_ami
#   instance_type = "t2.small"
#   count         = var.is_test == false ? 2 : 0
# }
########################################################

##################################################
# Data sources - use to fecth infomation outside Terraform
# Ecample
# reading info from a Digital Ocean Account or GCP Project or even read a file. GCP Example Below
# data "google_project" "project" { # fetch the data 
# }
# output "project_number" {
#   value = data.google_project.project.number # get the project number
# }
####################################
data "local_file" "gitignore" {
  filename = "${path.module}/../.gitignore"
}
output "file_output" {
  value = data.local_file.gitignore.content
}


data "aws_instances" "ec2-data" {
  filter {
    name   = "tag:team"
    values = ["dev"]
  }
}

output "ec2-data-output" {
  value = data.aws_instances.ec2-data
}
