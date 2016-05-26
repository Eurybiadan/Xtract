function [ roiout ] = montage_roi_selection( param )
% Robert Cooper 05-23-2013
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
%   READ THIS:
%   Designed in MATLAB 2012a, this function has a lot of handle calls and
%   searches to get the desired functionality. For all of the handle calls,
%   I am using pretty common MATLAB functions, so I wouldn't expect much in
%   the way of regressions, at least in the short term (3-5 years). I make
%   no promises about the state of MATLAB beyond that though...
%
%   This function contains all of the necessary functions and refreshing
%   for the imtool that we will be using to select and adjust ROIs.
%
%   This function requires a RSET dataset, or it will not work correctly!
%   As this is designed for montages, the reduced size dataset it essential
%   for good performance...
%
%   Input:
%       @param: This is a struct that contains all the parameters necessary 
%               to use this selector.
%               @eye - This variable is either od or os, depending on the
%                      eye.
%                   
%               @axial - This is the axial length of the eye, in millimeters
%
%               @pixperdeg - This is the pixels per degree of the montage
%               
%               @roiboxsize - Size of the region of interest in either
%                             pixels
%                 
%               @boxunits - Units of the roi box size (microns or degrees)
%                 
%               @roiloc - Location of all of the regions of interest in
%                         locunits - a 1 x N array
%                 
%               @locunits - Units of location (microns or degrees)
%                 
%               @SNIT - Standing for Superior, Nasal, Inferior or Temporal,
%                       this is a bit code variable- ex: 00001000 is only
%                       superior. This variable determines which direction
%                       the ROIs are created
%                 
%               @layer_bounds - The boundaries of all of the layers in the
%                               image, in pixels, a N x 4 array
%                
%               @rsetfname - The filename of the rset
%                 
%               @layer_names - The names of all of the layers. A cell array
%                 
%               @numungrp - The number of times that an operation has been
%                           done on the photoshop image. Needed to reverse 
%                           all the ungrouping


% Intialize state constants, and set the initial state.
SELECT_FOVEA   = 1;
SELECT_ROI_POS = 2;
GRAB_ROI       = 3;

state = SELECT_FOVEA;

layer_bounds = param.layer_bounds;

% roisize = deg_um_to_pixel(param.boxunits, param.roiboxsize);
roisizefunc = deg_um_to_roisize( param.boxunits, param.gen.locunits );
% roihalfsize = ceil(roisize/2);
micronsperdegree = (291*param.axial)/24;
pixelspermicron = (param.pixperdeg / micronsperdegree); 
selected_rect = 0;

% Initialize flags
mousedown = 0;
ver = version('-release');
% % Initialize function handles
% roi_mf = @movewindow;
% ect_dn = @dragdwn;
% ect_up = @dragup;
% ect_mv = @dragmv;

% Intialize handle variables
recthand  = [];

eccthand  = [];
roihand = [];
roitext = [];

% Create the imtool, set up its listeners
toolhandle = imtool(param.rsetfname);
% set(toolhandle,'RendererMode','manual');
% set(toolhandle,'renderer','opengl');
set(toolhandle,'WindowButtonDownFcn',@dragdwn); % Set the imtool to being button sensitive
set(toolhandle,'WindowButtonUpFcn',@dragup);
set(toolhandle,'KeyPressFcn',@keypress);
tool_mv = get(toolhandle,'WindowButtonMotionFcn'); % Save the original handle, so we can override its activity
set(toolhandle,'WindowButtonMotionFcn',@dragmv);

% Get the handles for the zoom and pan toolbar buttons
toolbar    = findall(toolhandle,'Type','uitoolbar');
jatoolbar   = get(get(toolbar,'JavaContainer'),'ComponentPeer'); % Java toolbar- contains the combobox...
panhandle  = findall(toolhandle,'Tag','pan toolbar button');
panprevstate = 'off';
outhandle  = findall(toolhandle,'Tag','zoom out toolbar button');
outprevstate = 'off';
inhandle   = findall(toolhandle,'Tag','zoom in toolbar button');
inprevstate = 'off';

% Add the new buttons to the toolbar.
layericon = imread('layerselecticon.png');
showlayers = uitoggletool(toolbar,'CData',layericon,'Tag','show layer boundaries button',...
                          'TooltipString','Show/hide layer boundaries','Separator','on',...
                          'Enable','on','OnCallback',@layerson, 'OffCallback',@layersoff);

% When we update the figure contents, we need to call drawnow, or it won't validate/repaint!                      
drawnow;                      

% Move the java object all the way to the right (The JPanel containing the comboBox)
contents = jatoolbar.getComponents;
jatoolbar(1).setComponentZOrder(contents(end-2),length(contents)-1)
jatoolbar(1).revalidate;


