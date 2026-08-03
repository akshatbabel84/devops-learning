terraform{
    required_providers{
        aws={
            source="hashicorp/aws"
            version="~>5.0"
        }

    }
}

variable "dev_bucket1"{
    type = string
    description = "Name of the s3 bucket to create"
    default = "akshat-devops-learning-bucket-2026" 
}

variable "enable_versioning"{
    type = bool
    description = "Adding the variable for versioning"
    default = true
}

variable "environment"{
    type = string
    description = "Adding the environment here"
    default = "dev"
}


provider "aws"{
    region = "ap-south-1"
}

resource "aws_s3_bucket" "my_first_bucket"{
    bucket=var.dev_bucket1
    tags = {
        Environment = var.environment
    }
}

resource "aws_s3_bucket_versioning" "my_first_bucket_versioning"{
    bucket = aws_s3_bucket.my_first_bucket.id
    versioning_configuration{
        status = var.enable_versioning ? "Enabled" : "Suspended"
    }
}