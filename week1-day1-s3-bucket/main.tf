terraform{
    required_providers{
        aws={
            source="hashicorp/aws"
            version="~>5.0"
        }

    }
}

provider "aws"{
    region = "ap-south-1"
}

resource "aws_s3_bucket" "my_first_bucket"{
    bucket="akshat-devops-learning-bucket-2026"
}