% Set up the imscrollpanel embedded in the imtool
toolscrpane = findall(toolhandle,'Tag','imscrollpanel');
scrapi = iptgetapi(toolscrpane);
scrapi.addNewLocationCallback(@movewindow);

% Create the default rectangle property 
set(toolscrpane,'DefaultRectangleEdgeColor',[0 101/255 165/255]);
set(toolscrpane,'DefaultRectangleLineStyle','-.');

get_roi_size =[];
eccent_loc = [];
eccent_center = [];
eccent_bounds = [];

initializeGuides(param.gen);

roiout = 0;
uiwait(toolhandle);


    function initializeGuides( genparam )
        
        get_roi_size = deg_um_to_roisize(param.boxunits, genparam.locunits);
        
        switch(param.gen.type)
            case 'Center'
                eccent_center = [ (max(layer_bounds(:,3))-min(layer_bounds(:,1)))/2 (max(layer_bounds(:,4))-min(layer_bounds(:,2)))/2 ]; % This is the common center of all of the circles.
                
                %Center
                eccent_loc = [0 0];
                
                % eccent_bounds(1) - x
                % eccent_bounds(2) - y
                % eccent_bounds(3) - w
                % eccent_bounds(4) - h
                roisize = get_roi_size(0);
                eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - [roisize/2 roisize/2] roisize roisize];
                
                eccthand(1) = rectangle('Parent',get(toolhandle,'CurrentAxes'),'EdgeColor','g','LineStyle','-',...
                                        'Position',[ eccent_bounds(1,1), eccent_bounds(1,2), eccent_bounds(1,3), eccent_bounds(1,4)]);
                
            case 'Strips'

                eccent_center = [ (max(layer_bounds(:,3))-min(layer_bounds(:,1)))/2 (max(layer_bounds(:,4))-min(layer_bounds(:,2)))/2 ]; % This is the common center of all of the circles.

                %Center
                eccent_loc = [0 0];
                
                if bitget(genparam.SNIT,4) % Superior
                    eccent_loc = [eccent_loc; zeros( length(genparam.northroiloc),1) -deg_um_to_pixel(genparam.locunits, genparam.northroiloc)'];
                end
                if bitget(genparam.SNIT,3) % Nasal (or Temporal, for left eye)
                    eccent_loc = [eccent_loc; deg_um_to_pixel(genparam.locunits, genparam.eastroiloc)' zeros( length(genparam.eastroiloc),1)];
                end
                if bitget(genparam.SNIT,2) % Inferior
                    eccent_loc = [eccent_loc; zeros( length(genparam.southroiloc),1) deg_um_to_pixel(genparam.locunits, genparam.southroiloc)'];
                end
                if bitget(genparam.SNIT,1) % Temporal (or Nasal, for left eye)
                    eccent_loc = [eccent_loc; -deg_um_to_pixel(genparam.locunits, genparam.westroiloc)' zeros( length(genparam.westroiloc),1)];
                end
                
                % eccent_bounds(1) - x
                % eccent_bounds(2) - y
                % eccent_bounds(3) - w
                % eccent_bounds(4) - h
%                 eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - roihalfsize roisize.*ones( size(eccent_loc,1), 2) ];
                eccent_dist = sqrt(sum(eccent_loc.*eccent_loc, 2));
                roisize = get_roi_size(eccent_dist);
                eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - [roisize/2 roisize/2] roisize roisize];

                % Create the boxes
                for e=1:length(eccent_loc)                    
                    eccthand(e) = rectangle('Parent',get(toolhandle,'CurrentAxes'),'EdgeColor','g','LineStyle','-',...
                                            'Position',[ eccent_bounds(e,1), eccent_bounds(e,2), eccent_bounds(e,3), eccent_bounds(e,4)]);
                end
                
            case 'Grid'
                
                eccent_center = [ (max(layer_bounds(:,3))-min(layer_bounds(:,1)))/2 (max(layer_bounds(:,4))-min(layer_bounds(:,2)))/2 ]; % This is the common center of all of the rectangles.
                
                gridwidth  = deg_um_to_pixel(genparam.locunits, genparam.gridwidth);
                gridheight = deg_um_to_pixel(genparam.locunits, genparam.gridheight); 
                
                samplesep_i = deg_um_to_pixel(genparam.locunits, genparam.gridrowsamp);
                samplesep_j = deg_um_to_pixel(genparam.locunits, genparam.gridcolsamp);
                
                % Create our  coordinate grid, anchored in one of the 9 locations.
                switch genparam.anchor
                    case 'TL'% Top Left
                        [ eccent_locx, eccent_locy ] = meshgrid( 0:floor(samplesep_j):gridwidth, 0:floor(samplesep_i):gridheight );
                    case 'CT'% Center Top
                        [ eccent_locx, eccent_locy ] = meshgrid( -floor(gridwidth/2):floor(samplesep_j):ceil(gridwidth/2), 0:floor(samplesep_i):gridheight );
                    case 'TR'% Top Right
                        [ eccent_locx, eccent_locy ] = meshgrid( -gridwidth:floor(samplesep_j):0, 0:floor(samplesep_i):gridheight );
                    case 'CL'% Center Left
                        [ eccent_locx, eccent_locy ] = meshgrid( 0:floor(samplesep_j):gridwidth, -floor(gridheight/2):floor(samplesep_i):ceil(gridheight/2) );
                    case 'C' % Center
                    	[ eccent_locx, eccent_locy ] = meshgrid( -floor(gridwidth/2):floor(samplesep_j):ceil(gridwidth/2), -floor(gridheight/2):floor(samplesep_i):ceil(gridheight/2) );
                    case 'CR'% Center Right
                        [ eccent_locx, eccent_locy ] = meshgrid( -gridwidth:floor(samplesep_j):0, -floor(gridheight/2):floor(samplesep_i):ceil(gridheight/2) );
                    case 'BL'% Bottom Left
                        [ eccent_locx, eccent_locy ] = meshgrid( 0:floor(samplesep_j):gridwidth, -gridheight:floor(samplesep_i):0 );
                    case 'CB'% Center Bottom
                        [ eccent_locx, eccent_locy ] = meshgrid( -floor(gridwidth/2):floor(samplesep_j):ceil(gridwidth/2), -gridheight:floor(samplesep_i):0 );    
                    case 'BR'% Bottom Right
                        [ eccent_locx, eccent_locy ] = meshgrid( -gridwidth:floor(samplesep_j):0, -gridheight:floor(samplesep_i):0 );
                    otherwise
                        [ eccent_locx, eccent_locy ] = meshgrid( -floor(gridwidth/2):floor(samplesep_j):ceil(gridwidth/2), -floor(gridheight/2):floor(samplesep_i):ceil(gridheight/2) );
                end
                eccent_loc = [ eccent_locx(:), eccent_locy(:) ];
                
                % eccent_bounds(1) - x
                % eccent_bounds(2) - y
                % eccent_bounds(3) - w
                % eccent_bounds(4) - h
                eccent_dist = sqrt(sum(eccent_loc.*eccent_loc, 2));
                roisize = get_roi_size(eccent_dist);
                
%                 eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - roihalfsize roisize.*ones( size(eccent_loc,1), 2) ];
                eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - [roisize/2 roisize/2] roisize roisize];
                
                % Create the eccentricity rings
                for e=1:length(eccent_loc)                    
                    eccthand(e) = rectangle('Parent',get(toolhandle,'CurrentAxes'),'Curvature',[0 0],'EdgeColor','g','LineStyle','-',...
                                         'Position',[ eccent_bounds(e,1), eccent_bounds(e,2), eccent_bounds(e,3), eccent_bounds(e,4)]);
                end
            case 'Import'
                eccent_center = [ (max(layer_bounds(:,3))-min(layer_bounds(:,1)))/2 (max(layer_bounds(:,4))-min(layer_bounds(:,2)))/2 ]; % This is the common center of all of the circles.

                eccent_locx = deg_um_to_pixel(genparam.locunits, genparam.locations(:,1));
                eccent_locy = deg_um_to_pixel(genparam.locunits, genparam.locations(:,2));
                
                eccent_loc = [ eccent_locx, eccent_locy ];
                
                % eccent_bounds(1) - x
                % eccent_bounds(2) - y
                % eccent_bounds(3) - w
                % eccent_bounds(4) - h
