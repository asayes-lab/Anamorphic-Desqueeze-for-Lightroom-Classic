# Anamorphic Desqueeze for Lightroom Classic

Creates a desqueezed copy of anamorphic photos, right from Lightroom's Library menu.

## What it does

This plugin creates a desqueezed copy of selected anamorphic photos, right from Lightroom Classic's
Library menu. Pick your squeeze factor, and it generates a properly proportioned copy next to the
original in your catalog, no exporting to another app and re-importing by hand.

You can also optionally flag, rate, color-label, and/or keyword the copies it creates, making it
easy to find and manage them afterward.

## Requirements

- **Lightroom Classic** (this plugin does not work with the cloud-based Lightroom, which has no
  plugin API).
- **[ImageMagick](https://imagemagick.org/script/download.php)** version 7, installed separately.
  Make sure the `magick` command-line tool is included in your install.

## Installation

1. Install **[ImageMagick](https://imagemagick.org/script/download.php)** version 7 (make sure the
   `magick` command-line tool is included). Confirm it worked by running `magick -version` in a
   terminal.
2. Download the latest plugin release and unzip it.
3. In Lightroom Classic, go to **File > Plug-in Manager > Add**, and select the
   `desqueeze.lrplugin` folder.
4. Make sure it shows as enabled in the plugin list.

## Usage

1. Select one or more photos in Library Grid view.
2. **Library > Plug-in Extras > Desqueeze copy...**
3. Pick a squeeze factor (1.33x, 1.5x, 1.6x, 1.8x, 2.0x, or type a custom value).
4. The first time you run it, point the ImageMagick field at your `magick` executable if it isn't
   auto-detected. 
5. Choose whether to stack the copy with the original.
6. Optionally check **Set flag / rating / color on the copy** and pick values, and/or check
   **Add keyword to the copy** and set the keyword text (defaults to "Desqueezed").
7. Click OK. The desqueezed TIFF appears in your catalog next to the original, with any flag,
   rating, color label, and keyword applied as chosen.

All settings in the dialog — including the flag/rating/color and keyword options — are remembered
as defaults for next time.

## Known limitations

- Output is always TIFF, not a raw format — the stretch has to happen on rendered pixels, since raw
  sensor data can't be non-uniformly resized and still be a valid raw file.
- Only handles still photos, not video.
- Squeeze direction is inferred from the photo's orientation metadata; if a stretch comes out on
  the wrong axis for an unusual orientation, please open an issue with the details.
- The color label option writes the default English label names (red, yellow, green, blue, purple).
  If you've customized your color label names in Lightroom's preferences, this may not map correctly.

## License

MIT — see LICENSE.
