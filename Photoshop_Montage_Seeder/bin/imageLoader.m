function [] = imageLoader(param)

basepath = param.basepath;

filesstr = param.substr;


micronsperdegree = (291*param.axial)/24;
micronsperpixel = 1 / (param.pixperdeg / micronsperdegree);

percentratio = zeros(size(param.scandata{1},1),1 );

for i=1:size(param.scandata{1},1)

% Depending on the FOV, calculate the ratio for each movie.
thisscale = param.allscale(param.scandata{2}(i) == param.allscale(:,1),2);
percentratio(i) = param.pixperdeg/thisscale;

[xshift(i) yshift(i) dominant_direction{i}] = deg_um_to_pixel( param.scandata{1}{i}, percentratio(i) );

end

group_directions = unique(dominant_direction);

% Create a new photoshop document with the sizes we calculated (with some
% padding) Order: (col, row)
canvas_size = [ abs(min(xshift))+max(xshift)+(param.pixperdeg*3) abs(min(yshift))+max(yshift)+(param.pixperdeg*3)];

psconfig( 'pixels', 'pixels', 10, 'no' );
psnewdoc( canvas_size(1), canvas_size(2), 72, [param.montage_name '_' num2str(micronsperpixel,'%0.4f') 'umppx.psd'], 'grayscale');

% Flip the canvas_size variable so it matches our column dominant approach
% canvas_size = canvas_size*[0 1; 1 0];

% Create the groups we have
fovlist = unique(param.scandata{2});
if param.groupbyfov % If we've turned on grouping by FOV, then create the groups
    for i=1: length(fovlist)

        make_Photoshop_group( num2str(fovlist(i),'%0.1f') );

        if param.groupbysubset% If we've turned on grouping by subset, then create the groups
            for j=1: length(filesstr)

                make_Photoshop_group( [num2str(fovlist(i),'%0.1f') '_' strrep(filesstr{j},'_','')] );
                add_to_Photoshop_group(num2str(fovlist(i),'%0.1f'));
                
                if param.groupbydomdir
                    for k=1: length(group_directions)                        
                        if ~isempty(group_directions{k})
                            make_Photoshop_group( [ num2str(fovlist(i),'%0.1f') '_' strrep(filesstr{j},'_','') '_' group_directions{k}] );
                            add_to_Photoshop_group([num2str(fovlist(i),'%0.1f') '_' strrep(filesstr{j},'_','')]);
                        end
                    end
                end
            end
        end
        % Make the active layer the previous FOV, so we don't place the next
        % FOV group inside of 1.0
        setActiveLayer(num2str(fovlist(i),'%0.1f'));
    end
elseif param.groupbysubset% If we've turned on grouping by subset, then create the groups
    
    for j=1: length(filesstr)

        make_Photoshop_group( strrep(filesstr{j},'_','') );
    end
end

i = 0;
maxmov = 250;
allfiles = read_folder_contents(basepath, 'tif','Wildcard',['_' num2str(i,'%04d') '_'] );

while i <= maxmov

    if ~isempty(allfiles)
    
        wildcardloc = strfind(allfiles, ['_' num2str(i,'%04d') '_']);
        validfiles  = cell2mat(cellfun(@(x) any(x>8), wildcardloc, 'UniformOutput',0)); % Only consider it part of the group if it occurs later in the filename.
        allfiles    = allfiles(validfiles);
        
        looplen=zeros(length(filesstr),1);
        fileoptions=cell(length(filesstr),1);
        loadfiles = [];
        
        %% Grab all of the subset filenames
        for j=1:length(filesstr)
