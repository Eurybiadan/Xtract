function [ retinaloc, retinaloc2] = calc_retina_loc( scale, units, distance, eye, type)
%   Robert Cooper 06-24-2013
%   This function outputs a conditioned string with the retinal location.
%   It can either put out the absolute distance from the center, or a 2
%   term value with both numbers.
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
% This function assumes (x,y) for both center and location.

if nargin < 6
   
    type = '2term';
    
end

% distance = [location(1)-center(1) location(2)-center(2)];

scaleddistance = round( (100*distance) ./ scale)/100;


% Note: char(176) is the degrees symbol
horzretinaloc = [];
vertretinaloc = [];
retinaloc = [];

if strcmp(type, '2term')
    
    % Add the pieces of the location to the screen- if it is at 0, then
    % don't include
    if strcmpi(eye,'os')
        if scaleddistance(1)>0
            horzretinaloc = [num2str(abs(scaleddistance(1)),'% 3.3g') units ' T'];
        elseif scaleddistance(1)<0
            horzretinaloc = [num2str(abs(scaleddistance(1)),'% 3.3g') units ' N'];
        end
    else
        if scaleddistance(1)>0
            horzretinaloc = [num2str(abs(scaleddistance(1)),'% 3.3g') units ' N'];
        elseif scaleddistance(1)<0
            horzretinaloc = [num2str(abs(scaleddistance(1)),'% 3.3g') units ' T'];
        end
    end
    
    if scaleddistance(2)>0
        vertretinaloc = [num2str(abs(scaleddistance(2)),'% 3.3g') units ' I'];
    elseif scaleddistance(2)<0
        vertretinaloc = [num2str(abs(scaleddistance(2)),'% 3.3g') units ' S'];
    end
    
    if isempty(horzretinaloc) && isempty(vertretinaloc)
        if nargout == 1
            retinaloc = 'Center';
        elseif nargout ==2
            retinaloc  = {'Center'};
            retinaloc2 = {'Center'};
        end
    else
        if nargout == 1
            retinaloc = [horzretinaloc ' ' vertretinaloc];
        elseif nargout ==2
            retinaloc  = {horzretinaloc};
            retinaloc2 = {vertretinaloc};
        end
    end
    
elseif strcmp(type, 'absolute')
    retinaloc = 'In construction';
else
    error('Output type not recgonized!');
    retinaloc = 'ERR';
end

end

