im=imread('CSL.jpg');
%figure;imshow(im);

% Filtering

%# Create the gaussian filter with hsize = [5 5] and sigma = 2
sigma=5;
hsize=[2*ceil(2*sigma)+1 2*ceil(2*sigma)+1];
G = fspecial('gaussian',hsize,sigma);
%# Filter it
im_gauss_filt = imfilter(im,G,'same');
%figure; imshow(im_gauss_filt);
%print -dpng FCV_Project_Sigma4.png

% Edge detection
im_gray=rgb2gray(im_gauss_filt);
im_edge=edge(im_gray,'canny',[0.05 0.15]);

im_edge(1:4,:)=0;
im_edge(:,1:4)=0;
im_edge(:,end-4:end)=0;
im_edge(end-4:end,:)=0;
%figure;
%imshow(im_edge);
% Hough Analysis

[H,T,R] = hough(im_edge);
T;
P  = houghpeaks(H,1000,'threshold',ceil(0.3*max(H(:))));
%figure;imshow(H,[],'XData',T,'YData',R,...
%            'InitialMagnification','fit');
%xlabel('\theta'), ylabel('\rho');
%axis on, axis normal, hold on;
%x = T(P(:,2)); y = R(P(:,1));
%plot(x,y,'s','color','white');
lines = houghlines(im_edge,T,R,P,'FillGap',100,'MinLength',9);
%figure; imshow(im); hold on;
max_len = 0;
xy_lines=[];
       for k = 1:length(lines)
          if ((lines(k).theta > -28 && lines(k).theta < -25) || (lines(k).theta > 45 && lines(k).theta < 49) )
                xy_lines = [xy_lines; lines(k).point1 lines(k).point2 lines(k).rho lines(k).theta];
                xy = [lines(k).point1; lines(k).point2];
               % plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');
                len = norm(lines(k).point1 - lines(k).point2);
                if ( len > max_len)
                    max_len = len;
                    xy_long = xy;
                end
           end
       end

figure; imshow(im); hold on;
xy_different_lines = [ ];
for k = 1:size(xy_lines,1)-1
    for p= k+1:size(xy_lines,1)
               if( (xy_lines(k,5) == xy_lines(p,5)) && (xy_lines(k,6) == xy_lines(p,6)))
                   if( abs(xy_lines(k,1)-xy_lines(k,3)) > abs(xy_lines(p,1)-xy_lines(p,3))  )
                        xy_different_lines = [xy_different_lines; xy_lines(k,:)];
                        xy = [xy_lines(k,1) xy_lines(k,2); xy_lines(k,3) xy_lines(k,4)];
                        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                   else              
                        xy_different_lines = [xy_different_lines; xy_lines(p,:)];
                        xy = [xy_lines(p,1) xy_lines(p,2); xy_lines(p,3) xy_lines(p,4)];
                        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                   end
               end  
     end
end

xy_intersecting_points=[];
for k=1: size(xy_different_lines,1)-1
    for p=k+1:size(xy_different_lines,1)
        x1=[xy_different_lines(k,1) xy_different_lines(k,3)];
        y1=[xy_different_lines(k,2) xy_different_lines(k,4)];
        x2=[xy_different_lines(p,1) xy_different_lines(p,3)];
        y2=[xy_different_lines(p,2) xy_different_lines(p,4)];
        [x, y]=polyxpoly(x1,y1,x2,y2);
        if(isempty(x) && isempty(y))
            continue
        end
        if(size(xy_intersecting_points,1) == 0)
            xy_intersecting_points = [x y 1];
            continue
        else
            for q=1:size(xy_intersecting_points,1)
                if(xy_intersecting_points(q,1) == x && xy_intersecting_points(q,2) == y)
                    xy_intersecting_points(q,3)=xy_intersecting_points(q,3) + 1;
                    break
                end
            end
            if(q == size(xy_intersecting_points,1))
                xy_intersecting_points = [xy_intersecting_points;x y 1 k p];
            end
        end
    end
end
targetIndex = find(max(xy_intersecting_points(:,3)));
plot(xy_intersecting_points(targetIndex,1),xy_intersecting_points(targetIndex,2),'x','LineWidth',10,'Color','yellow');
print -dpng FCV_Project_Vanishing.png