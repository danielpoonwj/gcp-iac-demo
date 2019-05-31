terraform {
  backend "gcs" {
    bucket = "gcp-demo-terraform-state-bucket"
    prefix = "gcp/dev/jenkins"
    region = "asia-southeast1"
  }
}
