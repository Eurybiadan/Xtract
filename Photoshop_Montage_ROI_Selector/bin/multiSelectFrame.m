function [ roi loc selected_logic ] = multiSelectFrame( images, titles, roititle, roibounds, roisizefcn, layerbounds,...
                                                 scale, unit, centerpoint, eye)
% FUNCTION [ selectionid ] = multiSelectFrame( images, titles )
% Robert Cooper 07-16-2013
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
%       @images: This is a cell array of 2d arrays which will be displayed
%       in the subplot.
%
%       @titles: This is a cell array containing matched titles (via index)
%                to the images
%
%   Outputs:
%       @roi: This is the roi that the user selected.
%
%
selectionid = 1;
shownid = 1;
imfigs = [];
selected = [];
selected_logic = [];
ver = version('-release');
% Reshape this so it that is in row/col format, with the bounds x/y in the
% columns and each layer is a row
layerbounds = reshape(layerbounds,[size(layerbounds,2) size(layerbounds,3)])';

numim = length(images);

% Spawn the subplot frame
selectFrame = figure;
set(selectFrame, 'HitTest','off');
set(selectFrame, 'CloseRequestFcn',@xnext);
set(selectFrame,'KeyPressFcn',@keypress);
set(selectFrame, 'Name', ['Selecting best layer for ROI location ' get(roititle(2),'String') ': ' get(roititle(1),'String')] );


% Pick the dimensions based on the number of images-
% THIS IS HACKY- switch to modulus, or something?
if numim < 3 % 2x1
    numrows = 1;
    numcols = 2;    
elseif numim < 5 % 2x2
    numrows = 2;
    numcols = 2;    
elseif numim < 7 % 2x3    
    numrows = 2;
    numcols = 3;    
elseif numim < 10 % 3x3    
    numrows = 3;
    numcols = 3;    
elseif numim < 13 % 3x4    
    numrows = 3;
    numcols = 4;    
elseif numim < 17 % 4x4    
    numrows = 4;
    numcols = 4;    
elseif numim < 21 % 5x4    
    numrows = 5;
    numcols = 4;    
elseif numim < 26 % 5x5    
    numrows = 5;
    numcols = 5;
elseif numim < 31 % 6x5    
    numrows = 6;
    numcols = 5;
elseif numim < 36 % 6x6
    
    numrows = 6;
    numcols = 6;    
end


for i=0 : numrows-1
    for j=1 : numcols
        
        ind = i*numcols + j;
        
        if ind <= numim
            imfigs(ind) = subplot(numrows, numcols, ind);
            im = imshow( images{ ind } );

            set(im,'HitTest','on');
            set(im,'ButtonDownFcn',@butdwn); % Set the imtool to being button sensitive
    %         set(imfigs(ind),'ButtonUpFcn',@dragup);

            title( strrep(titles{ind}, '_', '\_') );
        end
        
    end
end

selected = -1.*ones(size(imfigs,2),1);

% Draw the first rectangle on the selection window
subplot(numrows, numcols, 1);
selected(1) = rectangle('Position',[1 1 size(images{1},2)-1 size(images{1},1)-1],'LineWidth',4,'EdgeColor','r');


roirects = zeros(size(imfigs,2),1);

initroisize = roibounds(3,:)-roibounds(1,:);
% Draw all of the ROIs in their initial positions - the roi sizes will
% always be the same (always the same distance from the fovea) so just use
% the first bounds as a size reference.
for i=1:size(imfigs,2)
       
    tmpbounds = [roibounds(1,1)-layerbounds(i,1) roibounds(1,2)-layerbounds(i,2)];    
    roirects(i) = rectangle('Parent',imfigs(i),'Position',[tmpbounds(1) tmpbounds(2) initroisize(1) initroisize(2)],'LineWidth',2,'EdgeColor','r','HitTest','off');
    
end

% Display all the images- grab handles of the rectangle and image before
% starting
[tweakhand roifunc updatefunc] = roiTweakFrame(@xnext, @setROIpos, images{1}, titles{1}, roibounds, roisizefcn, layerbounds(1,:),scale,unit, centerpoint, eye);

imagehand   = findall(tweakhand,'type','image');
roihand     = findall(tweakhand,'type','patch');
roitexthand = findall(tweakhand,'type','text');
% Just create the default tag once- it'll be the same every time the user
% switches layers