%                 eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - roihalfsize roisize.*ones( size(eccent_loc,1), 2) ];
                eccent_dist = sqrt(sum(eccent_loc.*eccent_loc, 2));
                roisize = get_roi_size(eccent_dist);
                eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - [roisize/2 roisize/2] roisize roisize];

                % Create the boxes
                for e=1:length(eccent_loc)                    
                    eccthand(e) = rectangle('Parent',get(toolhandle,'CurrentAxes'),'EdgeColor','g','LineStyle','-',...
                                            'Position',[ eccent_bounds(e,1), eccent_bounds(e,2), eccent_bounds(e,3), eccent_bounds(e,4)]);
                end
        end

    end
        
    function generateROI()

        % Create the patches associated with the ROIs we just calculated
        eccent_dist = sqrt(sum(eccent_loc.*eccent_loc, 2));
        roisize = get_roi_size(eccent_dist);
        for i=1:size(eccent_loc,1)
             
                 bounds(1,:) = [eccent_bounds(i,1) eccent_bounds(i,2)]; % Top Left
                 bounds(2,:) = [(eccent_bounds(i,1)+roisize(i)) eccent_bounds(i,2)]; % Top Right
                 bounds(3,:) = [(eccent_bounds(i,1)+roisize(i)) ( eccent_bounds(i,2)+roisize(i) )]; % Bottom Right
                 bounds(4,:) = [eccent_bounds(i,1) ( eccent_bounds(i,2)+roisize(i) )]; % Bottom Left
                 
            
                 % scale, units, center, location, eye, type)
                 if strcmp(deblank(param.gen.locunits), 'degrees')
                    tag = calc_retina_loc( param.pixperdeg, char(176), ...
                                           eccent_loc(i,:), ...
                                           param.eye, '2term');
                 elseif strcmp(deblank(param.gen.locunits),'microns')
                     
                    tag = calc_retina_loc( pixelspermicron, '\mum', ...
                                           eccent_loc(i,:), ...
                                           param.eye, '2term');
                 end
                 
                 if isfield(param.gen,'roi_ind')
                     roinum = num2str(param.gen.roi_ind(i));
                 else
                     roinum = num2str(i);
                 end
