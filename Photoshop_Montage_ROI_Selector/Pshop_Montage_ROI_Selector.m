%     Photoshop Montage ROI Selector.
%     This software allows a user to extract regions of interest from a
%     montage created in Photoshop CS5.1 or greater, and in MATLAB 2012a
%     and greater.
% 
%     Copyright (C) 2014  Robert F Cooper
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% 
%                           ***** Prerequisites: *****
%       1) An Extended edition of Photoshop CS5, CS5.1, or CS6. An extended
%          edition is basically the edition that allows plugins (If you 
%          have "3D" as an option on your toolbar, then you have the 
%          extended edition).
% 
%       2) An acceptable MATLAB mex compiler installed. ( A list of some 
%          supported compilers for R2012a is here: 
%          http://www.mathworks.com/support/compilers/R2012a/win64.html )
%          I use Windows SDK 7.1 because it is freely downloadable and easy
%          to install.
% 
%       3) The MATLAB/Photoshop plugin correctly installed and MATLAB
%          linked. CS5/5.1 has the plugin included in the Extended edition
%          installation, but CS6 does not. You can download the CS6 plugin
%          from Adobe's website.It also has instructions for linking MATLAB
%          to Photoshop on the website.


clear
close all force
% Find what path this script is running from
thisPath=which('Pshop_Montage_ROI_Selector.m');

% Get the absolute path
basePath=thisPath(1:end-28);

% Add the bin directory to run the remainder of the files
path(path,fullfile(basePath,'bin'))

param = paramPane();

if param.axial ~= 0
    roiout = montage_roi_selection(param);
end

