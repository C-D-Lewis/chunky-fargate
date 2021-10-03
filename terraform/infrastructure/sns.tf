resource "aws_sns_topic" "notifications_topic" {
  count = var.email_notifications_enabled ? 1 : 0
 
  name = "${var.project_name}-sns-topic"
}
