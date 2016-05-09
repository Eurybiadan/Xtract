function [ parent kids ] = getparent( path, height,returntype)
% Robert Cooper 08-29-11
%   This function returns the parents of a path, up to a height designated
%   by height. It then returns the parent directories in the parent
%   variable and the children in the kids var.
% 
% Input of the return type is useful when trying to get only the parent
% directory. Use 'short' to get only the name of the parent directory of
% height h, or use 'full' to get the entirety of the parent path.
% If the height is undefined it will be assumed to be 1.
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

if ~exist('height','var') % If they don't input height
    height=1;
    returntype='full';
elseif ischar(height)
    returntype=height;
	height=1;
end


if strcmp(returntype,'short')
    indices=regexp(path,filesep);
    
    if height==0
        parent=path(indices(end)+1:end );
    elseif (height>0) && (height<length(indices))
        parent=path(indices(end-height)+1:indices(end-(height-1))-1 );
    else
        error('Incorrect height value- number must be positive and less than the length of the path');
    end
    
    kids='';
elseif strcmp(returntype,'full')
    indices=regexp(path,filesep);
    
    if height==0 % Included for consistency... no idea why you'd want this though.
        parent=path;
        kids='';
    elseif (height>0) && (height<length(indices))
        parent=path(1:indices(end-(height-1))-1 );
        kids=path(indices(end-(height-1))+1:end );
    else
        error('Incorrect height value- number must be positive and less than the length of the path');
    end
           
end



end

