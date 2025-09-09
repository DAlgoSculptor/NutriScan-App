# SVG to PNG Conversion Guide for NutriScan App Icon

## Overview
This guide explains how to convert the `nutriscan_logo.svg` file to a PNG format suitable for use as the app icon.

## Steps to Convert SVG to PNG

### Method 1: Using Figma (Recommended - Free)
1. Go to [figma.com](https://www.figma.com) and create a free account
2. Create a new design file
3. Drag and drop `nutriscan_logo.svg` into the canvas
4. Select the icon and resize it to 1024x1024 pixels
5. Go to File > Export
6. Choose PNG format
7. Set the export size to 1024x1024
8. Click "Export" and save as `app_icon.png`

### Method 2: Using Online Converters
1. Visit [convertio.co](https://convertio.co/svg-png/)
2. Upload `nutriscan_logo.svg`
3. Select PNG as the output format
4. Click "Convert"
5. Download the converted file
6. Rename to `app_icon.png`

### Method 3: Using Inkscape (Free Desktop Application)
1. Download and install Inkscape from [inkscape.org](https://inkscape.org/)
2. Open Inkscape
3. File > Open > Select `nutriscan_logo.svg`
4. File > Export As
5. Choose PNG format
6. Set width and height to 1024 pixels
7. Save as `app_icon.png`

## Important Notes
- The final PNG should be exactly 1024x1024 pixels
- Replace the existing `assets/images/app_icon.png` with the new file
- After replacing the file, run `flutter pub run flutter_launcher_icons` to generate all required icon sizes
- Test the icon on both Android and iOS simulators/devices

## Design Specifications
- Main color: #4CAF50 (primary green)
- Secondary color: #2E7D32 (dark green)
- Background: White circle
- Key elements: Leaf shape with scanning lines