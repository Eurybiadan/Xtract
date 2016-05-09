function [ handle ] = create_roi_size_fcn( a, b, minsize, maxsize, mindist, maxdist )
% Robert Cooper 12-8-14
%   This is a factory constructor for the roi function, that we'll use to
%   determine the size of an roi given a pixel distance.

handle = @roi_fcn;
    function [roisize] = roi_fcn(d)
        roisize = zeros(size(d));
        
        % Calculate the expected values
        roisize = a.*d.^b;
        % Change the values outside the min/max based on our initalized
        % values
        roisize(d < mindist) = minsize;        
        roisize(d > maxdist) = maxsize;
    end
end

