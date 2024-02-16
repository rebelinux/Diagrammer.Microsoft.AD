# :arrows_clockwise: Microsoft AD Diagrammer Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.6] - 2024-02-08

### Added

- Added Localization support for the following languages:
  - en-US
  - es-ES
- Added Sites Inventory DiagramType
- Added Get-HTMLNodeTable cmdlet

### Changed

- Improved diagram layout
- Improved Get-HTMLTable cmdlet (Now allow MultiColumn table)
- Updated Graphviz binaries to 10.0.1

### Fixed

- Fixed CodeQL security alerts

## [0.1.5] - 2024-01-25

### Fixed

- Added missing dll files on Graphviz binaries

## [0.1.4] - 2024-01-25

### Chaged

- Added Graphviz libraries to local module folder. (No need to manually install Graphviz)

## [0.1.3] - 2024-01-24

### Chaged

- Disabled strict modes

## [0.1.2] - 2024-01-21

### Chaged

- Setting strict mode to latest

### Fixed

- Fix issue with base64 format not working without setting the outputfolderpath

## [0.1.1] - 2024-01-19

### Chaged

- Improved Forest Diagram

## [0.1.0] - 2024-01-17

### Added

- Initial release
  - Forest diagram support
