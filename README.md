# Anamorphic Desqueeze for Lightroom Classic

Creates a desqueezed copy of anamorphic photos directly from Lightroom Classic's Library menu.

## What it does

Select one or more photos in Library Grid view, go to **Library > Plug-in Extras > Desqueeze copy...**, choose your squeeze factor, and the plugin will:

1. Export each photo as a 16-bit ProPhoto RGB TIFF, with your current Lightroom edits baked in.
2. Stretch it horizontally (or vertically, for portrait-oriented shots) by the chosen factor using ImageMagick.
3. Save the result next to the original as `<filename>_desqueezed.tif` and add it to your catalog, optionally stacked with the original.

A rendered TIFF (rather than a DNG) is used because the stretch has to happen to rendered pixels. A raw file's sensor data can't be non-uniformly resized and still remain a valid raw file. 16-bit TIFF preserves maximum editing headroom for subsequent color and tone work.

## Requirements

* **Lightroom Classic** — this plugin does not work with the cloud-based Lightroom, which does not provide a plugin API.
* **ImageMagick 7**, installed separately. The `magick` command-line tool must be included in the installation.

## Installation

1. Download the latest release ZIP from the **Releases** section of this GitHub repository.
2. Extract the ZIP. It should contain the `Desqueeze.lrdevplugin` folder.
3. In Lightroom Classic, go to **File > Plug-in Manager**.
4. Click **Add**.
5. Select the extracted `Desqueeze.lrplugin` folder.
6. Make sure the plugin appears in the Plug-in Manager and is shown as enabled.

You only need to install the plugin once. When a new version is released, download the new release ZIP, extract it, and use the new plugin folder in Lightroom's Plug-in Manager.

## ImageMagick

ImageMagick must be installed separately. Make sure the `magick` command-line tool is included with your installation.

To verify that ImageMagick is installed, open a terminal or command prompt and run:

```text
magick -version
```

The plugin normally detects the `magick` executable automatically. If it doesn't, you can specify its location in the plugin's settings.

To find the executable:

**Windows:**

```text
where magick
```

**macOS:**

```text
which magick
```

## Usage

1. Select one or more photos in **Library Grid view**.
2. Go to **Library > Plug-in Extras > Desqueeze copy...**
3. Choose a squeeze factor: **1.33x, 1.5x, 1.6x, 1.8x, 2.0x**, or enter a custom value.
4. If ImageMagick was not detected automatically, specify the path to the `magick` executable.
5. Choose whether to stack the desqueezed copy with the original.
6. Click **OK**.

The desqueezed TIFF is created next to the original and added to your Lightroom catalog.

## Known limitations

* Output is always TIFF, not DNG — see **What it does** above for why.
* Only still photos are supported; video is not supported.
* Squeeze direction is inferred from the photo's orientation metadata. If a stretch is applied along the wrong axis for an unusual orientation, please open an issue with the details.

## License

MIT — see [LICENSE](LICENSE).
