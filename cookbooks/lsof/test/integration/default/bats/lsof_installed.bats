#!/usr/bin/env bats

@test "lsof binary is found in PATH" {
  run which lsof
  [ "$status" -eq 0 ]
}
