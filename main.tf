resource "random_id" "hash" {
  byte_length = 8
}

# Create a VPC to launch our instances into
resource "alicloud_vpc" "vpc" {
  cidr_block = "10.86.0.0/16"

  tags = {
    Name = "TF-Ansible-VPC-${random_id.hash.hex}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "alicloud_internet_gateway" "igw" {
  vpc_id = alicloud_vpc.vpc.id
}

# Grant the VPC internet access on its main route table
resource "alicloud_route" "internet_access" {
  route_table_id         = alicloud_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = alicloud_internet_gateway.igw.id
}

# Create a subnet to launch our instances into
resource "alicloud_subnet" "subnet" {
  vpc_id                  = alicloud_vpc.vpc.id
  cidr_block              = "10.86.100.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az
}

resource "alicloud_security_group" "sg" {
  name   = "tfansible-sg-${random_id.hash.hex}"
  vpc_id = alicloud_vpc.vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All ports open within the VPC
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.86.0.0/16"]
  }

  # port 80 open to the world
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow ping
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security-Group-${random_id.hash.hex}"
  }
}

data "alicloud_images" "centos" {
    owners = "system"
    name_regex = "^centos_6"
}

resource "alicloud_instance" "this" {
  image_id               = "${data.alicloud_images.centos.0.image_id}"
  instance_type          = "ecs.sn1ne.large"
  key_name               = "ansible"
  subnet_id              = alicloud_subnet.subnet.id
  security_groups        = [alicloud_security_group.sg.id]
  tags = {
    Name = "ansible-${random_id.hash.hex}"
  }
}

resource "ansible_host" "web" {
  inventory_hostname = alicloud_instance.this.public_ip
  groups             = ["web"]
  vars = {
    port         = 80
    ansible_user = "centos"
  }
}
