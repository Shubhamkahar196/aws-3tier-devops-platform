resource "aws_db_subnet_group" "main"{
    name = "${var.project_name}-db-subnet-group"
    subnet_ids = var.database_subnet_ids

    tags={
         Name    = "${var.project_name}-db-subnet-group"
    Project = var.project_name
    Tier    = "database"
    }
}


resource "aws_db_instance" "postgres"{
    identifier = "${var.project_name}-postgres"
    
    engine = "postgres"
    engine_version = "17"

    instance_class = var.instance_class
    allocated_storage = 20
    max_allocated_storage = 50
    storage_type = "gp3"
    

    db_name = var.db_name
    username = var.db_username

    manage_master_user_password = true

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [var.database_security_group_id]

    multi_az = var.multi_az
    publicly_accessible = false

    backup_retention_period = 1
    skip_final_snapshot = true
    deletion_protection = false

    tags = {
        Name = "${var.project_name}-postgres"
        Project = var.project_name
        Tier = "database"
    }
}