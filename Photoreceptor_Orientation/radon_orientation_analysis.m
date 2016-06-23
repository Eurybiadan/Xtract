function [statistics] = radon_orientation_analysis(im, coords, um_per_pix)

% Calculate the cell distances
mean_nn_dist=calc_icd(coords,um_per_pix);

% figure(33); imagesc(im); colormap gray; axis image;
% recth = rectangle('Position',[0 0 1 1], 'EdgeColor','r');

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
           
        roi = roi.*mask;
        outroi = double(roi.*mask);

        radonim = radon(roi,60:120)';

        clear numpeaks;
        
        % Determine the cutoffs for the radon xform by looking for the FWHM
        gausfilt = fspecial('gaussian',[1 5],.75);
        middle_orient = round( size(radonim,1)/2);
        
        middlerow = conv(radonim(middle_orient,:),gausfilt,'valid');
        
        xings = 1:length(middlerow);
        xings = xings(middlerow > (max(radonim(middle_orient,:))/2) );

        rrms=[];
        for r=1:size(radonim,1)
            radonrow = radonim(r,:);
            
            
            radonrow = conv(radonrow,gausfilt,'valid');

            radonrow = radonrow( (xings(1)):(xings(end)));
            dervline =  ( diff( radonrow,2) ); %, 4 );
            
            rrms(r) = rms( dervline );
        end 
        
        rrms= rrms';
                  
        [rmsval angle] = max(rrms);
        [val worstangle] = min(rrms);
        
        theta = (angle-31);


        alist(i) = theta;
        arms(i) = rmsval;
%         disp(['Found angles were: RMS:' num2str(val) ' Angle: ' num2str(61-angle)] );
%         disp(['Found angles were: RMS:' num2str(61-angle) ' and GAUS: ' num2str(61-topind)] );

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

statistics.radon_angles = mean(alist(alist~=-100) );

%% Determine the orientation autocorrelation
% triangulation = delaunayTriangulation(coords);
% alistautocorr=[];
% for i=1:length(triangulation.Points)
% 
%     neigh = cell2mat( vertexAttachments(triangulation,i) );
%     
%     if size(neigh,2) == 6
%         
%         neighind = unique(triangulation(neigh,:));
%         connected_vertices  =coords( neighind,: );
%             
%         for v=1:length(connected_vertices)
%             if( (connected_vertices(v,1) == triangulation.Points(i,1) ) && ...
%                 (connected_vertices(v,2) == triangulation.Points(i,2)) )
% 
% %                 center = connected_vertices(v,:);
%                 centerind = neighind(v);
% %                 connected_vertices = [connected_vertices(1:v-1,:); connected_vertices(v+1:end,:)];
%                 connected_ind = [neighind(1:v-1,:); neighind(v+1:end,:)];
%                 break;
%             end
%         end
%         
%         if alist(centerind) ~= -100
%             conn_orient = alist(connected_ind);
%             conn_orient = conn_orient(conn_orient ~=-100);
%             alistautocorr = [alistautocorr; mean(alist(centerind)-conn_orient)];
%         end
%     end    
% end
% figure(32); bar(-30:1:30,histc(alistautocorr, -30:1:30)./length(alistautocorr) ,'histc');
