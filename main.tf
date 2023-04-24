locals {
  region = data.aws_region.current.name
}

data "aws_region" "current" {}