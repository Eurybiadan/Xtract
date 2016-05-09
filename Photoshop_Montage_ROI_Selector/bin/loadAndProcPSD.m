function [ rsetfname bounds layernames numungrp] = loadAndProcPSD(path)
% Robert Cooper 05-23-2013
%
% Requires: Photoshop CS5 Extended, and an active connection to a running
% version of photoshop. Photoshop must be running before MATLAB starts!
%
% This function connects to a running copy of Photoshop CS5.1, and opens an
% imagetool, allowing the user to select their ROI. There is a parameter
% window associated with this tool which allows the user to modify settings
% such as scaling, number of ROIs, restriction windows, etc.
%
% First the psd is flattened and converted to an rset which is essentially
% a tiled dataset which will allow for viewing of the entire image without
% a signficant slowdown.
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

waithandle = waitbar(0,'Loading photoshop data...');

% To visualize the image, we have to load, flatten, and convert the dataset
% to rset. (1/5)
psopendoc(path);

% Select the background- if it doesn't exist, create one- otherwise, select
% it
successful = hasBackground();

if strcmp(successful, 'true')
   selectBackground();
else
   createBackground(); 
end

blackenBackground(); % Blacken the background so we don't want to stab our eyes out...
allim = psimread(path,true,true);
imwrite(allim,[path(1:end-4) '_flat.tif']);

waitbar(1/5,waithandle,'Determining layer names and bounds (reloading)...');

clear allim;

% Open the photoshop file. (2/5)
psopendoc(path);
% waitbar(2/5,waithandle,'Determining layer names and bounds...');
[w, h, resolution, name, mode, bitsperchan, aspect] = psdocinfo();

if ~strcmp(mode,'grayscale')
    warndlg('The PSD MUST be Grayscale. Please convert the file to Grayscale and reload.', 'Incorrect Color Mode!');
    rsetfname = [];
    bounds =[];
    layernames =[];
    numungrp =[];
    close(waithandle);
    return
end

% Ungroup everything, making sure to keep track of how many times we did it
% (3/5)
numungrp=0;
% numungrp = ungroupLayers();

waitbar(3/5,waithandle,'Determining layer names and bounds...');

% Get the name and bounds of every layer in the photoshop file (4/5)
layernames = getLayerNames();
bounds     = getLayerBounds();


% Rasterize the file so that we don't have anymore problems.
% rasterizePSD();

waitbar(4/5,waithandle,'Cleaning up...');
% Undo what you did, and close the document, making sure not to accept any
% changes. (5/5)
% undoOp( numungrp );
% psclosedoc(1);

waitbar(5/5,waithandle,'Done!');
pause(.5);
close(waithandle);

rsetfname = [path(1:end-4) '_flat.rset'];

% If it has already been converted, don't waste time doing it again...
% if ~exist([path(1:end-4) '_flat.rset'],'file')
    rsetfname = rsetwrite([path(1:end-4) '_flat.tif'],[path(1:end-4) '_flat.rset']);
% end

% [ roi ] = montage_roi_selection( rsetfname, bounds );

% toolhandle = imtool(rsetfname);



