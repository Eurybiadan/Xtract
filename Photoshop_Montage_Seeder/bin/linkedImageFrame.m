function [ update, selected, multihand ] = linkedImageFrame( images, titles )
% FUNCTION [ selectionid ] = linkedImageFrame( images, titles )
% Robert Cooper 10-15-2014
%   This frame allows a user to select a single image from a group of
%   images.
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
%
%   Inputs:
%       @images: This is a cell array of 3d arrays which will be displayed
%       in the subplots.
%
%       @titles: This is a cell array containing matched titles (via index)
%                to the images
%
%   Outputs:
%       @selected: These are the images that will be transferred
%
%

multihand = figure('name',['Press Enter To Include, or Tab to exclude.']);
update = @updateContents;
set(multihand,'KeyPressFcn',@keypress);
set(multihand,'HitTest','off');



%% Find the image with the largest bounds; scale the others off of it.
imsizes = cell2mat(cellfun(@size,images,'UniformOutput',0));

[maxval ind] = max(imsizes(:,2));

sliderwidth=0.02;
ratios = (imsizes(:,2)./maxval);


for i=1:length(images)    
    
    subh(i) = subplot(length(images),1,i); 
    imfigs(i) = imagesc(images{i}); colormap gray; axis image; axis off; title(titles{i},'Interpreter', 'none')
    imrect(i) = rectangle('Position',[1 1 size(images{i},2)-1 size(images{i},1)-1],'LineWidth',4,'EdgeColor','w');
    set(imfigs(i),'HitTest','on');
    set(imfigs(i),'ButtonDownFcn',@butdwn);
    
end


top = length(images)*.5;

plotloc = 0:.5:top;
plotloc = plotloc(1:end-1);
if length(plotloc) > 1
    plotloc = plotloc-plotloc(end-1); % Set the viewable plots to the last pair
end
% Set up the positions of each of the plots
for i=1:length(images)    
    set(subh(i),'Units','normalized','Position',[ sliderwidth+(1-ratios(i))/2 plotloc(i) ratios(i)-sliderwidth .45]);
end

numims = length(images);

if length(plotloc) > 1
    sliderui = uicontrol(multihand, 'Style', 'slider','Min',1,'Max', numims,'Value', numims,'SliderStep',[ 1/(numims-1) 1/(numims-1) ],'Units','normalized','Position',[1-sliderwidth 0 sliderwidth 1 ], 'Callback',{@sliderMotion});
end
%% Create the image viewer
selectionid = length(images);
selected = -ones(length(images),1);
set(imrect(selectionid),'EdgeColor','y');

[ im_scr_hand ] = linkedImageViewFrame(images{end}, titles{end}, @acceptlayer);

uiwait(multihand);


    % Run this whenever you want tto update the contents of the figure
    function [selection]=updateContents(newimages, newtitles)
        % Empty out the figure
        clf(multihand);

        images = newimages;
        titles = newtitles;
        
        imsizes = cell2mat(cellfun(@size,images,'UniformOutput',0));

        [maxval ind] = max(imsizes(:,2));

        sliderwidth=0.02;
        ratios = (imsizes(:,2)./maxval);

        figure(multihand); % Make that handle current, for the subplots.
        for m=1:length(images)    
        
            subh(m) = subplot(length(images),1,m); 
            imfigs(m) = imagesc(images{m}); colormap gray; axis image; axis off; title(titles{m},'Interpreter', 'none');
            imrect(m) = rectangle('Position',[1 1 size(images{m},2)-1 size(images{m},1)-1],'LineWidth',4,'EdgeColor','w');
            set(imfigs(m),'HitTest','on');
            set(imfigs(m),'ButtonDownFcn',@butdwn);

        end
       
        top = length(images)*.5;

        plotloc = 0:.5:top;
        plotloc = plotloc(1:end-1);
        if length(plotloc) > 1
            plotloc = plotloc-plotloc(end-1); % Set the viewable plots to the last pair
        end

        % Set up the positions of each of the plots
        for m=1:length(images)
            set(subh(m),'Units','normalized','Position',[ sliderwidth+(1-ratios(m))/2 plotloc(m) ratios(m)-sliderwidth .45]);
        end
        numims = length(images);

        if length(plotloc) > 1
            sliderui = uicontrol(multihand, 'Style', 'slider','Min',1,'Max', numims,'Value', numims,'SliderStep',[ 1/(numims-1) 1/(numims-1) ],'Units','normalized','Position',[1-sliderwidth 0 sliderwidth 1 ], 'Callback',{@sliderMotion});
        end
%         sliderui = uicontrol(multihand, 'Style', 'slider','Min',1,'Max', length(images),'Value', length(images),'Units','SliderStep',[1/length(images) 1/length(images)],'normalized','Position',[1-sliderwidth 0 sliderwidth 1 ], 'Callback',{@sliderMotion});
        selectionid = length(images);
        selected = -ones(length(images),1);
        set(imrect(selectionid),'EdgeColor','y');
        
        im_hand_api=iptgetapi(im_scr_hand);

        im_hand_api.replaceImage(images{selectionid});
        im_hand_api.setMagnification(im_hand_api.findFitMag());
        
        uiwait(multihand);
        selection = selected;
    end

    function keypress(src, evt)
        
