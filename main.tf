provider "aws" {
    region = var.aws_region
}
resource "aws_cloudwatch_event_rule" "emr-state-change" {
  name        = "capture-emr-state"
  description = "This rule monitors if a job in cluster is terminated or terminated with errors"
  event_pattern = file("event-pattern.json")
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_logins.arn
}

resource "aws_sns_topic" "aws_logins" {
  name = "aws-console-logins"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.aws_logins.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.aws_logins.arn]
  }
}
