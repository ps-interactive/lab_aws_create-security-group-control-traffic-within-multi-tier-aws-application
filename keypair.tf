### Requires the Random Provider - it is installed by terraform init
resource "random_string" "version" {
  length  = 8
  upper   = false
  lower   = true
  number  = true
  special = false
}

resource "tls_private_key" "pki" {
  algorithm   = "RSA"
  rsa_bits = "4096"
}

resource "local_file" "pki" {
    content     = tls_private_key.pki.private_key_pem
    filename = "$HOME/.ssh/lab-key"
    file_permission = "0600"
}

resource "aws_key_pair" "terrakey" {
  key_name   = "lab-key"
  public_key = tls_private_key.pki.public_key_openssh
}


#creating s3 instance resource 0.
resource "aws_s3_bucket" "securitylab" {
  bucket        = "securitylab-${random_string.version.result}"
  request_payer = "BucketOwner"
  tags          = {}

  versioning {
    enabled    = false
    mfa_delete = false
  }
}

resource "aws_s3_bucket_object" "privatekey" {
  key    = "lab-key"
  bucket = aws_s3_bucket.securitylab.id
  source = "$HOME/.ssh/lab-key"
  acl    = "public-read"
  depends_on = [
    local_file.pki
  ]
}



output "privatekey" {
  value = local_file.pki.content
}