%         get(gcf,'CurrentCharacter')
        
        if strcmp(get(gcf,'CurrentCharacter'),char(13)) % Character 13 is the enter character...
            acceptlayer()
        elseif strcmp(get(gcf,'CurrentCharacter'),'r') % r for reject
            rejectlayer()
        elseif strcmp(evt.Key,'uparrow')
            if (selectionid+1) <= length(images)
                butdwn([], selectionid+1)
            end
        elseif strcmp(evt.Key,'downarrow')
            if (selectionid-1) > 0
                butdwn([], selectionid-1)
            end
        end
        
    end

    function acceptlayer()
               
        set(imrect(selectionid), 'EdgeColor','g')
        selected(selectionid) = 1;
        
        if (selectionid-1) > 0
            % Move downward (if we can)
            selectionid = selectionid-1;
            plotloc = plotloc - plotloc(selectionid);
            
            
            set(sliderui,'Value', selectionid )
        end
        
        plotloc = plotloc - plotloc(selectionid);
        for subind=1:length(images)
            pos = get(subh(subind),'Position');
            %Update the image positions
            pos(2) = plotloc(subind);
            set(subh(subind),'Position',pos);

            %If it isn't selected in some form (rejected/accepted), then
            % paint it white
            if selected(subind) == -1
                set(imrect(subind),'EdgeColor','w');
            elseif selected(subind) == 1
                set(imrect(subind),'EdgeColor','g');
            elseif selected(subind) == 0
                set(imrect(subind),'EdgeColor','r');
            end
        end
        %Mark the selected iamges yellow
        set(imrect(selectionid),'EdgeColor','y');

        im_hand_api=iptgetapi(im_scr_hand);

        im_hand_api.replaceImage(images{selectionid});
        im_hand_api.setMagnification(im_hand_api.findFitMag());
        
        if( all(selected > -1) )            
            uiresume;
        end
    end

    function rejectlayer()
                
        set(imrect(selectionid), 'EdgeColor','r')        
        selected(selectionid) = 0;

        if (selectionid-1) > 0
            % Move downward (if we can)
            selectionid = selectionid-1;
            plotloc = plotloc - plotloc(selectionid);
            
            set(sliderui,'Value', selectionid )
        end
        
        for subind=1:length(images)
            pos = get(subh(subind),'Position');
            %Update the image positions
            pos(2) = plotloc(subind);
            set(subh(subind),'Position',pos);

            %If it isn't selected in some form (rejected/accepted), then
            % paint it white
            if selected(subind) == -1
                set(imrect(subind),'EdgeColor','w');
            elseif selected(subind) == 1
                set(imrect(subind),'EdgeColor','g');
            elseif selected(subind) == 0
                set(imrect(subind),'EdgeColor','r');
            end
        end
        %Mark the selected iamges yellow
        set(imrect(selectionid),'EdgeColor','y');


        im_hand_api=iptgetapi(im_scr_hand);

        im_hand_api.replaceImage(images{selectionid});
        im_hand_api.setMagnification(im_hand_api.findFitMag());
            
        if( all(selected > -1) )            
            uiresume;
        end
    end

    function butdwn(src, evt)
       
        if ~isempty(src)
            selectionid = find(imfigs == src);
        else
            selectionid = evt;
        end

        % Update the figure positions
        plotloc = plotloc - plotloc(selectionid) +.25;
        for subind=1:length(images)
            pos = get(subh(subind),'Position');
            
            pos(2) = plotloc(subind);

            set(subh(subind),'Position',pos);
            %If it isn't selected in some form (rejected/accepted), then
            % paint it white
            if selected(subind) == -1
                set(imrect(subind),'EdgeColor','w');
            elseif selected(subind) == 1
                set(imrect(subind),'EdgeColor','g');
            elseif selected(subind) == 0
                set(imrect(subind),'EdgeColor','r');
            end
        end
        
        set(imrect(selectionid),'EdgeColor','y');
%         set(sliderui,'Min',plotloc(1),'Max',plotloc(end))
        set(sliderui,'Value', selectionid )
        
        im_hand_api=iptgetapi(im_scr_hand);
        
        im_hand_api.replaceImage(images{selectionid});
        im_hand_api.setMagnification(im_hand_api.findFitMag());
        
    end

    function sliderMotion(src, evt)
       
        neworigin = get(src,'Value');

        neworigin = round(neworigin);
        
        % Update the figure positions
        plotloc = plotloc - plotloc(neworigin) +.25;
        for subind=1:length(images)
            pos = get(subh(subind),'Position');
            
            pos(2) = plotloc(subind);

            set(subh(subind),'Position',pos);
        end
        
        set(sliderui,'Value', neworigin )
    end
end