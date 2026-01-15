# 1. יצירת ה-VPC הראשי של הפרויקט
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "devops-vpc" }
}

# שליפת רשימת איזורי הזמינות (us-east-1a, us-east-1b...)
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Subnet ראשונה (איזור A) - עבור השרתים וה-ALB
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0] # us-east-1a
  tags = { Name = "devops-public-subnet-1" }
}

# 3. Subnet שנייה (איזור B) - חובה עבור ה-ALB
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1] # us-east-1b
  tags = { Name = "devops-public-subnet-2" }
}

# 4. Internet Gateway (יציאה לאינטרנט)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "devops-igw" }
}

# 5. Route Table (נתב)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 6. חיבור ה-Subnet הראשונה לנתב
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. חיבור ה-Subnet השנייה לנתב
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}