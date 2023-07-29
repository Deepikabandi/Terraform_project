# variable "ami" {
#   default = "ami-0eb260c4d5475b901"
# }
# variable "instance_type" {
#   default = "t2.micro"
# }
# variable "environment" {
#   default = "dev"
# }
# variable "sg_ports" {
#   type    = list(number)
#   default = [8080, 80, 8282, 8989]
# }
variable "ami" {
  default = "ami-0b594cc165f9cddaa"
}
variable "instance_type" {
  default = "t2.micro"
}


