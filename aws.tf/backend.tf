terraform {
    backend "s3" {
        encrypt = true
        bucket = "s5-tfstate"
        # key = "barebone-dev/"
        region = "us-east-2"
    }
}

