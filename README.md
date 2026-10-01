# Anamorphic Desqueeze for Lightroom Classic

Creates a desqueezed copy of anamorphic photos, right from Lightroom's Library menu.

## What it does

Select one or more photos in Library Grid view, go to **Library > Plug-in Extras > Desqueeze copy...**,
choose your squeeze factor, and the plugin will:

1. Export each photo as a 16-bit ProPhoto RGB TIFF (with your current edits baked in).
2. Stretch it horizontally (or vertically, for portrait-oriented shots) by the chosen factor using
   ImageMagick.
3. Save the result next to the original as `<filename>_desqueezed.tif` and add it to your catalog,
   optionally stacked with the original.
4. Optionally set a flag, star rating, and/or color label on the copy, and/or add a keyword to it —
   handy for filtering your desqueezed copies later. Both options are off by default.

A rendered TIFF (rather than a DNG) is used because the stretch has to happen on rendered pixels —
a raw file's sensor data can't be non-uniformly resized and still be a valid raw file. 16-bit TIFF
keeps maximum editing headroom for your subsequent color and tone work.

## Requirements

- **Lightroom Classic** (this plugin does not work with the cloud-based Lightroom, which has no
  plugin API).
- **[ImageMagick](https://imagemagick.org/script/download.php)** version 7, installed separately.
  Make sure the `magick` command-line tool is included in your install.

## Installation

1. Download the latest release and unzip it.
2. In Lightroom Classic, go to **File > Plug-in Manager > Add**, and select the
   `desqueeze.lrplugin` folder.
3. Make sure it shows as enabled in the plugin list.

## Usage

1. Select one or more photos in Library Grid view.
2. **Library > Plug-in Extras > Desqueeze copy...**
3. Pick a squeeze factor (1.33x, 1.5x, 1.6x, 1.8x, 2.0x, or type a custom value).
4. The first time you run it, point the ImageMagick field at your `magick` executable if it isn't
   auto-detected. Run `magick -version` in a terminal to confirm your install, and
   `which magick` (Mac) / `where magick` (Windows) to find its exact path.
5. Choose whether to stack the copy with the original.
6. Optionally check **Set flag / rating / color on the copy** and pick values, and/or check
   **Add keyword to the copy** and set the keyword text (defaults to "Desqueezed").
7. Click OK. The desqueezed TIFF appears in your catalog next to the original, with any flag,
   rating, color label, and keyword applied as chosen.

All settings in the dialog — including the flag/rating/color and keyword options — are remembered
as defaults for next time.

## Known limitations

- Output is always TIFF, not DNG — see "What it does" above for why.
- Only handles still photos, not video.
- Squeeze direction is inferred from the photo's orientation metadata; if a stretch comes out on
  the wrong axis for an unusual orientation, please open an issue with the details.
- The color label option writes the default English label names (red, yellow, green, blue, purple).
  If you've customized your color label names in Lightroom's preferences, this may not map correctly.

## License

MIT — see LICENSE.
