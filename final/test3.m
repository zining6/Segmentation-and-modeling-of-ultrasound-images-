%%image file
cross_section = "hengjiemian.png";
longitudinal_section = "17-48-21.jpg";
%%ellipse fitting
test = imread(cross_section);%load image
gray_test = rgb2gray(test); 

hist_img = histeq(gray_test);  

blur_img = imgaussfilt(hist_img,3); 

med_img = medfilt2(blur_img); 

BW_img = imbinarize(med_img); 
se1=strel('disk',15);  
se2=strel('square',15);

dilated_img = imdilate(BW_img,se1); 
erode_img = imerode(dilated_img,se2);

comp_img = imcomplement(erode_img); 

clear_img = imclearborder(comp_img,4); 

bwar_img = bwareafilt(clear_img,1); 

stats = regionprops(bwar_img,{'Centroid','Orientation','MajorAxisLength','MinorAxisLength'});%Ellipse fitting
                                                                                             %Centroid:Center of circle
                                                                                             %Orientation:Radian
                                                                                             %MajorAxisLength:y-axis diameter
                                                                                             %MinorAxisLength:x-axis diameter
                                                                                             
[w,center]= width(longitudinal_section);%w:a list with width of blood vessel
                                  %center:a list with center of the blood vessel

                                  
                                  
prop = w/(stats.MajorAxisLength/2);%The ratio of the longitudinal width of the pipe to the y-axis radius of the fitted ellipse
t = -pi:0.05:pi; %radians
x = stats.Centroid(1) + (stats.MinorAxisLength/2)*cos(t);%x:a list with x-axis coordinate of points on the fitted ellipse
y = stats.Centroid(2) + (stats.MajorAxisLength/2)*sin(t);%y:a list with y-axis coordinate of points on the fitted ellipse
wx = prop*(stats.MinorAxisLength/2);%wx:x-axis radius


nx=[];%list with m rows and n columns, m is pixel length of blood vessel, n is number of points on the fitted ellipse
      %each row has all x-axis coordinates of the points on the fitted ellipse
ny=[];%list with m rows and n columns, m is pixel length of blood vessel, n is number of points on the fitted ellipse
      %each row has all y-axis coordinates of the points on the fitted ellipse
z=[];%list with m rows and n columns, m is pixel length of blood vessel, n is number of points on the fitted ellipse
     %each row has all z-axis coordinates of the points on the fitted ellipse
for i = 1:size(w,2)
    for j=1:size(x,2)
        z(i,j)=i;
    end
    nx(i,:) = stats.Centroid(1) + wx(i)*cos(t); %Determine the x-axis coordinates of the point by the center, radius and radian
    if(i==1)
        ny(i,:) = stats.Centroid(2) + w(i)*sin(t); %Determine the y-axis coordinates of the point by the center, radius and radian
    else
        ny(i,:) = stats.Centroid(2) + center(i) - center(1) + w(i)*sin(t);
    end
end

fm = [];
c=1
for i = 1:size(w,2)
    for j = 1:size(x,2)
    %[X,Y,Z] = meshgrid(x(i),y(i),z(i));
    %F = X.^2 + Y.^2 + Z.^2;
    %gridsize = size(F);
    %surf(X,Y,Z);
    fm(c,1) = nx(i,j);
    fm(c,2) = ny(i,j);
    fm(c,3) = z(i,j);
    c=c+1;
    end
end

pc = pointCloud(fm);
pcwrite(pc, 'fm', 'PLYformat', 'binary');

%%surface
[t]=MyCrustOpen(fm);

figure(1);
set(gcf,'position',[0,0,1280,800]);
subplot(1,2,1)
hold on
axis equal
title('Points Cloud','fontsize',14)
plot3(fm(:,1),fm(:,2),fm(:,3),'g.')
axis vis3d
view(3)


figure(1)
subplot(1,2,2)
hold on
title('Output Triangulation','fontsize',14)
axis equal
trisurf(t,fm(:,1),fm(:,2),fm(:,3),'facecolor','r','edgecolor','[1 0.9 0.9]')%plot della superficie
axis vis3d
view(3)
