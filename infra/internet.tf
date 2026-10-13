resource "aws_internet_gateway" "travel" {
  vpc_id = aws_vpc.travel.id

  tags = {
    Name = "travel-internet-gateway"
  }
}

resource "aws_route_table" "travel_public" {
  vpc_id = aws_vpc.travel.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.travel.id
  }

  tags = {
    Name = "travel-public-routes"
  }
}

resource "aws_route_table_association" "travel_a" {
  subnet_id      = aws_subnet.travel_a.id
  route_table_id = aws_route_table.travel_public.id
}

resource "aws_route_table_association" "travel_b" {
  subnet_id      = aws_subnet.travel_b.id
  route_table_id = aws_route_table.travel_public.id
}
