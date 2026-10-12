#!/usr/bin/env bash
# Deploy a host's home-manager configuration to that host over SSH.
#
# Usage: deploy.sh <hostname> [ssh-target]
#
#   hostname    host name from nix-hosts (matches "<user>@<hostname>" config)
#   ssh-target  optional override for the SSH destination; defaults to
#               <user>@<fqdn> from nix-hosts
#
# Everything is evaluated and built locally (using configured remote builders
# for other systems); the target only receives the closure and activates it.
set -euo pipefail

if [[ $# -lt 1 ]]; then
	echo "usage: $0 <hostname> [ssh-target]" >&2
	exit 1
fi

host="$1"
flake="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

config="$(nix eval --raw "$flake#homeConfigurations" \
	--apply "cs: builtins.concatStringsSep \"\n\" (builtins.filter (n: builtins.match \".*@${host}\" n != null) (builtins.attrNames cs))")"

if [[ -z "$config" ]]; then
	echo "error: no homeConfiguration found for host '$host'" >&2
	exit 1
fi
if [[ "$config" == *$'\n'* ]]; then
	echo "error: multiple homeConfigurations match host '$host':" >&2
	echo "$config" >&2
	exit 1
fi

attr="$flake#homeConfigurations.\"$config\""
user="${config%@*}"
fqdn="$(nix eval --raw "$attr._module.specialArgs.host.fqdn")"
target="${2:-$user@$fqdn}"

echo ">>> Deploying $config to $target"

echo ">>> Building $config"
out="$(nix build "$attr.activationPackage" --no-link --print-out-paths)"

echo ">>> Copying closure to $target"
nix copy --to "ssh-ng://$target" "$out"

echo ">>> Activating $out on $target"
ssh -t "$target" "HOME_MANAGER_BACKUP_EXT=backup $out/activate"
