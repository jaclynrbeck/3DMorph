# 3DMorph
3DMorph is a MATLAB-based script that analyzes microglia morphology from 3D data. Outputs include cell and territorial volume, branch length, and number of branch and end points.

------------------------------------------------------------

Written by Elisa M York
Packaged May 2018

This package comes with no warranty of any kind. Permission is
granted to use the material for noncommercial and research purposes. Please cite "3DMorph automatic analysis of microglial morphology in 3 dimensions from ex vivo and in vivo imaging". 

------------------------------------------------------------


Description
-----------

3DMorph imports .tif or .lsm stacks (3 dimensional images) and processes cell morphologies. 
To begin, run the program and select 'Interactive Mode'. Choose your file (must be in Current Folder or add path first), input xy and z scale, and channel information. 
From here, GUI windows are implemented with individual explanations. Follow the instructions, using image feedback to determine accuracy of data processing. 
Once complete, a Parameters file will be saved to the MATLAB Current Folder. This file can then be used to batch process files with no user input. 

Control and ExCell images are provided as test samples. 

For more information,troubleshooting tips, and to cite, please refer to [paper]. 

-------------------------------------------------------------


Edits by Jaclyn Beck
--------------------

* Fixed several things that caused the code to crash in automatic mode 
* Thresholding is now done on the 3D image as a whole, rathern than per slice
* Changed connecting two points in a skeleton from brute force search using convn, to using built-in 'bwdistgeodesic' function. This gives the same result but runs much faster. 
* New nucleus threshold: In interactive mode there is now an additional screen where you select a threshold/noise level at which only cell nuclei are visible. This feeds into the new separation algorithm. 
* Connected regions are assigned to any nuclei they overlap. Regions with no overlapping nuclei are discarded.
* Rather than segmenting "too-large" regions based on erosion, only regions that overlap more than one nucleus are segmented.
* Segmenting is no longer done by clustering. It's done by geodesic distance from each nucleus.
* Segmentation is now done BEFORE cell size selection. Cells with one nucleus that are still over/under the size limit are discarded. 
* Cell centroids are now calculated as the centroid of the nucleus, not the whole cell. 
* Changed file output from excel to CSV files
* Split data files up into formats that were easy to read in by processing code.
* Added error checking in a few places

* GUI changes:
	* Displayed images in most places are now z-projections of the 3D data rather than one slice of it, or a 2D rendering. This makes it easier to determine thresholds.
	* For faster plotting, cells are no longer outlined in black for display.
	* On the threshold screens, individual objects now have different shades so you can tell if the threshold is separating objects. 
	* Threshold screens open with some default values already set. 
	* Cell size cutoff GUIs now show all cells post-segmentation instead of all cells

