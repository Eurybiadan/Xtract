function [ loadfiles ] = load_associated_AOSLO_tuple( basepath, allfiles, assocationstr )
% Robert F Cooper 10-17-2014
%   This function loads a single AOSLO tuple- meaning, it will parse
%   together image files with a common root. 

looplen=[];
fileoptions=[];
loadfiles = [];

%% Grab the different types of filenames
for i=1:length(assocationstr)
    strloc = strfind(allfiles ,assocationstr{i});
    str    = ~cellfun( @isempty, strloc);
    
    if any(str)
    
        fileoptions = [fileoptions {allfiles(str)}];
        looplen     = [looplen length(allfiles(str))];
        
    end
end


% Use the biggest list to check for matches
[looplen longind] = max(looplen);

%% Go through each of the lists above, comparing filenames to the
% other pair- each time a file is assessed, remove it and its
% matches (if they exist). Otherwise, add it to the loading group.
% h = waitbar(0, ['Finding filename tuples: ' strrep(fileoptions{longind}{1},'_','\_')]);
for j=1:looplen
%     disp(['Reference: ' fileoptions{longind}{j}])
%     waitbar(j/(2*looplen), h, ['Finding filename tuples: ' strrep(fileoptions{longind}{1},'_','\_')]);

    wildcard = fileoptions{longind}{j};
    matchfiles = {wildcard};
    % Use a regular expressions to find the common rest of the
    % string in the filename
    wildcard = ['(' strrep(wildcard,assocationstr{longind},')*(') ')'];

    for k=1:length(fileoptions)
        if k ~= longind

            matches = ~cellfun(@isempty, regexp(fileoptions{k},wildcard));

%             disp(['Matches: ' fileoptions{k}{matches}])
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


% loadedim = [];
% loadedname = [];
% for j=1:length(loadfiles)
%     loadtmp = [];
% %     waitbar( (j+looplen)/(2*looplen), h, ['Loading filename tuples: ' strrep(fileoptions{longind}{1},'_','\_')]);
%     for k=1:length(loadfiles{j}) % Load confocal, and/or split and/or average
% 
%         loadtmp{k} = imread( fullfile(basepath, loadfiles{j}{k}) );
% %         loadedname{k} = loadfiles{j}{k};
%         
%     end
% 
%     loadedim = [loadedim; {loadtmp}];
% end

% close(h);
end

