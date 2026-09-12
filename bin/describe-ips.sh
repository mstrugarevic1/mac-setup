#!/usr/bin/env bash
#
# Show used and free IP addresses per subnet, grouped by VPC, with the Name tag
# of each VPC when it exists. The count accounts for the five addresses AWS
# reserves in every subnet, so it shows where EKS or pod IPs are close to
# exhaustion.
#
# Usage:
#   describe-ips [region]     # defaults to the configured region

set -euo pipefail

REGION="${1:-$(aws configure get region 2>/dev/null || true)}"
[[ -n "$REGION" ]] || {
    echo 'usage: describe-ips [region]   (no configured region found)' >&2
    exit 1
}

VPC_NAMES="$(aws ec2 describe-vpcs --region "$REGION" \
    --query 'Vpcs[].{VPC:VpcId,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output json)"

aws ec2 describe-subnets --region "$REGION" \
    --query 'Subnets[].{VPC:VpcId,Subnet:SubnetId,AZ:AvailabilityZone,CIDR:CidrBlock,Free:AvailableIpAddressCount,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output json \
    | jq -r --argjson vpcs "$VPC_NAMES" '
        ($vpcs | map({(.VPC): .Name}) | add) as $vpcname
        | sort_by(.VPC, .AZ)
        | group_by(.VPC)[]
        | "VPC: \(.[0].VPC) (\($vpcname[.[0].VPC] // "-"))",
          (.[]
            | (.CIDR | split("/")[1] | tonumber) as $prefix
            | (pow(2; 32 - $prefix) - 5) as $total
            | ($total - .Free) as $used
            | "  \(.Subnet)  \(.AZ)  \(.CIDR)  used=\($used)/\($total)  free=\(.Free)  \(.Name // "-")"),
          ""
      '
