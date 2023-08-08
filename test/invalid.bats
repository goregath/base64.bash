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

@test "input less than four characters" {
	run base64 -d <<<"VVV"
	assert_failure
	assert_output -e '^error:'
}

@test "input not aligned by four characters" {
	run base64 -d <<<"VVVVV"
	assert_failure
	assert_output -e '^error:'
}
