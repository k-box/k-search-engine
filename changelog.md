# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/0.3.0/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.4.0] - 2018-02-09
### Added
- Updated field configuration for `filename_*` fields [PR-3](https://github.com/k-box/k-search-engine/pull/3)

## [0.3.1] - 2018-01-12

### Changed
- Updated Solr to v5.5.5 [PR #2](https://github.com/k-box/k-search-engine/pull/2)

## [0.3.0] - 2018-01-10

- Added support for field sorting based on string representation. Ordering is case insensitive.

## [0.2.2] - 2017-11-01

### Changed

- Updated solr configuration to commit `a459883c6`, which reverts a change
  that caused regression bugs in the handling of datetime strings.

## [0.2.1] - 2017-10-25

### Added

- Ability to trigger a deployment on the test.slmtj.net integration environment

### Changed

- Updated solr configuration to commit `66472e0653`. 
  This includes date format fix when adding or updating a previously added data
- Updated `.gitlab-ci.yml` to use Gitlab's new environment variable names

## [0.2.0] - 2017-10-04

### Changed

- Updated solr configuration to commit `ac3c344`. This includes integer 
  indexing and better string indexing support

## [0.1.0] - 2017-05-31

### Added

- Startup script that gracefully handle container shutdown
- SOLR 5.5.x configuration
- Docker image building
- More logging during build time and service startup time
