# Changelog

All notable changes to this plugin are documented here.

## [1.1.0] 
1.10.2026
### Added
- Option to set flag, star rating, and color label on the desqueezed copy.
- Option to add a keyword to the desqueezed copy.
- Both new options are adjustable in the dialog and saved as defaults.

## [1.0.1]
1.10.2026
### Fixed
- Error when adding a desqueezed copy without stacking
  (`LrCatalog:addPhoto: position can not be used unless stackWithPhoto is present`).

## [1.0.0]
### Added
- Initial release.
- Right-click / Library menu entry to create a desqueezed copy of selected photos.
- Exports as 16-bit ProPhoto RGB TIFF, stretched via ImageMagick (Lanczos filter) to an exact
  pixel size based on the chosen squeeze factor.
- Adjustable squeeze factor, ImageMagick path, and stacking option, saved as defaults.
