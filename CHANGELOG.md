# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
*Currently no unreleased changes*

## [1.0.0] - 2019-11-12
### Changed
- removed EnvConfig dependency. Replaced `EnvConfig.get/2` with `Application.get_env/2`

## [0.4.4] - 2018-12-14
### Added
- This changelog!

### Changed
- Added support in vm stats for OTP21 logging in order to provide the number of `error`-level log messages in the logging queue.  Support for `:error_logger` is maintained
