clear;
close all; 

[fname pathname] = uigetfile('*.txt;*.csv');

coords = dlmread(fullfile(pathname,fname));

coords = coords;

imname = [fname(1:end-11) '.tif'];
impath = fullfile(pathname,imname);
if exist(impath,'file')
   im = imread(impath);
end
   
um_per_pix=.5;

% Calculate the cell distances
mean_nn_dist=calc_icd(coords,um_per_pix);

figure(33); imagesc(im); colormap gray; axis image;
recth = rectangle('Position',[0 0 1 1], 'EdgeColor','r');

% micronboxsize = 12;
micronboxsize = mean_nn_dist.*4.5;

pixelboxsize = ceil(micronboxsize./um_per_pix);
pixelboxhalf = floor(pixelboxsize/2);

% center it on 0 so that we can rotate/translate to the center

anglecoords = [-3, 0;
                3, 0];

[X, Y]=meshgrid(0:(pixelboxhalf*2), 0:(pixelboxhalf*2));

X = X-pixelboxhalf;
Y = Y-pixelboxhalf;

mask = uint8(X.^2 + Y.^2 < pixelboxhalf.^2);


% figure(33); voronoi( coords(:,1), coords(:,2) ); axis image;

i=1;
j=1;
alist=-100*ones(size(coords,1),1);
for i=1:size(coords,1)
        
    x = round(coords(i,1));
    y = round(coords(i,2));
    
    if (y-pixelboxhalf) > 0           && (x-pixelboxhalf) > 0 && ...
       (y+pixelboxhalf) <= size(im,1) && (x+pixelboxhalf) <= size(im,2)
       
        roi = im( y-pixelboxhalf : y+pixelboxhalf, ...
                  x-pixelboxhalf : x+pixelboxhalf);

%         figure(33); hold on;
%         set(recth, 'Position',[x-pixelboxhalf y-pixelboxhalf pixelboxsize pixelboxsize]);
%         hold off;
              
%         roi = 255.*((roi-min(roi(:)))./max(roi(:)));

%         figure(2); imagesc(roi); colormap gray; axis image;

%         roi = histeq(uint8(roi));
        
%         outroi = double(roi);                      
%         imwrite(uint8(255.*(outroi./max(outroi(:)))),'roi.tif');
                      
        roi = roi.*mask;
        outroi = double(roi.*mask);
%         imwrite(uint8(255.*(outroi./max(outroi(:)))),'roimasked.tif');
        
        radonim = radon(roi,60:120)';
%         radonim = radon(roi)';
        
%         figure(1);
%         imagesc(radonim); colormap gray; axis image;
% 
%         outradonim = uint8(255.*(radonim./max(radonim(:))));
%         
% 
%         imwrite(outradonim,'radon_60_120.tif');
%         

        clear numpeaks;
        
        % Determine the cutoffs for the radon xform by looking for the FWHM
        gausfilt = fspecial('gaussian',[1 5],.75);
        middle_orient = round( size(radonim,1)/2);
        
        middlerow = conv(radonim(middle_orient,:),gausfilt,'valid');
        
        xings = 1:length(middlerow);
        xings = xings(middlerow > (max(radonim(middle_orient,:))/2) );
%         xings = find_zero_crossings(diff(middlerow,2));
         
        rrms=[];
        for r=1:size(radonim,1)
            radonrow = radonim(r,:);
            
            
            radonrow = conv(radonrow,gausfilt,'valid');
          
%             xings = 1:length(radonrow);
%             xings = xings(radonrow > (max(radonrow)/2) );
            
            radonrow = radonrow( (xings(1)):(xings(end)));
            dervline =  ( diff( radonrow,2) ); %, 4 );
            
            rrms(r) = rms( dervline );


%             pause(1);
        end 
        
        rrms= rrms';
%         if any(numpeaks>=3) % For edge cases in generated mosaics...
%             numpeaks = numpeaks>=3;
%             rrms = rrms(numpeaks);
%         end
        
                  
        [rmsval angle] = max(rrms);
        [val worstangle] = min(rrms);
        
        theta = (angle-31);

        
%         tform = affine2d([cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; x y 1]);
%         
%         [rotx roty]=transformPointsForward(tform,anglecoords(:,1),anglecoords(:,2));
%         
% %         figure(1); imagesc(roi); colormap gray; axis image; hold on;
%         figure(33); hold on;
%         plot(x, y,'b.');
%         plot(rotx,roty,'r'); %title(num2str(61-angle));
%         hold off;
        
        
%         figure(3); plot((xings(1)+1):(xings(end)-1), radonim(angle,(xings(1)+1):(xings(end)-1)), (xings(1)+1):(xings(end)-1), radonim(worstangle,(xings(1)+1):(xings(end)-1))  );
%         figure(4); plot((xings(1)+2):(xings(end)-1), diff(radonim(angle,(xings(1)+1):(xings(end)-1))), (xings(1)+2):(xings(end)-1), diff(radonim(worstangle,(xings(1)+1):(xings(end)-1))) );

%         disp(['Found angle was: ' num2str(59-angle)]);

