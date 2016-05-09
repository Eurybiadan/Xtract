function [ ] = undoOp( numundo )
% function [ ] = undoOp( numundo )
% Robert Cooper 05-22-2013
%
% Requires: Photoshop CS5 Extended, and an active connection to a running
% version of photoshop. Photoshop must be running before MATLAB starts!
%
% This function connects to a running copy of Photoshop CS5.1, and undos
% the last x number of operations that were performed, with the idea that
% whatever is done to acquire information, it can be rolled back.
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

    undo = [ 'for(var i=0;i<' num2str(numundo) ';i++){'...
             '    var desc = new ActionDescriptor();'...
             '    var ref = new ActionReference();'...
             '    ref.putEnumerated( charIDToTypeID( "HstS" ), charIDToTypeID( "Ordn" ), charIDToTypeID( "Prvs" )  );'...
             '    desc.putReference( charIDToTypeID( "null" ), ref );'...
             '    try {'...
             '        executeAction( charIDToTypeID( "slct" ), desc, DialogModes.NO );'...
             '    } catch(e) { }'...
             '}'];

    psjavascript(undo);
     
end