%             filesstr{j}
            loc   = strfind(allfiles,filesstr{j});
            found = ~cellfun( @isempty, loc);
            if any(found)
                fileoptions(j) = {allfiles(found)};
                looplen(j) = length(allfiles(found));
            end
        
        end

        % Use the biggest list to check for matches
        [looplen longind] = max(looplen);
        
        %% Go through each of the lists above, comparing filenames to the
        % other pair- each time a file is assessed, remove it and its
        % matches (if they exist). Otherwise, add it to the loading group.
        h = waitbar(0, ['Finding filename tuples: ' strrep(fileoptions{longind}{1}, '_', '\_')]);
        for j=1:looplen
            disp(['Reference: ' fileoptions{longind}{j}])
            waitbar(j/(2*looplen), h, ['Finding filename tuples: ' strrep(fileoptions{longind}{1}, '_', '\_')]);
            
            wildcard = fileoptions{longind}{j};
            matchfiles = {wildcard};
            % Use a regular expressions to find the common rest of the
            % string in the filename
            wildcard = ['(' strrep(wildcard, filesstr{longind},')*(') ')'];
            
            for k=1:length(fileoptions)
                if k ~= longind && ~isempty(fileoptions{k})
                    
                    matches = ~cellfun(@isempty, regexp(fileoptions{k},wildcard));
            
                    disp(['Matches: ' fileoptions{k}{matches}]);
                    matchfiles = [matchfiles fileoptions{k}(matches)];
                    
                end
            end
            % If we found matches among all of our options, then add them
            % to the list of "to be loaded"
            
            loadfiles = [ loadfiles {matchfiles} ];

        end
        
        %% Actually load the images
        loadedim = [];
        loadedname = [];
        for j=1:length(loadfiles)
            loadtmp = [];
            
            for k=1:length(loadfiles{j}) % Load confocal, and/or split and/or average
            
                loadtmp = [loadtmp imread( fullfile(basepath, loadfiles{j}{k}) ) ];
                
                if ~isempty(strfind(loadfiles{j}{k},filesstr{longind}))
                    loadedname{j} = strrep(loadfiles{j}{k},filesstr{longind},'_');
                end
            end
            
            loadedim = [loadedim; {loadtmp}];
        end                
        
        
        % Determine which images are larger than the minimum allowable size
        if param.limitimagesize
            aboveminsize = cellfun(@(s) all(size(s)>[param.minsize(1) param.minsize(2)*3]),loadedim);
            loadedim     = loadedim(aboveminsize);
            loadedname   = loadedname(aboveminsize);
            loadfiles    = loadfiles(aboveminsize);
        end
        
        %% If we designated that we wanted to cull the images, go through the selection process
        if param.cullimages
            if i==0 || ~exist('updateContents')
                [updateContents selected linkedHandle]= linkedImageFrame(loadedim, loadedname);
            else
                selected = updateContents(loadedim, loadedname);
            end
        else
            selected = ones(length(loadfiles),1);
        end

        
        %% Load the images we wanted into photoshop
        for j=1:length(loadfiles)            
            if selected(j)
                waitbar( (j+looplen)/(2*looplen), h, 'Loading files into photoshop...');
                % If we've selected them to be imported, load them into Photoshop. 
                for k=1:length(loadfiles{j}) % Copy confocal, and/or split and/or average                                
                    
                    names_to_import = loadfiles{j};
                    