%                  tag
%                  i*2-1
%                  i*2
                 roitext(i*2-1) = text( bounds(2,1), bounds(2,2)-50, tag, 'Color',[1 0 0]); 
                 roitext(i*2)   = text( (bounds(3,1)+bounds(1,1))/2, (bounds(3,2)+bounds(1,2))/2, roinum,...
                                        'HitTest','on', 'Color',[1 0 0],'HorizontalAlignment', 'center');
                 
                 roihand(i)= patch( bounds(:,1), bounds(:,2),...
                                     'w','EdgeColor',[1 0 0],'Parent',get(toolhandle,'CurrentAxes'),'HitTest','on',...
                                     'Tag',tag,'CDataMapping','direct','AlphaDataMapping','direct','FaceColor',[.1 .1 .1],'FaceAlpha',0.01,...
                                     'UserData',[roitext(i*2-1) roitext(i*2)]);
                %Backwardly associate the text with the handle
                set(roitext(i*2),'UserData',roihand);
        end
        repaint();
    end


    function grabROI()
        waithandle = waitbar(0,'Extracting ROIs from layers...');
        
        rasterized=0;
        
        % Set gray as the only active channel.
        pssetactivechannels({'Gray'})

        roiX = get(roihand,'XData');
        roiY = get(roihand,'YData');
        roiNames = get(roihand,'UserData');
        
        roiCellX = roiX;
        roiCellY = roiY;
        
        % If its a cell, then there are more than one ROI. If there is only
        % one ROI, then it will come out as a single array.
        if iscell(roiX) && iscell(roiY)
            numroi = size(roiX,1);
            roiX = cell2mat(roiX);
            roiY = cell2mat(roiY);
        else
            roiNames = {roiNames};
            roiCellX = {roiX};
            roiCellY = {roiY};
            numroi = 1;
        end
        
        % Construct the complete layer boundaries (instead of just the
        % corners)
        ref_layer(1,1:2,:) = param.layer_bounds(:,1:2)'; % Top Left
        ref_layer(2,1:2,:) = [param.layer_bounds(:,3) param.layer_bounds(:,2)]'; % Top Right
        ref_layer(3,1:2,:) = param.layer_bounds(:,3:4)'; % Bottom Right
        ref_layer(4,1:2,:) = [param.layer_bounds(:,1) param.layer_bounds(:,4)]'; % Bottom Left
        ref_layer(5,1:2,:) = param.layer_bounds(:,1:2)'; % Top left
        
        l=1;
        % Check which ROI the poly is contained in (if any), and load it.
        
        for k=1:size(ref_layer,3)
            
            tmp = inpolygon(roiX, roiY, ref_layer(:,1,k), ref_layer(:,2,k) );
            roicontained(k,:) = all(reshape(tmp,4,numroi),1)'; % Reshape this so that each ROI's containment is in the columns,
                                                         % then determine from this which ROIs are completely contained in a layer. 
                                                         
            loadthis = any(roicontained(k,:),2); %If this is 1, then load this layer. If the ROI isn't contained
            if(loadthis)
                try
                    usedlayer{l} = param.layer_names{k};
                    setActiveLayer(param.layer_names{k});
                    param.numungrp = param.numungrp + 1;
                catch
                    error('Error setting active layer in Photoshop!');
                end                                             

                try               % Get the pixels from the gray channel, Top, Left, Bottom, Right parameter order.
                    % If we've rasterized the entire PSD, don't do it
                    % again.
                    if rasterized == 0
                        israster = isRaster();
                    else
                        israster = 1;
                    end
                    
                    if israster
                        layerpix{l} = psgetpixels('Gray',param.layer_bounds(k,2),param.layer_bounds(k,1),...
                                                         param.layer_bounds(k,4),param.layer_bounds(k,3));
                    else
                        rasterizePSD();
                        rasterized = 1;
                        layerpix{l} = psgetpixels('Gray',param.layer_bounds(k,2),param.layer_bounds(k,1),...
                                                         param.layer_bounds(k,4),param.layer_bounds(k,3));
                    end
                catch me
                    rethrow(me)
                    error('Error grabbing pixels from active layer in Photoshop!')
                end                                             

                
                %figure(2); imshow(layerpix{l});
                waitbar(k/size(ref_layer,3),waithandle,strrep( ['Extracting layer ' param.layer_names{k} '.'],'_','\_') );
                l = l+1;
            end
        end
       
        % Find out if the ROI *DON'T* have a bounded region. If they don't,
        % then drop it from the list of ROI names so we don't mess up which
        % ROI we're looking at.
        boundROI = any(roicontained,1)';
        
        roiNamesBound  = roiNames(boundROI);
        roiXBound      = roiCellX(boundROI);
        roiYBound      = roiCellY(boundROI);

        % Pull out the rows that have contained ROI- each ROI is a column
        roicontainedbound = roicontained(any(roicontained,2), boundROI);
        ref_layerBound = ref_layer(:,:,any(roicontained,2));
        
      
        waitbar(1,waithandle, ['Finished!']);
        pause(.5);
        close(waithandle);
        
        % If the user sucks at picking ROI, none will be contained- don't
        % die if they do!
        if ~isempty(roiNamesBound)
            % Allow the user to pick the ROI within each of the layer windows
            for j=1:length(roiNamesBound)

                % Determine the layer indexes that the roi falls within
                roiinlayer = find(roicontainedbound(:,j) == 1);

                if strcmp(deblank(param.gen.locunits), 'degrees')
                    scaleunit = char(176);
                    scale = param.pixperdeg;
                elseif strcmp(deblank(param.gen.locunits),'microns')
                    scaleunit = '\mum';
                    scale = pixelspermicron;
                end
               
                [ cutout{j} loc{j} selectionid] = multiSelectFrame( layerpix(roiinlayer), usedlayer(roiinlayer),...
                                                                    roiNamesBound{j}, [roiXBound{j} roiYBound{j}],...
                                                                    get_roi_size, ref_layerBound(1,:,roiinlayer),...
                                                                    scale,scaleunit, eccent_center, param.eye);

                  tmp = usedlayer(roiinlayer);
                  layerprefix{j} = {tmp{selectionid}};
                  layerid{j} = get(roiNamesBound{j}(2),'String');
                
            end
        end
        disp('Finished.');
        
        roiout = [loc' layerprefix' cutout' layerid'];
        saveandquit(roiout)
        
    end

    % Generate the function that will be used to determine ROI size.
    function [ roi_fcn ] = deg_um_to_roisize( roiunits, locunits ) 
           
        if strcmp( param.roitype, 'Fixed')
            
            fixedroisize = deg_um_to_pixel(param.boxunits, param.roiboxsize);
            roi_fcn = @(d)ones(size(d)).*fixedroisize;
            
        elseif strcmp( param.roitype, 'Variable')
            % Calculate the padding value
            padding = deg_um_to_pixel(param.boxunits, param.roiboxsize);
            
            if strcmp(deblank(locunits),'degrees') % If the input unit is in degrees
                % Get the minimum and maximum eccentricity locations in pixels
                minlocstart = deg_um_to_pixel( locunits, .01);
                maxlocend = deg_um_to_pixel( locunits, 10);    
            elseif strcmp(deblank(locunits),'microns')            
                % Get the minimum and maximum eccentricity locations in pixels
                minlocstart = deg_um_to_pixel( locunits, .5 );
                maxlocend = deg_um_to_pixel( locunits, 2910);
            end

            if strcmp(deblank(roiunits),'degrees')
                % Get the minimum and maximum roi values in pixels
                minroisize = deg_um_to_pixel( roiunits, (37/291) ) + padding;
                maxroisize = deg_um_to_pixel( roiunits, (100/291) ) + padding;
            elseif strcmp(deblank(roiunits),'microns')
                % Get the minimum and maximum roi values in pixels
                minroisize = deg_um_to_pixel( roiunits, 37 ) + padding;
                maxroisize = deg_um_to_pixel( roiunits, 100 ) + padding;
            end

            b = (log10(minroisize)-log10(maxroisize))/log10(minlocstart/maxlocend);
            a = 10^(log10(maxroisize)-b*log10(maxlocend));

            roi_fcn = create_roi_size_fcn(a, b, minroisize, maxroisize, minlocstart, maxlocend);
        end
    end

    function [in_pixels] = deg_um_to_pixel( units, value )
        % This function converts any 'unit'ed value to pixels.
        % if value
        if strcmp(deblank(units),'degrees')

            in_pixels = value.*param.pixperdeg;

        elseif strcmp(deblank(units),'microns')

            micronsperdegree = 291*(param.axial/24);
            micronsperpixel = 1 / (param.pixperdeg / micronsperdegree);

            in_pixels = value./micronsperpixel;
        else
            in_pixels = 0;
        end
    end

    function saveandquit(roiout)
        
        if ~isempty(roiout{1})
            savePath = 0;
            while savePath == 0
                savePath = uigetdir(getparent(param.rsetfname),'Select ROI save location');

                if savePath == 0
                   h = warndlg('You must select a valid ROI save location!', 'Please select a valid folder');
                   uiwait(h);
                end
            end
            fid = fopen(fullfile(savePath, 'ROI_Locations.csv'),'w');

            % roiout col 1: locations
            % roiout col 2: layerprefix (layer name from photoshop)
            % roiout col 3: layer data


            for i=1:size(roiout,1)
                if ~isempty(roiout{i,2})
                    combined_loc = [roiout{i,1}{1}, roiout{i,1}{2}];
                    horz_loc = roiout{i,1}{1};
                    vert_loc = roiout{i,1}{2};
                    if strcmp(deblank(param.gen.locunits), 'degrees')
                        combined_loc = strrep(combined_loc, char(176),'deg');                 
                        horz_loc = strrep(horz_loc, char(176),'deg');
                        vert_loc = strrep(vert_loc, char(176),'deg');
                    elseif strcmp(deblank(param.gen.locunits),'microns')
                        combined_loc = strrep(combined_loc, '\mum','um');   
                        horz_loc = strrep(horz_loc, '\mum','um');
                        vert_loc = strrep(vert_loc, '\mum','um'); 
                    end

                    for j=1:size(roiout{i,3},1) % Loop through the (possible) multiple selections in an roi.
                        fprintf(fid,'%s,%s,%s,%s\n', roiout{i,2}{j}, horz_loc, vert_loc, roiout{i,4} );
                        imwrite(roiout{i,3}{j}, fullfile(savePath, [roiout{i,2}{j} '_' combined_loc '_' num2str(i) '.tif']))
                    end
                end
            end
        end
        fclose(fid);
        
