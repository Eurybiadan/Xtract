# Eques
This is a repository for a variety of adaptive optics tools. I don't mind if you use the tools contained in this package, however I do ask that you credit me if you *do* use any of the tools.

The "Montage Seeder" has been rendered mostly useless by Chen et al.'s work: M. Chen, R. F. Cooper, G. K. Han, J. Gee, D. H. Brainard, and J. I. W. Morgan, "Multi-modal automatic montaging of adaptive optics retinal images," Biomedical Optics Express, Vol. 7 (12), pp. 4899-4918, 2016. The repository of our implementation is here: https://github.com/BrainardLab/AOAutomontaging

Photoshop Montage ROI Selector and ROI Seeders:

These softwares allow a user to extract regions of interest from an existing  montage or seed a montage from a set of images created in Photoshop CS5.1 or greater, and in MATLAB 2011a and greater.

**Prerequisites:**

1. An Extended edition of Photoshop CS5, CS5.1, CS6, or CS. An extended edition is basically the edition that allows plugins (If you have "3D" as an option on your toolbar, then you have the extended edition).
2. An acceptable MATLAB mex compiler installed. ( A list of some supported compilers for R2012a is here: http://www.mathworks.com/support/compilers/R2012a/win64.html ) I use Windows SDK 7.1 because it is freely downloadable and easy to install.
3. The MATLAB/Photoshop plugin correctly installed and MATLAB linked. CS5/5.1 has the plugin included in the Extended edition installation, but CS6 and CS does not. You can download the CS6 and CS plugin from Adobe's website. It also has instructions for linking MATLAB to Photoshop on the website.
