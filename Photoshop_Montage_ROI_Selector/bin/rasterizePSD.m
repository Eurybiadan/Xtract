function [ ] = rasterizePSD()
% function [  ] = rasterizePSD()
% 
% Robert Cooper 05-22-2013
% Requires: Photoshop CS5 Extended, and an active connection to a running
% version of photoshop. Photoshop must be running before MATLAB starts!
%
% This function connects to a running copy of Photoshop CS5.1, and
% rasterizes the entire photoshop file, so that we can properly extract the
% layers.
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

    rasterize = ['var idrasterizeAll = stringIDToTypeID( "rasterizeAll" );' ...
                   'executeAction( idrasterizeAll, undefined, DialogModes.NO ); '];


    raststring = psjavascript(rasterize);

    
end