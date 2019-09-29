# VclEx for Delphi

This library contains some VCL components with improved functionality for new versions of Delphi.

## How to use

To compile and design projects that depend on this library inside IDE you need to install it first. To do so, open **VclExtension.dproj**, right click on it in the Projects window and choose _Install_. It will compile the package and add the visual component to the Components toolbar under Win32Ex page. To uninstall, go to Component -> Install Packages and remove "Vcl Extended Components" package.

When using in a VCL application make sure to add the sources (*.pas) to your project by going to Project -> Add to project.

## ListViewEx

### Fixes
 - `Clear` method didn't trigger `OnSelectItems` for items that are currently selected
 - `AddItem` wasn't showing the caption sometimes
 - Pressing <kbd>Space</kbd> checks/unchecks all selected items

### New features
 - Accessing caption and subitems with `Cell[i]` without need to preallocate them
 - Items now store hints
 - Changing per-item background color
 - Add missing event for ending item editing
 - Feature to preserve selection when calling `BeginUpdate`/`EndUpdate`
 - Text searching functionality

### New shortcuts
 - <kbd>Crtl+A</kbd> to select all items
 - <kbd>Crtl+C</kbd> to copy content of a main column
 - <kbd>Crtl+Shift+C</kbd> to copy content of all columns