%         if (61-angle) < 0
%             disp(['Found angle was: ' num2str(angle-61)]);
%         end

        
%         a=lsqcurvefit(@sumofThreeGauss,a0,1:47,radonim(topind,:),lb,ub);
%         figure(1); plot((1:47),radonim(topind,:), (1:47), gausfunc(a(1),a(2),a(3),1:47), (1:47), gausfunc(a(4),a(5),a(6),1:47),(1:47), gausfunc(a(7),a(8),a(9),1:47));
%         figure(1); plot((1:45),diff(radonim(angle,:),2));

%       if theta == -30
%           figure(1); imagesc(roi); colormap gray; axis image;
%         figure(2); imagesc(radonim); colormap gray; axis image;
%         figure(3); plot(radonim(angle,xings(1):(xings(end))));
%         figure(4); plot(diff(radonim(angle,(xings(1)):(xings(end))),2) );
%         
% %         [thesepeaks, theselocs]=findpeaks(rrms);
% %         rng = -30:1:30;
% %         figure(4); plot(rng,rrms,'b', rng(theselocs), thesepeaks,'r*');
% %         
% %         [maxpeak, maxpeakind] = max(thesepeaks);
% %         theta = rng(theselocs(maxpeakind));
%         
% %         pause(1);
%         val = 57;
%         figure(5); plot(radonim(val,xings(1):(xings(end))));
%         figure(6); plot(diff(radonim(val,xings(1):(xings(end))),2));
%         
%       end


        alist(i) = theta;
        arms(i) = rmsval;
%         disp(['Found angles were: RMS:' num2str(val) ' Angle: ' num2str(61-angle)] );
%         disp(['Found angles were: RMS:' num2str(61-angle) ' and GAUS: ' num2str(61-topind)] );
        
%         pause;
    end
end


    
% figure(1); imagesc(im); axis image; colormap gray;
figure(30); imagesc(im); colormap gray; axis image; hold on;

[V,C] = voronoin(coords,{'QJ'});

green=0;
blue=0;

%% Color the voronoi cells based on the above values
for i=1:length(C)
   
    vertices=V(C{i},:);
    numedges=size(V(C{i},1),1);
    
if (all(C{i}~=1)  && all( vertices(:,1)<=max(coords(:,1))) && all(vertices(:,2)<=max(coords(:,2)) ) ... % Second row are the Column limits
                  && all( vertices(:,1)>=min(coords(:,1))) && all(vertices(:,2)>=min(coords(:,2)) ) )
        
 
        if ((alist(i) >=-30) && (alist(i) < -25))
%             if alist(i) == -30 
%                 alist(i) = -100;
%                 color = 'k';
%             else
%              
                color = 'b';
%             end
        elseif (alist(i) >= -25) && (alist(i) < -15)
            color = 'c';
        elseif (alist(i) >=-15) && (alist(i) < -5)
            color = 'g';
            green = green+1;
        elseif (alist(i) >=-5) && (alist(i) <= 5)
            color = 'y';
        elseif (alist(i) >5) && (alist(i) <= 15)
            color = 'm';
        elseif ((alist(i) >15) && (alist(i) <= 25)) 
            color = 'r';
        elseif  ((alist(i) >25) && (alist(i) <= 30))
            color = 'b';
        else
%             alist(i) = -100;
            color = 'k';
        end 
        
        if (numedges == 6)            
            patch(V(C{i},1), V(C{i},2), ones(size(V(C{i},1))),'FaceColor',color );
        else
            alist(i) = -100;
            patch(V(C{i},1), V(C{i},2), ones(size(V(C{i},1))),'FaceColor','k' );
        end
else
    alist(i) = -100;
end
 
end
axis image;
title('Radon Orientation Map')
hold off;

figure(31); bar(-30.5:1:30.5,histc(alist(alist~=-100), -30.5:1:30.5) ,'histc');


%% Determine the orientation autocorrelation
triangulation = delaunayTriangulation(coords);
alistautocorr=[];
for i=1:length(triangulation.Points)

    neigh = cell2mat( vertexAttachments(triangulation,i) );
    
    if size(neigh,2) == 6
        
        neighind = unique(triangulation(neigh,:));
        connected_vertices  =coords( neighind,: );
            
        for v=1:length(connected_vertices)
            if( (connected_vertices(v,1) == triangulation.Points(i,1) ) && ...
                (connected_vertices(v,2) == triangulation.Points(i,2)) )

%                 center = connected_vertices(v,:);
                centerind = neighind(v);
%                 connected_vertices = [connected_vertices(1:v-1,:); connected_vertices(v+1:end,:)];
                connected_ind = [neighind(1:v-1,:); neighind(v+1:end,:)];
                break;
            end
        end
        
        if alist(centerind) ~= -100
            conn_orient = alist(connected_ind);
            conn_orient = conn_orient(conn_orient ~=-100);
            alistautocorr = [alistautocorr; mean(alist(centerind)-conn_orient)];
        end
    end    
end
figure(32); bar(-30:1:30,histc(alistautocorr, -30:1:30)./length(alistautocorr) ,'histc');