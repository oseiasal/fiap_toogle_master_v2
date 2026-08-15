output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.events.url
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.events.arn
}

output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.events.name
}
