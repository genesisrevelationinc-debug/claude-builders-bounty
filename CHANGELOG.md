# Changelog

## v1.0.0 (2026-03-15)

### Added
- Initial release of the changelog generator
- Support for generating changelog from git history
- Auto-categorization of changes (Added, Fixed, Changed, Removed)
- Command line interface with `/generate-changelog` command

### Changed
- Improved parsing of commit messages for better categorization
- Updated README with clearer setup instructions

### Fixed
- Issue with duplicate entries in generated changelog
- Problem with handling special characters in commit messages

### Removed
- Deprecated legacy changelog generation methods
- Unused dependency on external changelog tools

## v0.2.0 (2026-03-10)

### Added
- Support for custom tag ranges
- Option to specify output file

### Fixed
- Minor bug fixes in commit parsing