%                     disp(['Importing ' names_to_import{k} ' at ' num2str(percentratio(i+1)*100) '% scale.'] );
                    
                    
                    psnewlayer(names_to_import{k}(1:end-4));
                    load_file_Photoshop( strrep(fullfile(param.basepath, names_to_import{k}),'\','\\'), ...
                                     xshift(i+1), yshift(i+1), percentratio(i+1)*100, percentratio(i+1)*100);
                    
                    strmatched = cell2mat( cellfun(@(s) ~isempty(strfind(names_to_import{k},s)), filesstr, 'UniformOutput',false ) );

                    if ~any( strmatched(param.visible) )
                        set_Photoshop_layer_Visibility('false');
                    end

                    if param.groupbyfov || param.groupbysubset
                        groupname=[];
                        
                        if param.groupbyfov
                            groupname = num2str(param.scandata{2}(i+1),'%0.1f');
                        end
                        
                        if param.groupbysubset
                            if sum(strmatched(param.visible)) > 1

                            wh = warndlg('Two substrings match this filename! Either change the filename, or change your substring. Defaulting to first substring....', 'Substring conflict!');
                            uiwait(wh);

                            [val ind] = max(strmatched);

                                if ~isempty(groupname)
                                    groupname = [ groupname '_' strrep(filesstr{ind},'_','')];
                                else
                                    groupname = strrep(filesstr{ind},'_','');
                                end
                            else
                                if ~isempty(groupname)
                                    groupname = [ groupname '_' strrep(filesstr{strmatched},'_','')];
                                else
                                    groupname = strrep(filesstr{strmatched},'_',''); 
                                end
                            end                            
                        end
                        
                        if param.groupbydomdir
                            if ~isempty(dominant_direction{i+1})
                                groupname = [ groupname '_' dominant_direction{i+1} ];
                            end
                        end
                        
                        add_to_Photoshop_group(groupname)
                    end
                    
                    waitbar( (j+looplen)/(2*looplen), h, ['Loading ' strrep(names_to_import{k}, '_', '\_') ' into photoshop...']);                    
                end
                
                % Link the layers we just imported
                link_Photoshop_layers(names_to_import);
            end            
        end
        close(h);
    end
    
    i = i+1;
    allfiles = read_folder_contents(basepath,'tif','Wildcard',['_' num2str(i,'%04d') '_'] );
end

% close(linkedHandle);

function [xshift, yshift, domdir] = deg_um_to_pixel( locationstring, fov )

        switch( locationstring )
            case {'TRC','trc'}
                xshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'MRE','mre'}
                xshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = 0;
                domdir = 'Fovea';
            case {'BRC','brc'}
                xshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'MBE','mbe'}
                xshift = 0;
                yshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'BLC','blc'}
                xshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'MLE','mle'}
                xshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = 0;
                domdir = 'Fovea';
            case {'TLC','tlc'}
                xshift = sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                yshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'MTE','mte'}
                xshift = 0;
                yshift = -sqrt( (fov./2.0)*(fov./2.0) + (fov./2.0)*(fov./2.0) ).*param.pixperdeg;
                domdir = 'Fovea';
            case {'CENTER','center'}
                xshift = 0;
                yshift = 0;
                domdir = 'Fovea';
            otherwise        
                [token, remain]=strtok(locationstring,'STNI');

                xshift = 0;
                yshift = 0;
                domdir = '';

                %Tokenize the string using S,I,N,T
                while ~isempty(remain)            
                    switch( remain(1) )
                        case 'S'
                            yshift = -(str2double(token)+(fov./2.0))*param.pixperdeg;
                            
                            if abs(yshift) >= abs(xshift)
                                domdir = 'Superior';
                            end
                        case 'I'
                            yshift = (str2double(token)+(fov./2.0))*param.pixperdeg;
                            
                            if abs(yshift) >= abs(xshift)
                                domdir = 'Inferior';
                            end
                        case 'T'
                            if strcmp(param.eye,'od')
                                xshift = -(str2double(token)+(fov./2.0))*param.pixperdeg;
                            elseif strcmp(param.eye,'os')
                                xshift = (str2double(token)+(fov./2.0))*param.pixperdeg;
                            end
                            
                            if abs(xshift) >= abs(yshift)
                                domdir = 'Temporal';
                            end
                        case 'N'
                            if strcmp(param.eye,'os')
                                xshift = -(str2double(token)+(fov./2.0))*param.pixperdeg;
                            elseif strcmp(param.eye,'od')
                                xshift = (str2double(token)+(fov./2.0))*param.pixperdeg;
                            end
                            
                            if abs(xshift) >= abs(yshift)
                                domdir = 'Nasal';
                            end                            
                    end

                    [token, remain]=strtok(remain(2:end),'STNI');
                end
        end
    end

end
