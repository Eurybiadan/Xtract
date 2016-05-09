function [param] = image_culler(param)

basepath = param.basepath;

filesstr = param.substr;
param.selectedImNames = {};
i = 0;
maxmov = 250;
allfiles = read_folder_contents(basepath, 'tif','Wildcard',['_' num2str(i,'%04d') '_'] );

while i <= maxmov

    if ~isempty(allfiles)
    
        length(allfiles)
        allfiles;
        
        wildcardloc = strfind(allfiles, ['_' num2str(i,'%04d') '_']);
        validfiles  = cell2mat(cellfun(@(x) any(x>8), wildcardloc, 'UniformOutput',0));
        allfiles    = allfiles(validfiles);
        
        looplen=[];
        fileoptions=[];
        loadfiles = [];
        
        %% Grab all of the subset filenames
        for j=1:length(filesstr)
        
            loc   = strfind(allfiles,filesstr{j});
            found = ~cellfun( @isempty, loc);
            if any(found)
                fileoptions = [fileoptions {allfiles(found)}];
                looplen  = [looplen length(allfiles(found))];            
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
                if k ~= longind
                    
                    matches = ~cellfun(@isempty, regexp(fileoptions{k},wildcard));
            
                    disp(['Matches: ' fileoptions{k}{matches}]);
                    matchfiles = [matchfiles fileoptions{k}(matches)];
                    
                end
            end
            % If we found matches among all of our options, then add them
            % to the list of "to be loaded"
            if length(matchfiles) == length(fileoptions)
                loadfiles = [ loadfiles {matchfiles} ];
            else
                disp('Not all modality types match! Ignoring...');
            end
        end
        
        %% Actually load the images
        loadedim = [];
        loadedname = [];
        for j=1:length(loadfiles)
            loadtmp = [];
            waitbar( (j+looplen)/(2*looplen), h, ['Loading filename tuples: ' strrep(fileoptions{longind}{1},'_','\_')]);
            for k=1:length(loadfiles{j}) % Load confocal, and/or split and/or average
            
                loadtmp = [loadtmp imread( fullfile(basepath, loadfiles{j}{k}) ) ];
                
                if ~isempty(strfind(loadfiles{j}{k},filesstr{longind}))
                    loadedname{j} = strrep(loadfiles{j}{k},filesstr{longind},'_');
                    loadedname{j};
                end
            end
            
            loadedim = [loadedim; {loadtmp}];
        end
        
        close(h);
        
        %% Go through the selection process
        if i==0 || ~exist('updateContents')
            [updateContents selected linkedHandle]= linkedImageFrame(loadedim, loadedname);
        else
            selected = updateContents(loadedim, loadedname);
        end

        
        %% Copy the images we wanted
        for j=1:length(loadfiles)
            
            if selected(j)
                % If we've selected them to be imported, load them. 
                param.selectedImNames = [param.selectedImNames loadfiles(j)];
                
%                 for k=1:length(loadfiles{j}) % Copy confocal, and/or split and/or average
            
%                 copyfile( fullfile(basepath, loadfiles{j}{k}), fullfile(copypath, loadfiles{j}{k}) );
                
%                 disp(['From: ' fullfile(basepath, loadfiles{j}{k}) ' To: ' fullfile(copypath, loadfiles{j}{k})])
% 
%                 end
            end            
        end
        
    end    
    i = i+1;
    allfiles = read_folder_contents(basepath,'tif','Wildcard',['_' num2str(i,'%04d') '_'] );
end

close(linkedHandle);

end
