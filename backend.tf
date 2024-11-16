terraform {
    backend "s3" {
        profile = "somoim"
        bucket = "undefineddev-tf-state"
        key    = "production.tfstate"
        region = "ap-northeast-2"
      
    }
}