%         undoOp(param.numungrp);
        
        delete(gcbf);
    end

	function keypress(src,evnt)

        if strcmp(get(gcf,'CurrentCharacter'),char(13)) % Character 13 is the enter character...

            state = state+1; % Advance to the next state on every enter press.

            switch state
                case SELECT_FOVEA
                    
                case SELECT_ROI_POS
                    delete(eccthand);
                    generateROI();
                case GRAB_ROI
                    grabROI();
            end
            
            disp(['Now in state ' num2str(state) '.']);
        end
    end

    function layerson(src,evt)
        repaint();
    end

    function layersoff(src,evt)
        repaint();
    end
        
    function dragdwn(src,evt)

        % As determined from StackOverflow:
        %http://stackoverflow.com/questions/10110823/is-ctrl-key-pressed
        modifiers = get(gcf,'currentModifier');
       
        if( isempty(modifiers) )
            if(strcmp(get(panhandle,'State'),'off') && ...
               strcmp(get(outhandle,'State'),'off') &&...
               strcmp(get(inhandle,'State'),'off') )
                % Signal that we've pressed the mouse
                mousedown=1;
            end
        end
    end

    % This function is designed to handle all movement of the mouse. In all
    % cases, the mouse press is overridden if there is a zoom, pan, or
    % contrast operation occuring.
    function dragmv(src,evt)
        tool_mv(src,evt);
        
        if(mousedown && strcmp(get(panhandle,'State'),'off') && ...
                        strcmp(get(outhandle,'State'),'off') &&...
                        strcmp(get(inhandle,'State'),'off')   )
            % Get the position of the mouse- update the center.         
            cp = get(gca,'CurrentPoint');

            % Depending on the state, one may be dragging a variety of
            % objects.
            switch state
                case SELECT_FOVEA
                    eccent_center = [cp(1,1) cp(1,2)];

