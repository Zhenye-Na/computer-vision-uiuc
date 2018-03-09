clear all
%parameters for the systems.
n=10;
scale=2;
k=1.25;
threshold=0.5;

%load and preprosses the image.
img=imread('../data/fishes.jpg');
s=size(img);
filter=cell(n,1);
img=rgb2gray(img);
img=im2double(img);



%scale-Space source - "https://en.wikipedia.org/wiki/Scale_space"
scale_space=zeros(s(1),s(2),s(3));
scale_spaceNew=zeros(s(1),s(2),s(3));

%Choose between two approches 
ip=input('Enter choice: 0:-Slower 1:-Faster:');
switch ip 
    
   case 0 %slower working : change the filter size.
tic
for i=(1:n)
    filter{i}=fspecial('log',2*ceil(2*scale)+1,scale); %keep the size odd
    %scale normalization sorce- "http://www.cs.unc.edu/~lazebnik/spring11/lec08_blob.pdf"
    filterresponse=((scale^2).*imfilter(img,filter{i},'replicate')).^2; 
    scale_space(:,:,i)=filterresponse;
    scale=scale*k;
    
end 
toc


    case 1 %faster working: do not change the filter size, downsize the image.
img_current=img;
tic
for i=(1:n)
    filter{i}=fspecial('log',2*ceil(2*scale)+1,scale); %keep the size odd
    %scale normalization source- "http://www.cs.unc.edu/~lazebnik/spring11/lec08_blob.pdf"
    filterresponse=(imfilter(img_current,filter{i},'replicate')).^2; 
    scale_space(:,:,i)=imresize(filterresponse,size(img));
    %downsize the image 
    if(i<n)
        img_current=imresize(img,1/(k^i));  
    end
end
toc
end 

%Performimg Non-maximum Suppression.
for i = (1:n)
    %nms- https://www.mathworks.com/help/images/ref/ordfilt2.html
    scale_space_temp(:,:,i)=ordfilt2(scale_space(:,:,i),9,ones(3,3)); % find maximum across all the levels 
end

[Maximum,I]=max(scale_space_temp,[],3);
for i=(1:n)
    scale_space(:,:,i) = (Maximum==scale_space(:,:,i)); % obtain the boolean values where the maximum exit at that particular level.
    scale_space(:,:,i) = scale_space(:,:,i).*img; % write intensity at the level were the max. was obtained.  
end 

[N,Index]=max(scale_space,[],3); % to find the index values and the CX and CY values.
si=size(N);
id=1;
for p=(1:si(1))
    for q=(1:si(2))
       
       if(N(p,q)>threshold) 
           x(id)=p;
           y(id)=q;
           rad(id)=3*Index(p,q); %to plot blobs proportional to the the sigma of the layer that the maximum was encountered at. 
           id=id+1;
       end
       
    end
end 

%modifying the passed parameters to match the required dimension of the provided show_all_circles function. 
show_all_circles(img,y',x',rad');
