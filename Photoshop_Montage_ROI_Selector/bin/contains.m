function [ contained ] = contains( bounds, point )
% Robert Cooper 05-22-2013
%   %   
%   This function is designed to simply determine if the point is contained
%   (less than or equal to, or greater than or equal to) within a specified
%   region.
%   The bounds are assumed to be in:
%   [top left column, top left row, bottom right column, bottom right row]
%   format.
%   The point is assumed to be in (row, column) format.
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

    if (bounds(1) <= point(2)) && (bounds(2) <= point(1)) && ...
       (bounds(3) >= point(2)) && (bounds(4) >= point(1))

        contained = 1;
    else
        contained = 0;

    end

end

