#!/usr/bin/env bash

# shellcheck shell=bats
# shellcheck disable=SC1091

if [[ -z "$BATS_TEST_DIRNAME" ]]; then
	exec "${0%/*}"/bats/bats-core/bin/bats --tap "$0" "$@"
fi

source "$BATS_TEST_DIRNAME"/bats/commons.bash

setup() {
	load 'bats/bats-support/load'
	load 'bats/bats-assert/load'
	run type -t base64
	assert_output 'function'
}

binencode() {
	local b
	printf -v b '\\x%02x' {0..255}
	printf %b "$b" | command base64
}

libdecode() {
	base64 -d | command sha256sum
}

@test "raw binary data" {
	run libdecode < <(binencode)
	assert_output -p '40aff2e9d2d8922e47afd4648e6967497158785fbd1da870e7110266bf944880'
}