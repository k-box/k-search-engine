# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/0.3.0/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.1] - 2018-09-19

### Fixes

- Fixed index name in startup script
- Fixed build problem that prevented Docker image to start

## [1.0.0] - 2018-08-10

**The docker image for this version was released with a startup bug, please use 1.0.1**

### Changed

- Updated to Solr v7.4.0

## [0.4.2] - 2018-04-05

### Changed

- Increased maximum header size for request to 10MiB to accomodate long URIs
- Increased max form post from 100 MiByte to 500 MiByte

## [0.4.1] - 2018-03-16

### Added

- jhighlight 1.0 library to support extracting text from Java, C++, and Groovy attachments embedded in PDF files [PR-5](https://github.com/k-box/k-search-engine/pull/5)

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
