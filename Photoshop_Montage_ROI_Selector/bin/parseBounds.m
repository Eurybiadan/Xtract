function [ boundarray ] = parseBounds( string )
% function [ boundarray ] = parseBounds( string )
% 
% Robert Cooper 05-22-2013
% This function takes the bound string and parses it into a n x 4 array.
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

layersplit = regexp(string(1:end-1),';','split');

boundarray = zeros(length(layersplit),4);

    for i=1:length(layersplit)
%        tmp = find( 1 == ~cellfun(@isempty, regexp(layersplit{i},',','split'))); % Don't include the first split, its empty.
       boundarray(i,:) = cellfun(@str2num, regexp(layersplit{i},',','split') );
    end

end

