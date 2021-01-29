function [w,center] = width(image)

test = imread(image);%load image
gray_test = rgb2gray(test);
gray_test = imgaussfilt(gray_test, 2);
hist_test = imhist(gray_test);

total = size(gray_test,1) * size(gray_test,2);%total pixels of the image

level = otsu_new(hist_test, total);%threshold

binary_image = []
for i = 1:size(gray_test,1) %get the binary image by threshold
   for j = 1:size(gray_test,2)
       if gray_test(i,j)>level
           binary_image(i,j) = -1;
       else
           binary_image(i,j) = 1;
       end
   end
end

[m, n, z] = size(test);


[L,N] = superpixels(test,800);%L:the superpixel image
                              %N:then number of labels
                              
BM = boundarymask(L);%add edges to the superpixel image
imshow(imoverlay(test,BM,'cyan'),'InitialMagnification',67)%show the superpixel image with edges
h=drawfreehand('Color','w');%draw circle to select the vessel region of the image
pos = ceil(h.Position);%coordinates of the region you selected
[x_pos,y_pos] = size(pos);%x_pos:number of pixels selected by drawing circle
                          %y_pos:2

%---------------------------------------- 
%Traverse the super pixel image to find the target area
%---------------------------------------- 
marker = zeros(1,N);%a list with N zero elements,the index of elements represent the label of the superpixel image
                    %if the element is 1, means the pixels with label 'index' are selected
                    %if the element is 0, means the pixels with label 'index' are not selected
BW = zeros(m,n);%the binary image

for i = 1:x_pos
    x_axis = pos(i,1);%the x-axis coordinate of the pixel
    y_axis = pos(i,2);%the y-axis coordinate of the pixel
    flag = L(y_axis,x_axis);%flag: the label of the pixel
    marker(1,flag) = 1;%mark the area with label 'flag' are selected
end
%---------------------------------------- 
%Convert selected area to binary image
%---------------------------------------- 
for i = 1:N %change the selected part to 1 in BW
    if marker(1,i) == 1
        for j = 1:m
            for q = 1:n          
                if L(j,q) == i
                    BW(j,q) = 1;
                end
                
            end
        end
    end
end

%---------------------------------------- 
%Combine the image segmented by the threshold with the image segmented by the super pixel
%---------------------------------------- 
comb = BW + binary_image;
for i = 1:size(comb,1)
    for j = 1:size(comb,2)
        if comb(i,j) <= 1
            comb(i,j) = 1;
        else
            comb(i,j) = 0;
        end
    end
end

for i = 1:size(comb,1)
    for j = 1:size(comb,2)
        if comb(i,j) == 1
            comb(i,j) = 0;
        else
            comb(i,j) = 1;
        end
    end
end

[B,L] = bwboundaries(comb);

for k = 1:length(B)
    boundary = B{k};
end

coordinate = [];

for i = 1:size(L,1)%Confirm the label of the blood vessel
   if L(i,1)==L(i,end) && L(i,1)>0
        area = L(i,1)%the label of the blood vessel
   end
end

c = 1;

%Store the pixel coordinates contained in the blood vessel in the coordinate
for i = 1:size(L,1)
   for j = 1:size(L,2)
       if L(i,j) == area
           coordinate(c,1) = j;
           coordinate(c,2) = i;
           coordinate(c,3) = 0;
           c = c+1;
       end
   end
end

w=[]%store all widths of blood vessel
center=[]%store centers of blood vessel

for i = 1:size(gray_test, 2)%let the upper bound pixel's ordinate minus lower bound pixel's ordinate of the blood vessel to get the width
    points = coordinate(coordinate(:,1) == i,:);
    w_i = (points(end, 2) - points(1, 2))/2;
    w(i) = w_i;
end

for i = 1:size(w, 2)%let the upper bound pixel's ordinate plus the width/2 to get the center of blood vessel
    points = coordinate(coordinate(:,1) == i,:);
    center(i) = points(1,2) + w(i);
end

fileID = fopen('coordinate.ply','w');
formatSpec = '%d %d %d\n';
fprintf(fileID, formatSpec, coordinate);
fclose(fileID);

pc = pointCloud(coordinate);
pcwrite(pc, 'test', 'PLYformat', 'binary');