% Find out how much screen space remains, and take all of it.
screensize = get(0,'ScreenSize');
screensize = [screensize(4) screensize(3)]; % rearrange so it is row/col

tweakpos = get(tweakhand,'Position');

pickpos = [1, round((screensize(1)-tweakpos(4))/2) , screensize(2)-tweakpos(3), tweakpos(4) ];

if all(sign(pickpos) > 0)
    set(selectFrame,'Position',pickpos);
else
    pickpos = [1 tweakpos(4) tweakpos(3) tweakpos(4)];
    set(selectFrame,'Position',pickpos);
end

figure(selectFrame);
% Create the roiTweakFrame, grab its handle
uiwait(gcf);

    function butdwn(src, evt)
        
        prevind = selectionid;

        % Get the parent axes of the image selected
        pickedax = get(src,'Parent');
        selectionid = find(imfigs == pickedax);
        
        modifiers = get(selectFrame,'currentModifier');
        if isempty(modifiers) % If modified is empty, then maybe it was clicked from the other figure
            modifiers = {get(selectFrame,'SelectionType')};
        end

        width  = max(get(src,'XData'));
        height = max(get(src,'YData'));
                
            switch(modifiers{1})        
                case {'shift', 'extend'}% For multi-selections
                    
                    if ishandle(selected(selectionid))
                        delete( selected(selectionid) )
                    else
                    
                        selsize = size(images{selectionid});
                        roipos = get(roirects(selectionid),'Position');

                        imbounds(1,:) = [1 1]; % Top Left
                        imbounds(2,:) = [selsize(2) 1]; % Top Right
                        imbounds(3,:) = [selsize(2) selsize(1)]; % Bottom Right
                        imbounds(4,:) = [1 selsize(1)]; % Bottom Left
                        imbounds(5,:) = [1 1]; % Top Left (Finish)

                        rbounds(1,:) = [roipos(1) roipos(2)]; % Top Left
                        rbounds(2,:) = [roipos(1)+roipos(3) roipos(2)]; % Top Right
                        rbounds(3,:) = [roipos(1)+roipos(3) roipos(2)+roipos(3)]; % Bottom Right
                        rbounds(4,:) = [roipos(1) roipos(2)+roipos(3)]; % Bottom Left 

                        if all( inpolygon( rbounds(:,1), rbounds(:,2), imbounds(:,1), imbounds(:,2) ) )                   
                            % Create the red rectangle around the selection
                            selected(selectionid) = rectangle('Position',[1 1 width-1 height-1],'LineWidth',4,'EdgeColor','r');
                        end
                    end
                case 'normal'
                    
                    if any(ishandle(selected))
                        delete( selected(ishandle(selected)) )
                    end
                    
                    % Set the id of the image that is being shown
                    shownid = selectionid;
                    
                    selsize = size(images{shownid});
                    roipos = get(roirects(shownid),'Position');
                    
                    imbounds(1,:) = [1 1]; % Top Left
                    imbounds(2,:) = [selsize(2) 1]; % Top Right
                    imbounds(3,:) = [selsize(2) selsize(1)]; % Bottom Right
                    imbounds(4,:) = [1 selsize(1)]; % Bottom Left
                    imbounds(5,:) = [1 1]; % Top Left (Finish)

                    rbounds(1,:) = [roipos(1) roipos(2)]; % Top Left
                    rbounds(2,:) = [roipos(1)+roipos(3) roipos(2)]; % Top Right
                    rbounds(3,:) = [roipos(1)+roipos(3) roipos(2)+roipos(3)]; % Bottom Right
                    rbounds(4,:) = [roipos(1) roipos(2)+roipos(3)]; % Bottom Left 
                    
                    if all( inpolygon( rbounds(:,1), rbounds(:,2), imbounds(:,1), imbounds(:,2) ) )                   
                        % Create the red rectangle around the selection
                        selected(selectionid) = rectangle('Position',[1 1 width-1 height-1],'LineWidth',4,'EdgeColor','r');
                    end

                    disp(['Selected: ' titles{selectionid} ]);

                    % Grab the title bar, change its value
                    set(tweakhand, 'Name', ['Editing ' titles{selectionid} '''s ROI: Press Enter When Finished.']  );

                    % Get the scroll panel, and replace the image with the newly
                    % selected one.
                    imscrpane = get(tweakhand,'Children');
                    api = iptgetapi(imscrpane);
                    api.replaceImage(images{selectionid});

                    %Update the ROI position in the tweakPane
                    set(roihand,'XData',rbounds(:,1),'YData',rbounds(:,2));
                    set(roitexthand,'Position', rbounds(2,:)+10);
                    % Update the layer bounds
                    updatefunc( [layerbounds(selectionid,1) layerbounds(selectionid,2)]);
            end            
            drawnow expose;      
    end

    function setROIpos( newpos )
        
        % Update the ROIs
        if ~isempty(newpos)
%             if str2num(ver(1:4)) <= 2014 && strcmp(ver(end), 'a')
%                 set(roirects(:),'EraseMode','xor');
%             end
            
            % Calculate the offset from the shown image to the other images
            layeroffset = ones(size(roirects))*[layerbounds(shownid,1) layerbounds(shownid,2)]-layerbounds;
            
%             roisize = (roihalfsize*2).*ones(size(layeroffset));
%             newroisize = roisizefcn(norm(newpos-layerbounds(1,:),2));

            for m=1:size(layeroffset,1)
                set(roirects(m),'Position',[newpos(1)+layeroffset(m,1) newpos(2)+layeroffset(m,2) newpos(3) newpos(4)]);            
            end
        else % This will be empty when we finish moving
            
            roipos = get(roirects,'Position');
            
            if ~iscell(roipos)               
                roipos = {roipos};
            end
            
            for m=1:size( roipos, 1 )
                if ishandle( selected(m) ) % If this roi is selected (if there is a rect around it) then verify the box is still in it!
                    selsize = size( images{m} );

                    imbounds(1,:) = [1 1]; % Top Left
                    imbounds(2,:) = [selsize(2) 1]; % Top Right
                    imbounds(3,:) = [selsize(2) selsize(1)]; % Bottom Right
                    imbounds(4,:) = [1 selsize(1)]; % Bottom Left
                    imbounds(5,:) = [1 1]; % Top Left (Finish)

                    rbounds(1,:) = [roipos{m}(1) roipos{m}(2)]; % Top Left
                    rbounds(2,:) = [roipos{m}(1)+roipos{m}(3) roipos{m}(2)]; % Top Right
                    rbounds(3,:) = [roipos{m}(1)+roipos{m}(3) roipos{m}(2)+roipos{m}(3)]; % Bottom Right
                    rbounds(4,:) = [roipos{m}(1) roipos{m}(2)+roipos{m}(3)]; % Bottom Left                    
                    
                    if ~all( inpolygon( rbounds(:,1), rbounds(:,2), imbounds(:,1), imbounds(:,2) ) )
                        delete( selected(m) )
                    end
                end
            end
%             if str2num(ver(1:4)) <= 2014 && strcmp(ver(end), 'a')
%                 set(roirects(:),'EraseMode','normal');
%             end
        end
        
    end

    function xnext(roiin, locin)
        
        if isempty(roiin) && isempty(locin)
            [r, loc ] = roifunc();
        else
%             roi = roiin;
            loc = locin;
        end
        
        % Get the ROIs from all of the selected images
        selected_logic = ishandle( selected );        
        
        roi = [];
        
        roipos = get(roirects(selected_logic),'Position');
        
        if ~iscell(roipos)        
            roipos = {roipos};
        end
        if ~isempty(roipos{1})
            selectedim = images(selected_logic)';
            roi = cell(size(roipos,1),1);
        
            for m=1:size(roipos,1)

                roi{m} = selectedim{m}(floor(roipos{m}(2)):ceil(roipos{m}(2)+roipos{m}(3)-1),...
                                           floor(roipos{m}(1)):ceil(roipos{m}(1)+roipos{m}(3)-1) );

            end
            close(tweakhand);

            delete(selectFrame);
        else
            choice = questdlg('There is no image selected for extraction! Continue?','No ROI image selected!', 'Ignore and Continue','No','No');
            switch choice
                case 'Ignore and Continue'
                    roi = {};
                    close(tweakhand);
                    delete(selectFrame);
                case'No'
            end
        end
    end

    function keypress(src,evt)
        
        if strcmp(get(gcf,'CurrentCharacter'),char(13)) % Char 13 is enter

            xnext([],[]);
            
        end
    end
end