%                     eccent_bounds = ones(length(eccent_loc),4).*((2*eccent_loc)*[1 1 1 1]);
%                     eccent_bounds(:,1:2) = (ones(size(eccent_bounds,1),1)*eccent_center)- eccent_loc*[1 1];
                    eccent_dist = sqrt(sum(eccent_loc.*eccent_loc, 2));
                    roisize = get_roi_size(eccent_dist);
                    
                    % eccent_bounds(1) - x
                    % eccent_bounds(2) - y
                    % eccent_bounds(3) - w
                    % eccent_bounds(4) - h
                    eccent_bounds = [ eccent_loc + (ones(size(eccent_loc,1),1)*eccent_center) - [roisize/2 roisize/2] roisize roisize];
                    
%                     eccent_bounds(:,1:2) = eccent_loc+(ones(size(eccent_loc,1),1)*eccent_center)-ceil(roisize/2);                                    
%                     eccent_bounds = [ eccent_loc-ceil(roisize/2) roisize.*ones( size(eccent_loc,1), 2) ];
                    
                    for i=1:length(eccthand)
                        set(eccthand(i),'Position',[ eccent_bounds(i,1), eccent_bounds(i,2), eccent_bounds(i,3), eccent_bounds(i,4)]);
                    end
                    
                case SELECT_ROI_POS
                    
                    center = [cp(1,1) cp(1,2)];
                    selected_rect = gco;

                    if strcmp(get(selected_rect,'Type'),'patch') || strcmp(get(selected_rect,'Type'),'text')   
                                
                        % Allow movement of patches
                        if( strcmp(get(selected_rect,'Type'),'patch') )
                            rect_text = get(selected_rect,'UserData');
                        elseif strcmp(get(selected_rect,'Type'),'text')
                            %If it's text, then we need to get the patch
                            %first.
                            selected_rect = get(selected_rect,'UserData');
                            rect_text = get(selected_rect,'UserData');
                        end
                        

                        if str2num(ver(1:4)) <= 2014 && strcmp(ver(end), 'a')
                            set(selected_rect,'EraseMode','xor');
                            set(rect_text(1),'EraseMode','xor');
                            set(rect_text(2),'EraseMode','xor');
                        end
                        
                        % Calculate the expected size at this eccentricity
                        roihalfsize = get_roi_size(norm( (center - eccent_center),2) ) / 2;

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

                        % scale, units, center, location, eye, type)
                        if strcmp(deblank(param.gen.locunits), 'degrees')
                            tag = calc_retina_loc( param.pixperdeg, char(176), ...
                                                   [xbounds(1)+roihalfsize-eccent_center(1) ybounds(1)+roihalfsize-eccent_center(2)], ...
                                                   param.eye, '2term');
                        elseif strcmp(deblank(param.gen.locunits),'microns')

                            tag = calc_retina_loc( pixelspermicron, '\mum', ...
                                                   [xbounds(1)+roihalfsize-eccent_center(1) ybounds(1)+roihalfsize-eccent_center(2)], ...
                                                   param.eye, '2term');
                        end
                        
                        
                        
                        set(selected_rect,'XData',[xbounds'],'YData',[ybounds']);
                        set(rect_text(1),'Position',[xbounds(2) ybounds(2)-50]);
                        set(rect_text(1),'String',tag);
                        set(rect_text(2),'Position',[center(1) center(2)]);
                       
                   
                        drawnow expose; 
                    end
            end

        end                
    end
    
    function dragup(src,evt)
        if( state == SELECT_ROI_POS)
        modifiers = get(gcf,'currentModifier');
       
        if( ~isempty(modifiers) && size(modifiers,1) == 1 )
            switch(modifiers{1})
                case 'control'
                    
                    % Get the position of the mouse- update the center.         
                    cp = get(gca,'CurrentPoint');
                    center = [cp(1,1) cp(1,2)];
                    
                    eccent_loc = [ eccent_loc; (center - eccent_center) ];

                    roisize = get_roi_size(norm( (center - eccent_center),2));
                    roihalfsize = roisize/2;
                    % eccent_bounds(1) - x
                    % eccent_bounds(2) - y
                    % eccent_bounds(3) - w
                    % eccent_bounds(4) - h
                    eccent_bounds = [ eccent_bounds;
                                      center - roihalfsize roisize roisize];

                    bounds(1,:) = [eccent_bounds(end,1) eccent_bounds(end,2)]; % Top Left
                    bounds(2,:) = [(eccent_bounds(end,1)+roisize) eccent_bounds(end,2)]; % Top Right
                    bounds(3,:) = [(eccent_bounds(end,1)+roisize) ( eccent_bounds(end,2)+roisize )]; % Bottom Right
                    bounds(4,:) = [eccent_bounds(end,1) ( eccent_bounds(end,2)+roisize )]; % Bottom Left


                    % scale, units, center, location, eye, type)
