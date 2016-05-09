function [ roilocs, units ] = extract_roi_locations( locations, eye )

% 1st column of locations contains the x directions (N, T)
% 2nd column of lcoations contains the y directions (I, S)

roilocs = zeros(size(locations));

for i=1:length(locations{1})

    xlocstr = locations{1}{i};
    ylocstr = locations{2}{i};
    
    if strcmp(xlocstr,'Center')
        roilocs(i,1) = 0;
        roilocs(i,2) = 0;
    else

        % Temporal is always negative, Nasal is always positive (unless its
        % left eye, then we'll flip them in montage_roi_selection)
%         [xlocs, xdirection] = strsplit( xlocstr, {'N','T'});  % Removed
%         for MATLAB 2011
%         [ylocs, ydirection] = strsplit( ylocstr, {'S','I'});
                
        xind = strfind(xlocstr,'N');
        if isempty(xind)
            xind = strfind(xlocstr,'T');
            if ~isempty(xind)
                xlocs = {xlocstr(1:xind-1)};
                xdirection = {xlocstr(xind:end)}; 
            else
                xlocs = {''};
                xdirection = {};
            end
        else
            xlocs = {xlocstr(1:xind-1)};
            xdirection = {xlocstr(xind:end)};
        end
        
        yind = strfind(ylocstr,'S');
        if isempty(yind)
            yind = strfind(ylocstr,'I');
            if ~isempty(yind)
                ylocs = {ylocstr(1:yind-1)};
                ydirection = {ylocstr(yind:end)};
            else
                ylocs = {''};
                ydirection = {};
            end                
        else
            ylocs = {ylocstr(1:yind-1)};
            ydirection = {ylocstr(yind:end)};
        end

        xlocs = xlocs(~cellfun('isempty',xlocs));

        if isempty(xlocs)            
            roilocs(i,1) = 0;
        else
            xlocs = strtrim(xlocs{1});
            unitloc = strfind(xlocs,'um');
            if ~isempty(unitloc)
                units = xlocs(unitloc:end);
                roilocs(i,1) = str2double(xlocs(1:unitloc-1));
            end
            unitloc = strfind(xlocs,'deg');
            if ~isempty(unitloc)
                units = xlocs(unitloc:end);
                roilocs(i,1) = str2double(xlocs(1:unitloc-1));
            end
            
            if strcmp(eye,'os')
                if strcmp(xdirection,'N')
                    roilocs(i,1) = -roilocs(i,1);
                end
            elseif strcmp(eye,'od')
                if strcmp(xdirection,'T')
                    roilocs(i,1) = -roilocs(i,1);
                end                
            end
            
        end
        
        ylocs = ylocs(~cellfun('isempty',ylocs));

        if isempty(ylocs)            
            roilocs(i,2) = 0;
        else
            ylocs = strtrim(ylocs{1});
            unitloc = strfind(ylocs,'um');
            if ~isempty(unitloc)
                units = ylocs(unitloc:end);
                roilocs(i,2) = str2double(ylocs(1:unitloc-1));
            end
            unitloc = strfind(ylocs,'deg');
            if ~isempty(unitloc)
                units = ylocs(unitloc:end);
                roilocs(i,2) = str2double(ylocs(1:unitloc-1));
            end
            
            if strcmp(ydirection,'S')
                roilocs(i,2) = -roilocs(i,2);
            end 
        end
        

%         roilocs
    end

end
