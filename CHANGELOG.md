# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2020-01-19

- Forked from [@dimensigon](https://github.com/dimensigon)
- Fixed container issue when rerun
- Modify Dockerfile
    - Change image from `centos:7` to `oraclelinux:7`
    - Place all necessary environment variables
    - Include all heavy duty tasks (file downloads, package installs, etc.)
- Add feature(s) for Tibero Preboot Configuration
    - Conditional initialization (`gen_tip.sh`, `tb_create_db.sh` run only during first initialization)
	- Environment Variables for configuring `tibero.tip`  (`TB_MAX_SESSION_COUNT`, `TB_MEMORY_TARGET`, `TB_TOTAL_SHM_SIZE`)
- Add explanation for Docker configuration