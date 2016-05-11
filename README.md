# hanat

## Overview

Install, enable and configure highly available NAT servers in AWS. The server is configured to monitor a peer NAT server and will take over the gateway of the peer route table when the peer NAT server goes down; then the script will try to reboot the peer NAT server.

* `hanat` : Main class for the HA NAT server.

## Availability zones, route tables and number of servers

One route table, and one NAT server is needed for each availability zone to provide high availability. For two AZ setup, the NAT server monitors each other. For three AZ setup, each server monitors another server and three servers form a loop.

## IAM role requirements/example

1. Create following IAM policy and an IAM role (e.g. "NAT Monitor")
2. Create servers with above IAM role and tag: "description"="NAT server"

```xml
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:RebootInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Effect": "Allow",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/description": "NAT server"
        }
      }
    },
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

## Puppet example

```puppet
class { '::hanat':
  peerinstanceid   => 'i-88888888',
  peerroutetableid => 'rtb-88888888',
  myroutetableid   => 'rtb-88884444'
}
```

## Reference

https://aws.amazon.com/articles/2781451301784570
