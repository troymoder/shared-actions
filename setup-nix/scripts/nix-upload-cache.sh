#!/usr/bin/env bash

set -euo pipefail

if [[ ! -f "${NIX_CACHE_PRIVATE_KEY_FILE:-}" ]]; then
	echo "Error: ${NIX_CACHE_PRIVATE_KEY_FILE:-} not found"
	exit 1
fi

if [[ -z "${S3_CACHE_BUCKET:-}" ]]; then
	echo "Error: S3_CACHE_BUCKET not set"
	exit 1
fi

if [[ -z "${S3_CACHE_ENDPOINT:-}" ]]; then
	echo "Error: S3_CACHE_ENDPOINT not set"
	exit 1
fi

if [[ -s /tmp/nix-built-paths.txt ]]; then
	echo "Uploading $(wc -l </tmp/nix-built-paths.txt) paths to cache..."
	mapfile -t paths < <(sort -u /tmp/nix-built-paths.txt)
	nix copy \
		--to "s3://${S3_CACHE_BUCKET}/${S3_CACHE_NIX_PREFIX:-}?endpoint=${S3_CACHE_ENDPOINT}&scheme=https&compression=zstd&parallel-compression=true&secret-key=${NIX_CACHE_PRIVATE_KEY_FILE}&multipart-upload=true" \
		"${paths[@]}" ||
		echo "Warning: nix copy failed, continuing anyway"
else
	echo "No paths were built locally"
fi