%                     tag = calc_retina_loc( param.pixperdeg, char(176), ...
%                                            eccent_loc(end,:), ...
%                                            param.eye, '2term');
                    if strcmp(deblank(param.gen.locunits), 'degrees')
                        tag = calc_retina_loc( param.pixperdeg, char(176), ...
                                               eccent_loc(end,:), ...
                                               param.eye, '2term');
                     elseif strcmp(deblank(param.gen.locunits),'microns')

                        tag = calc_retina_loc( pixelspermicron, '\mum', ...
                                               eccent_loc(end,:), ...
                                               param.eye, '2term');
                     end                   
                                       
                    roinum = num2str(str2double(get(roitext(end),'String'))+1);
                    texthand = text( bounds(2,1), bounds(2,2)-50, tag, 'Color',[1 0 0]);
                    indhand  = text( (bounds(3,1)+bounds(1,1))/2, (bounds(3,2)+bounds(1,2))/2, roinum, 'Color',[1 0 0],'HorizontalAlignment', 'center');
 
                    roitext = [roitext; texthand; indhand];
                    patchhand = patch( bounds(:,1), bounds(:,2),...
                                         'w','EdgeColor',[1 0 0],'Parent',get(toolhandle,'CurrentAxes'),'HitTest','on',...
                                         'Tag',tag,'CDataMapping','direct','AlphaDataMapping','direct','FaceColor',[.1 .1 .1],'FaceAlpha',0.01,...
                                         'UserData',[roitext(end-1) roitext(end)]);
                    roihand = [roihand; patchhand];
                    
                    repaint();
                case 'shift'
                    
                    selected_rect = gco;

                    if strcmp(get(selected_rect,'Type'),'patch') || strcmp(get(selected_rect,'Type'),'text')   
                                
                        % Allow movement of patches
                        if( strcmp(get(selected_rect,'Type'),'patch') )
                            rect_text = get(selected_rect,'UserData');
                        elseif strcmp(get(selected_rect,'Type'),'text')
                            %If it's text, then we need to get the patch
                            %first.
                            selected_rect = get(selected_rect,'UserData');
                            rect_text = get(selected_rect,'UserData');
                        end 

                        rectind = find(roihand == selected_rect);
                        tagind = find(roitext == rect_text(1));
                        
                        roihand = roihand([1:rectind-1 rectind+1:end]);
                        roitext = roitext([1:tagind-1 tagind+2:end]);
                        
                        delete(selected_rect)
                        delete(rect_text(1))
                        delete(rect_text(2))
                    end
            end
        end
        if ishandle(selected_rect) &&strcmp(get(selected_rect,'Type'),'patch')
            
            if str2num(ver(1:4)) <= 2014 && strcmp(ver(end), 'a')
                set(selected_rect,'EraseMode','normal');
                roitext = get(selected_rect,'UserData');
                set(roitext(1),'EraseMode','normal');
                set(roitext(2),'EraseMode','normal');
            end
        end
        end
       mousedown=0;
    end
        
    function movewindow(src,evt)
        repaint();
    end

    % Repainting the image consists of redrawing all of the necessary
    % graphics.
    function repaint()
        
        if all(recthand)~=0; delete(recthand); recthand = zeros(length(layer_bounds),1); end;
        
        
        if( strcmp(get(showlayers,'State'),'on') )
            
