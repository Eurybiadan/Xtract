function [ im_scr_hand ] = linkedImageViewFrame(allim, imagename, acceptlayer)
% FUNCTION [ ] = linkedImageViewFrame(allim, imagename, acceptlayer)
% 
%   Robert F Cooper
%   This frame is designed to allow a user to view confocal, split
%   detector, and average images simultaneously to determine their utility
%   in a montage.
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
    

    
    % Set up function handles
    button_detect = @keypress;
    x_out_detect = @xoff;
    
    % Set up imscrollpane parameters, spawn imscrollpane
    im_scr_hand=figure('name',['Viewing ' imagename ': Press Enter To Include, or Tab to exclude.']);
    im_scr_hand=imscrollpanel(im_scr_hand,imshow(allim,'Border','tight'));

    
%     imcontrast(im_scr_hand);
   
    
    % Grab the pointer to the frame we spawned, store its location
    top_pane=get(im_scr_hand, 'Parent');
    set(top_pane,'ResizeFcn', @resizeFcn);


    set(top_pane,'KeyPressFcn',button_detect);
    set(top_pane,'CloseRequestFcn',x_out_detect);

    
    im_hand_api=iptgetapi(im_scr_hand);  % Grab an api so we can modify the scrollpane  
    zoom = im_hand_api.findFitMag();
    im_hand_api.setMagnification(zoom); % Set default api magnification to 100%

    % If we're increasing the size by dragging, fill the window with our image.
    function resizeFcn(src, evt)
        if im_hand_api.findFitMag() > zoom
            im_hand_api.setMagnification(im_hand_api.findFitMag());
        end
    end

    function keypress(src,evnt)

        if strcmp(get(gcf,'CurrentCharacter'),char(13)) % Character 13 is the enter character...

            acceptlayer()
            
        elseif strcmp(get(gcf,'CurrentCharacter'),'-') % To Zoom out
            
            zoom = im_hand_api.getMagnification()/2;

            disp(['Zooming to:' num2str(zoom)]);
            % Refresh image and coordinates
            im_hand_api.setMagnification(zoom);
            
        elseif strcmp(get(gcf,'CurrentCharacter'),'+') %  To Zoom in

            zoom = im_hand_api.getMagnification()*2;

            disp(['Zooming to:' num2str(zoom)]);
            % Refresh image and coordinates
            im_hand_api.setMagnification(zoom);
        
        elseif strcmp(get(gcf,'CurrentCharacter'),char(27))
            
            % Send 0, use as signal to kill program...            
            disp('You hit escape!');
            close(gcf);
            
        end
    end

    % @Override: This function is designed to run if someone presses "x" on the window
    % instead of pressing enter.
    function xoff(src,evnt)
        
        %% Matlab default code
        if isempty(gcbf)
           if length(dbstack) == 1
              warning(['MATLAB:closereq'...
              'Calling closereq from the command line is now obsolete.'...
                     'use close instead']);
           end
           close force
        else
           delete(gcbf);
        end
        
    end

end