resource "aws_cloudwatch_log_group" "medusa_logs" {
  name              = "medusa-logs"
  retention_in_days  = 3
}
