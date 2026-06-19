# resource "aws_s3_bucket_notification" "this" {
#   bucket = aws_s3_bucket.this.id

#   queue {
#     queue_arn = aws_sqs_queue.this.arn
#     events    = ["s3:ObjectCreated:*"]
#     filter_suffix = ".jpg"
#   }
# }
