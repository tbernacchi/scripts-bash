#!/bin/bash
wget https://github.com/opencontainers/runc/releases/download/v1.1.9/runc.arm64
install -m 755 runc.arm64 /usr/local/sbin/runc
