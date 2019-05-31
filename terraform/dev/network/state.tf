terraform {
  backend "gcs" {
    bucket = "gcp-demo-terraform-state-bucket"
    prefix = "gcp/dev/network"
    region = "asia-southeast1"
  }
}
