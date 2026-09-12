#!/usr/bin/env bash
#
# Terminate the EC2 instance behind an EKS node named in the ip-10-0-1-23 form.
#
# The ip-A-B-C-D hostname maps to the private IPv4 address A.B.C.D. The script
# converts the name to that address, finds the matching running instance and
# terminates it. The node is drained first unless --no-drain is given.
#
# Usage:
#   terminate-node ip-10-0-1-23.eu-central-1.compute.internal
#   terminate-node ip-10-0-1-23 [--region eu-central-1]
#   terminate-node 10.0.1.23 [--no-drain] [--yes]
#
# Flags:
#   --region <r>   AWS region (defaults to the configured region)
#   --no-drain     skip `kubectl drain` and terminate straight away
#   --yes, -y      skip the confirmation prompt

set -euo pipefail

REGION="$(aws configure get region 2>/dev/null || true)"
DRAIN=1
ASSUME_YES=0
INPUT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --region) REGION="$2"; shift 2 ;;
        --no-drain) DRAIN=0; shift ;;
        --yes|-y) ASSUME_YES=1; shift ;;
        -*) echo "unknown flag: $1" >&2; exit 1 ;;
        *) INPUT="$1"; shift ;;
    esac
done

[[ -n "$INPUT" ]] || {
    echo 'usage: terminate-node <node-name|ip> [--region r] [--no-drain] [--yes]' >&2
    exit 1
}
[[ -n "$REGION" ]] || {
    echo 'no region set (use --region or configure one)' >&2
    exit 1
}

# Accepts ip-10-0-1-23[.rest...] or a bare 10.0.1.23.
NODE_NAME=""
if [[ "$INPUT" =~ ^ip-([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+) ]]; then
    IP="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}.${BASH_REMATCH[4]}"
    NODE_NAME="$INPUT"
elif [[ "$INPUT" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    IP="$INPUT"
else
    echo "input '$INPUT' is not an ip-A-B-C-D node name or an A.B.C.D address" >&2
    exit 1
fi

INSTANCE_ID="$(aws ec2 describe-instances --region "$REGION" \
    --filters "Name=private-ip-address,Values=$IP" \
              "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].InstanceId' --output text)"

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "None" ]]; then
    echo "no running instance found with private IP $IP in $REGION" >&2
    exit 1
fi

# Context for a sanity check before anything is terminated.
IFS=$'\t' read -r NAME_TAG AZ TYPE < <(aws ec2 describe-instances --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`]|[0].Value,Placement.AvailabilityZone,InstanceType]' \
    --output text)

printf 'Instance   : %s\n' "$INSTANCE_ID"
printf 'Name tag   : %s\n' "${NAME_TAG:-<none>}"
printf 'Private IP : %s    AZ: %s    Type: %s\n' "$IP" "$AZ" "$TYPE"
printf 'Region     : %s\n' "$REGION"
printf 'Drain      : %s\n\n' "$([[ $DRAIN -eq 1 ]] && echo yes || echo no)"

if [[ $ASSUME_YES -ne 1 ]]; then
    printf 'Terminate this instance? [y/N] '
    read -r answer
    [[ "$answer" == [yY] ]] || { echo 'aborted.'; exit 0; }
fi

if [[ $DRAIN -eq 1 ]]; then
    # Resolve the kube node name when only a bare IP was given.
    if [[ -z "$NODE_NAME" ]]; then
        NODE_NAME="$(kubectl get nodes \
            -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' 2>/dev/null \
            | awk -v ip="$IP" '$2 == ip { print $1; exit }')"
    fi
    if [[ -n "$NODE_NAME" ]] && kubectl get node "$NODE_NAME" >/dev/null 2>&1; then
        echo "cordoning and draining $NODE_NAME ..."
        kubectl cordon "$NODE_NAME"
        kubectl drain "$NODE_NAME" \
            --ignore-daemonsets --delete-emptydir-data --force --timeout=120s || true
    else
        echo "warning: could not match a kube node for $IP; skipping drain" >&2
    fi
fi

echo "terminating $INSTANCE_ID ..."
aws ec2 terminate-instances --region "$REGION" --instance-ids "$INSTANCE_ID" \
    --query 'TerminatingInstances[].{Instance:InstanceId,Prev:PreviousState.Name,Now:CurrentState.Name}' \
    --output table
