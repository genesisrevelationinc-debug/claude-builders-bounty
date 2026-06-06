# Changelog

## [v1.0.0] - 2026-03-15

### Added
- Initial release of the changelog generator script
- Support for fetching commits since last git tag
- Auto-categorization of changes into Added/Fixed/Changed/Removed sections
- Structured output to CHANGELOG.md

### Changed
- Improved changelog formatting logic
- Better grouping of commit types

### Fixed
- Issue with duplicate commit processing
- Error handling for repositories with no tags

### Removed
- Deprecated legacy changelog generation method


## [v0.2.0] - 2026-03-10

### Added
- New feature for changelog generation
- Support for automatic version detection

### Fixed
- Minor bug fixes in parsing


## [v0.1.0] - 2026-03-01

### Added
- Initial version of changelog generator
- Basic commit parsing functionality
- Category classification (Add, Fix, Change, Remove)
- CHANGELOG.md output file creation

### Fixed
- Formatting issues in generated changelog

### Changed
- Improved commit message parsing logic
- Enhanced error handling for edge cases