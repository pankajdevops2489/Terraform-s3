
resource "aws_kms_key" "kmskey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "queen-s3-devops-assessment-new"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_encryption" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kmskey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_iam_user" "my_user" {
  name = "queen-test" 
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy"
  description = "Allows putting bucket policy for S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:PutBucketPolicy",
        Resource = aws_s3_bucket.mybucket.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.my_user.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
