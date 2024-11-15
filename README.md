# Printainer
Your fully parametric "designed as code" container creation tool!

Printainer measurements is based on *internal* space. This was done to allow users to tailer very specific measurements to your desired needs. Printainer does caluclate the total space. You can provide your printer bed max measurements. Printainer will assert an error if the total size of either a container or lid exceeds your print capacity in height, width, or depth.

## Setup

### Installing BOSL2
Printainer makes heavy use of the external open source library [BOSL2](https://github.com/BelfrySCAD/BOSL2). Printainer assumes BOSL2 has been installed as an Openscad library. 

To set this up on a Windows workstation:

1. Download or clone the library to wherever you keep your Openscad libraries. For example:
`C:\path\to\OpenSCAD\libraries`
2. Be sure to add this to your PATH system or user environment variable so printainer can find it. 

### Calibrating  $slop
BOSL2 uses a concept named `$slop` to make two physical parts fit together nicely. $slop is applied to the part that is subtracted from another part. For example to create the space fit a lid, you must "subtract" the lid from the container. However the fit will be too tight in phsyical pace. So the subtracted 3D space will be increased by your `$slop` size. This will make the physical lid will fit nicely.

Before printing a container that includes a lid, it is highly recommended that you calibrate your $slop value by print a $slop tool.

Most printers will need some slop. Out of the box a slop of 0.2 is configured. You can change the default $slop under the tolerances parameter section.

[Learn more about `$slop` here](https://github.com/BelfrySCAD/BOSL2/wiki/constants.scad#constant-slop) and find the code to print your `$slop` calibration tool.


