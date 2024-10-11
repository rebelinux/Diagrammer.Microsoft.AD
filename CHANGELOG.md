# :arrows_clockwise: Microsoft AD Diagrammer Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.6] - 2024-10-11

### Fixed

- Fix an issue with error handling

## [0.2.5] - 2024-10-05

### Changed

- Migrate nodes to Get-DiaHTMLNodeTable on module Get-DiagForest

### Fixed

- Remove the use of the Multicolumns option

## [0.2.4] - 2024-06-15

### Changed

- Improved Site diagram SiteLink object text

## [0.2.3] - 2024-05-16

### Added

- Added SiteLink information to the Domain and Trust diagram

### Changed

- Increased Diagrammer.Core minimum version requirement v0.2.1

### Fixed

- Fix [#19](https://github.com/rebelinux/Diagrammer.Microsoft.AD/issues/19)

## [0.2.2] - 2024-05-08

### Added

- Domain and Trust diagram

### Changed

- Increased Diagrammer.Core minimum version requirement v0.2.0

### Fixed

- Fix [#10](https://github.com/rebelinux/Diagrammer.Microsoft.AD/issues/10)

## [0.2.1] - 2024-03-16

### Changed

- Increased Diagrammer.Core minimum version requirement

### Fixed

- Improved Site diagram code
- Fix [#18](https://github.com/rebelinux/Diagrammer.Microsoft.AD/issues/18)

## [0.2.0] - 2024-02-20

### Fixed

- Increased Diagrammer.Core (v0.1.3) minimum version requirement

## [0.1.9] - 2024-02-20

### Fixed

- Fix Diagrammer.Core module rename due to conflict with ImportExcel

## [0.1.8] - 2024-02-20

### Changed

- Migrated common module to Diagrammer.Core

## [0.1.7] - 2024-02-16

### Changed

- Updated Graphviz binaries to 10.0.1
- Changed Signature code from node to a subgraph to better align the content
- Overall diagram design simplification

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

### Fixed

- Fixed CodeQL security alerts

## [0.1.5] - 2024-01-25

### Fixed

- Added missing dll files on Graphviz binaries

## [0.1.4] - 2024-01-25

### Changed

- Added Graphviz libraries to local module folder. (No need to manually install Graphviz)

## [0.1.3] - 2024-01-24

### Changed

- Disabled strict modes

## [0.1.2] - 2024-01-21

### Changed

- Setting strict mode to latest

### Fixed

- Fix issue with base64 format not working without setting the outputfolderpath

## [0.1.1] - 2024-01-19

### Changed

- Improved Forest Diagram

## [0.1.0] - 2024-01-17

### Added

- Initial release
  - Forest diagram support
