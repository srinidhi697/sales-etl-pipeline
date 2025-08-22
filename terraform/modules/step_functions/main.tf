resource "aws_sfn_state_machine" "etl_pipeline" {
  name     = "${var.project}-${var.env}-etl-sm"
  role_arn = var.sfn_role_arn

  definition = <<EOF
{
  "Comment": "ETL Orchestration with Lambda Crawler",
  "StartAt": "RunCrawler",
  "States": {
    "RunCrawler": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${var.lambda_arn}"
      },
      "Next": "RawToSilver"
    },
    "RawToSilver": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${var.project}-${var.env}-raw-to-silver"
      },
      "Next": "SilverToGold"
    },
    "SilverToGold": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${var.project}-${var.env}-silver-to-gold"
      },
      "End": true
    }
  }
}
EOF
}