%             rectnew = copyobj(recthand,get(toolhandle,'CurrentAxes'));
%             delete(recthand);
%             recthand = rectnew;
            % This refreshes the layer rectangles
            for i=1:length(layer_bounds)
                recthand(i)= rectangle('Parent',get(toolhandle,'CurrentAxes'),...
                          'Position',[ layer_bounds(i,1), layer_bounds(i,2), layer_bounds(i,3)-layer_bounds(i,1), layer_bounds(i,4)-layer_bounds(i,2)]);
            end
        end
        
        switch state
            case SELECT_FOVEA
                ecctnew = copyobj(eccthand,get(toolhandle,'CurrentAxes'));
                delete(eccthand);
                eccthand = ecctnew;
            case SELECT_ROI_POS
                
                roinew    = copyobj(roihand,get(toolhandle,'CurrentAxes'));
                roinewtag = copyobj(roitext,get(toolhandle,'CurrentAxes'));
                delete(roihand);
                delete(roitext);
                roihand  = roinew;
                roitext  = roinewtag;
                for x=1:length(roihand)
                    set(roihand(x),'UserData',[roitext(x*2-1) roitext(x*2)])
                    set(roitext(x*2),'UserData',roihand(x));
                end
            
        end


        
        

%         drawnow;

    end

end

