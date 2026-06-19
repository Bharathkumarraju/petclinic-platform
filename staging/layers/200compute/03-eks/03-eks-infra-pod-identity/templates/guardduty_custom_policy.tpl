{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AmazonGuardDutyFullAccessSid1",
        "Effect": "Allow",
        "Action": "guardduty:*",
        "Resource": "*"
      },
      {
        "Sid": "GuardDutyAgentPermissions",
        "Effect": "Allow",
        "Action": [
          "guardduty:CreateDetector",
          "guardduty:GetDetector",
          "guardduty:UpdateDetector",
          "guardduty:CreateIPSet",
          "guardduty:CreateThreatIntelSet",
          "guardduty:GetIPSet",
          "guardduty:GetThreatIntelSet",
          "guardduty:UpdateIPSet",
          "guardduty:UpdateThreatIntelSet",
          "guardduty:ListDetectors",
          "guardduty:CreateMembers",
          "ec2:DescribeInstances",
          "eks:DescribeCluster",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource": "*"
      },
      {
        "Sid": "CreateServiceLinkedRoleSid1",
        "Effect": "Allow",
        "Action": "iam:CreateServiceLinkedRole",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "iam:AWSServiceName": [
              "guardduty.amazonaws.com",
              "malware-protection.guardduty.amazonaws.com"
            ]
          }
        }
      },
      {
        "Sid": "ActionsForOrganizationsSid1",
        "Effect": "Allow",
        "Action": [
          "organizations:EnableAWSServiceAccess",
          "organizations:RegisterDelegatedAdministrator",
          "organizations:ListDelegatedAdministrators",
          "organizations:ListAWSServiceAccessForOrganization",
          "organizations:DescribeOrganizationalUnit",
          "organizations:DescribeAccount",
          "organizations:DescribeOrganization",
          "organizations:ListAccounts"
        ],
        "Resource": "*"
      },
      {
        "Sid": "IamGetRoleSid1",
        "Effect": "Allow",
        "Action": "iam:GetRole",
        "Resource": "arn:aws:iam::*:role/*AWSServiceRoleForAmazonGuardDutyMalwareProtection"
      },
      {
        "Sid": "AllowPassRoleToMalwareProtectionPlan",
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": "arn:aws:iam::*:role/*",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "malware-protection-plan.guardduty.amazonaws.com"
          }
        }
      }
    ]
}