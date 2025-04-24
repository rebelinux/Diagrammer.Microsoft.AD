# :arrows_clockwise: Microsoft AD Diagrammer Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.14] - 2025-04-24

### Added

- Bump version to 0.2.14
- Add theme to diagrams
  - Neon
  - Black
  - White

## [0.2.13] - 2025-04-18

### Changed

- Bump version to 0.2.13
- Increase Diagrammer.Core minimum version requirement to v0.2.24
- Refine code formatting in various scripts for consistency

## [0.2.12] - 2025-04-15

### Changed

- Bump version to 0.2.12
- Increase Diagrammer.Core minimum version requirement to v0.2.23

## [0.2.11] - 2025-04-14

### Added

- Introduced support for using a PSSession parameter to establish connections via WinRM.

### Changed

- Bump version to 0.2.11
- Increase Diagrammer.Core minimum version requirement to v0.2.22
- Change diagram icons
- Refactor code structure for improved readability and maintainability
- Enhance AD diagram functions with improved trust information handling, add new translation keys, and optimize child domain node rendering logic.

### Fixed

- Fix Forest diagram when there is more than 5 child domian

## [0.2.10] - 2025-04-08

### Changed

- Bump version to 0.2.10
- Increase Diagrammer.Core minimum version requirement to v0.2.20
- Enforce connections to the Domain Controller using its Fully Qualified Domain Name (FQDN) instead of its IP address
- Enhance code to handle scenarios where no infrastructure is available for diagramming

### Fixed

- Fix issue where the Server 2025 domain mode was not being detected correctly

## [0.2.9] - 2025-03-04

### Changed

- Increase Diagrammer.Core minimum version requirement to v0.2.19
- Enhance diagram font styling

## [0.2.8] - 2025-02-21

### Added

- Add Certificate Diagram
- Add spanish translation

### Changed

- Increase Diagrammer.Core minimum version requirement to v0.2.15
- Add forest root as a child domain
- Improved Forest diagram
- Improved Site Inventory diagram

## [0.2.7] - 2024-11-15

### Changed

- Increased Diagrammer.Core minimum version requirement to v0.2.12

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
