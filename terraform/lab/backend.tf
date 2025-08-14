terraform {
  backend "oci" {
    namespace = "ax7otv4piohp"            # oci os ns get
    bucket    = "myBucket"                    # your bucket name
    region    = "us-phoenix-1"              # match bucket region
    key       = "terraform/envs/lab.tfstate"   # change dev -> prod/test as needed
  }
}