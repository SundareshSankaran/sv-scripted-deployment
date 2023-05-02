#!/usr/bin/env bash

# Parameters:
# 1 - Logs directory

mkdir -p $1/oldlogs && mv $1/*.log  $1/oldlogs/