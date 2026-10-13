resource "aws_subnet" "travel_a" {
  vpc_id                  = aws_vpc.travel.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "travel-subnet-a"
  }
}

resource "aws_subnet" "travel_b" {
  vpc_id                  = aws_vpc.travel.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "travel-subnet-b"
  }
}
