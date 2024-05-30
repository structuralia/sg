# ---------------------------------------------
# Creación security group para el Bastion host
# ---------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Permite acceso via SSH por el puerto 22"
  vpc_id      = var.vpc_id
  

  ingress {
    description     = "acceso ssh por el puerto 22"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description       = "Permitir todo el trafico saliente"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }


  tags = {
    "Name" = "${var.env}-bastion-sg",
    "Proyect" = var.project_name
  }
}


# ----------------------------------------------------------
# Creación security group para la application load balancer
# ----------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "permite acceso http/https por el puerto 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "acceso http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "acceso https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description       = "Permitir todo el trafico saliente"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  tags = {
    "Name" = "${var.env}-alb_sg",
    "Proyect" = var.project_name
  }
}

# ----------------------------------------------------------
# Creación security group para la app
# ----------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "enable http/https access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  ingress {
    description     = "acceso shh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "acceso http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "acceso https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description       = "Permitir todo el trafico saliente"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  tags = {
    "Name" = "${var.env}-app-sg",
    "Proyect" = var.project_name
  }
}

# ----------------------------------------------------------
# Creación security group para la base de datos
# ----------------------------------------------------------
resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Control de acceso a la instancia de base de datos"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Permite acceso desde la instancias a las bases de datos"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
    # cidr_blocks = concat(values(aws_subnet.subnet_private_app)[*].cidr_block, values(aws_subnet.subnet_private_db)[*].cidr_block)
  }

  egress {
    description       = "Permitir todo el trafico saliente"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
  }

  tags = {
  "Name" = "${var.env}-db-sg",
  "Proyect" = var.project_name
  }
}


# ----------------------------------------------------------
# Creación security group para los discos EFS
# ----------------------------------------------------------
resource "aws_security_group" "efs_sg" {
  name        = "efs_sg"
  description = "Control de acceso a los discos EFS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Permite acceso desde la instancias a las discos NFS/EFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description       = "Permitir todo el trafico saliente"
    from_port         = 0
    to_port           = 0
    protocol          = -1
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  tags = {
    "Name" = "${var.env}-efs-sg",
    "Proyect" = var.project_name
  }
}

