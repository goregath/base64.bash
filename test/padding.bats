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

@test "two byte padding" {
	run base64 -d <<<"YWJjZA=="
	assert_success
	assert_output 'abcd'
}

@test "one byte padding" {
	run base64 -d <<<"YWJjZGU="
	assert_success
	assert_output 'abcde'
}

@test "no padding" {
	run base64 -d <<<"YWJjZGVm"
	assert_success
	assert_output 'abcdef'
}

@test "invalid padding #1" {
	run base64 -d <<<"X==="
	assert_failure
	assert_output -e '^error:'
}

@test "invalid padding #2" {
	run base64 -d <<<"===="
	assert_failure
	assert_output -e '^error:'
}