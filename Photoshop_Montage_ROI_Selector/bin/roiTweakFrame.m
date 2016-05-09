function [ panehand roifunc updatefunc] = roiTweakFrame(roiout, setROIpos, layerim, name, roibounds, roisizefcn, layerbounds, scale, unit, centerpoint, eye)
% FUNCTION [ panehand roifunc ] = roiTweakFrame(roiout, layerim, name, roibounds,roihalfsize, layerbounds, scale, centerpoint, eye)
% 
%   Robert F Cooper
%   This frame is designed to allow a user to tweak the location of an ROI
%   within a given image. Is intimately coupled with multiSelectFrame, as
%   multiSelectFrame is responsible for giving it the image and ROI that it
%   displays.
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

    roi = 0;
    center = centerpoint;
    selected_rect = 0;
    mousedown = 0;
    cellimage = layerim;
    imagesize = size(layerim);
    zoomlevel=6;
    zoomnum=[ 5 10 25 50 100 150 200 300 400 800];

    % Set up function handles
    fh_cb = @removepress; % Create function handle for remove press detection
    fh_ac = @addpress; % Create function for cell addition
    button_detect = @keypress;
    x_out_detect = @xoff;
    
    % Set up imscrollpane parameters, spawn imscrollpane
    im_scr_hand=figure('name',['Editing ' name '''s ROI: Press Enter When Finished.'],'MenuBar','none','Toolbar','none');
    im_scr_hand=imscrollpanel(im_scr_hand,imshow(cellimage));
    im_hand = findall(im_scr_hand,'type','image');
    imcontrast(im_scr_hand);
   
    
    % Grab the pointer to the frame we spawned, store its location
    top_pane=get(im_scr_hand, 'Parent');
%     main_im=findall(im_hand,'type','image');
%     set(main_im,'ButtonDownFcn',fh_ac); % Set the image to being button sensitive
    iptPointerManager(top_pane, 'disable'); % MUST do this, or the contrast cursor will not go away...
    
    % Set figure parameters
    tmp=get(top_pane,'Position');
    
    % Check to see if the image is bigger than the screen- if it is larger
    % than the screen, then shrink it by a zoomsize factor until it fits-
    % then center it in the middle of the screen, and display.
    screensize = get(0,'ScreenSize');
    screensize = [screensize(4) screensize(3)]; % rearrange so it is row/col
    
    difference = 0;

    while any(difference < 100)
        difference = round(screensize/(zoomnum(zoomlevel)/100)) - imagesize;
        zoomlevel = zoomlevel-1;
        if zoomlevel == 0
            break;
        end
    end
    
    zoomlevel = zoomlevel+1;
    scaledimsize = imagesize*(zoomnum(zoomlevel)/100);
    
    set(top_pane,'Position',[screensize(2)-scaledimsize(2) round((screensize(1)-scaledimsize(1))/2) scaledimsize(2) scaledimsize(1)]);
    set(top_pane,'Pointer','crosshair');
    set(top_pane,'KeyPressFcn',button_detect);
    set(top_pane,'CloseRequestFcn',x_out_detect);
    set(top_pane,'WindowButtonDownFcn',@dragdwn); % Set the imtool to being button sensitive
    set(top_pane,'WindowButtonUpFcn',@dragup);
    set(top_pane,'WindowButtonMotionFcn',@dragmv);
    clear tmp;
    
    
    im_hand_api=iptgetapi(im_scr_hand);  % Grab an api so we can modify the scrollpane  
    im_hand_api.setMagnification(zoomnum(zoomlevel)/100); % Set default api magnification to 100%

    % Parse the bounds relative to the layer location
    roibounds = [roibounds(:,1)-layerbounds(1) roibounds(:,2)-layerbounds(2)];
    
    tagroihalfsize = (roibounds(3,1)-roibounds(1,1))/2;
    
    tag = calc_retina_loc( scale, unit, ...
                           [layerbounds(1)+roibounds(1,1)+tagroihalfsize-centerpoint(1) layerbounds(2)+roibounds(1,2)+tagroihalfsize-centerpoint(2) ],...
                           eye);
    
                     
    disp(['At: ' tag ' pixel loc ' num2str(roibounds(2,1)) ',' num2str(roibounds(2,2))])
    roitext  = text(roibounds(2,1)+10,roibounds(2,2)-10,tag,'Color',[1 0 0],'Parent',get(top_pane,'CurrentAxes'));
    
    roipatch =  patch([ roibounds(1,1); roibounds(2,1); roibounds(3,1); roibounds(4,1)],...
                      [ roibounds(1,2); roibounds(2,2); roibounds(3,2); roibounds(4,2)],...
                      'w','EdgeColor',[1 0 0],'Parent',get(top_pane,'CurrentAxes'),'HitTest','on',...
                      'Tag',name,'CDataMapping','direct','AlphaDataMapping','direct','FaceColor',[.1 .1 .1],'FaceAlpha',0.01,...
                      'UserData',roitext);
    
    figure(top_pane);
    
    % Give the handle of the getROI function and the figure handle so we
    % can change the image and grab the ROI
    panehand = top_pane;
    roifunc = @getROI;
    updatefunc = @updateLayerBounds;
    % Wait until the user presses enter (killing the figure) before continuing
%     uiwait(gcf);
    
    function dragdwn(src,evt)

        mousedown=1;
            
    end

    % This function is designed to handle all movement of the mouse. In all
    % cases, the mouse press is overridden if there is a zoom, pan, or
    % contrast operation occuring.
    function dragmv(src,evt)
        %tool_mv(src,evt);
       
        if( mousedown )
            % Get the position of the mouse- update the center of the roi.         
            cp = get(gca,'CurrentPoint');

            selected_rect = gco;
           
            if strcmp(get(selected_rect,'Type'),'patch')
                % Allow movement of patches               
                center = [cp(1,1) cp(1,2)];

%                 set(selected_rect,'EraseMode','xor');
%                 set(roitext,'EraseMode','xor');
                roihalfsize = roisizefcn(norm(layerbounds-centerpoint+center,2))/2;
                
                % Top Left
                xbounds(1) = center(1) - roihalfsize;
                ybounds(1) = center(2) - roihalfsize;
                % Top Right
                xbounds(2) = center(1) + roihalfsize;
                ybounds(2) = center(2) - roihalfsize;
                % Bottom Right
                xbounds(3) = center(1) + roihalfsize;
                ybounds(3) = center(2) + roihalfsize;
                % Bottom Left
                xbounds(4) = center(1) - roihalfsize;
                ybounds(4) = center(2) + roihalfsize;

                set(selected_rect,'XData',xbounds','YData',ybounds');
                set(roitext,'Position',[xbounds(2)+10 ybounds(2)-10]);

                tag = calc_retina_loc( scale, unit, [layerbounds(1)-centerpoint(1)+center(1) layerbounds(2)-centerpoint(2)+center(2)],eye);

                set(roitext,'String',tag)
                
                % Update the ROIs in the multiselect frame
                setROIpos( [xbounds(1) ybounds(1) roihalfsize*2 roihalfsize*2] )
                
                drawnow expose; 
            end
        end
    end
    
    function dragup(src,evt)
       
       if strcmp(get(selected_rect,'Type'),'patch')
%            set(selected_rect,'EraseMode','normal');
%            set(roitext,'EraseMode','normal');
           setROIpos([])
       end
       mousedown=0;
    end

    function []=updateLayerBounds(bounds)
        layerbounds = bounds;
    end

    function [rout locout] = getROI()
%     disp('START GETROI FUNCTION');
        % Make sure layerim is updated with the current image.
        layerim = get(im_hand,'CData');
        roiregionx = get(roipatch,'XData');
        roiregiony = get(roipatch,'YData');

        roiregion = uint8(round([roiregionx(1) roiregionx(2); roiregiony(1) roiregiony(4)]));
        
        roihalfsize = [roiregionx(2)-roiregionx(1) roiregiony(4)-roiregiony(1)]/2;
        
        if roiregionx(1) >= 1 && roiregionx(2) <= size(layerim,2) && ...
           roiregiony(1) >= 1 && roiregiony(4) <= size(layerim,1)
        
            rout = layerim(roiregion(2,1):roiregion(2,2),roiregion(1,1):roiregion(1,2));

            [locouthorz locoutvert] = calc_retina_loc( scale, unit, ...
                                        [layerbounds(1)-centerpoint(1)+roiregionx(1)+roihalfsize(1) layerbounds(2)-centerpoint(2)+roiregiony(1)+roihalfsize(2)],...
                                        eye);

            locout = [locouthorz locoutvert];
        else
            rout = 0;
            locout = 0;
        end
%         disp('END GETROI FUNCTION');
    end

    function keypress(src,evnt)

        if strcmp(get(gcf,'CurrentCharacter'),char(13)) % Character 13 is the enter character...

            
%             roiregionx = ceil(get(roipatch,'XData'));
%             roiregiony = ceil(get(roipatch,'YData'));
% 
%             roiregion = [roiregionx roiregiony];
%             roi = layerim(roiregiony(1):roiregiony(4),roiregionx(1):roiregionx(2));
%             close(gcf);
            [region, location] = getROI();
            roiout(region,location);
            
        elseif strcmp(get(gcf,'CurrentCharacter'),'-') % To Zoom out
            
            if zoomlevel>1
                zoomlevel=zoomlevel-1;
            else
                zoomlevel=1;
            end
            disp(['Zooming to:' num2str(zoomnum(zoomlevel))]);
            
            % Refresh image and coordinates          
            repaint();
            
        elseif strcmp(get(gcf,'CurrentCharacter'),'+') %  To Zoom in
            
            
            if zoomlevel<length(zoomnum)
                zoomlevel=zoomlevel+1;
            else
                zoomlevel=length(zoomnum);
            end
            
            disp(['Zooming to:' num2str(zoomnum(zoomlevel))]);
            % Refresh image and coordinates
            repaint(); 
        
        elseif strcmp(get(gcf,'CurrentCharacter'),char(27))
            
            % Send 0, use as signal to kill program...
            roi=[];
            disp('You hit escape!');
            close(gcf);
            
        end
    end

    % @Override: This function is designed to run if someone clicks off the window
    % instead of pressing enter.
    function xoff(src,evnt)
       %% My Handling code here...
       
       % disp('Exiting cell coordinate modification.');
%         if coordout~=0  % If it wasn't an exit condition, fill in the coordinates
%             
%             if strcmp(outputtype,'file')
%                 [fname pname]=uiputfile('*.csv');
% 
%                 dlmwrite(fullfile(pname,fname),coords,',');
%                 coordout=1;
%             elseif strcmp(outputtype,'var');
%                 coordout=coords;
%             end    
%         end
        
%         close all;
%         uiresume(gcbf);


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

    function repaint()
            % Grab old contrast values before updating; otherwise we'll
            % lose them...
            contrast=get(gca,'Clim');
            
            im_hand_api.setMagnification(zoomnum(zoomlevel)/100);
                    
            set(gca,'Clim',contrast);
         
    end

end