function [ A ] = wbc_vogado( f )
%% made some edit, to make more easy to debug 
% original source code by @lhvogado at Aug 31, 2019
% modified by @elybin at Apr 10, 2020

show_detailed_figure = false;

image_rgb = f;  % kim edit in 10/04/2020 - 8:11pm WIB

transforma = makecform('srgb2lab');
lab = applycform(f,transforma);
L = lab(:,:,1);
A = lab(:,:,2);
B = lab(:,:,3);
lab_y = B; % kim edit

AD = imadd(L,B);
f = im2double(f);
r = f(:,:,1);

r = imadjust(r);



g = f(:,:,2);
g = imadjust(g);
b = f(:,:,3);
b = imadjust(b);
c = 1-r;
c = imadjust(c);
m = 1-g;

cmyk_m = m; % kim edit

m = medfilt2(m, [7 7]); % updated in 13/04/2016 - 6:15

cmyk_m_con_med  = m;

    
m = imadjust(m);
m = imadjust(m);

y = 1-b;
y = imadjust(y);
AD = mat2gray(B);
AD = medfilt2(AD, [7 7]); 

lab_y_con_med = AD; % kim edit 


sub = imsubtract(m,AD);
img_subt = sub; % kim edit 

CMY = cat(3,c,m,y);
F = cat(3,r,g,b);
% imshow(sub);
%%
LEN = 21;
THETA = 11;
PSF = fspecial('motion', LEN, THETA);
wnr1 = deconvwnr(sub,PSF,0);
% figure, imshow(wnr1);
%%
ab = double(CMY(:,:,1:3));
nrows = (size(ab,1));
ncols = (size(ab,2));
ab = reshape(ab,nrows*ncols,3);

nrows = (size(c,1));
ncols = (size(c,2));
[x, y] = size(c);
data = [sub(:)];
nColors = 3; % Quantidade de grupos

[cluster_idx, cluster_center] = kmeans(data, nColors, 'distance','sqEuclidean',...
  'Replicates',4);%Aplico o Kmeans


pixel_labels = reshape(cluster_idx, nrows, ncols);
mean_cluster_value = mean(cluster_center,2);
[tmp, idx] = sort(mean_cluster_value);
nuclei_cluster = idx(3);
[u,v] = size(c);
for i = 1:u
    for j = 1:v
           if pixel_labels(i,j) == nuclei_cluster
              A(i,j) = 1; 
           else
              A(i,j) = 0;
           end 
    end
end



img_clustering = A; % kim edit 
img_clustering = bwareaopen(img_clustering, 0);

se = strel('disk',2);
se1 = strel('ball',1,1);

A = imdilate(A,se1);
A = imerode(A,se);
A = bwareaopen(A, 800); % vogado mention he use 800px
% figure, imshow(A);

% adding morphological operator that missing 
% removing object regions with fewer than 800px

img_morpho = A; % kim edit

%% more deatiled image
if(show_detailed_figure)
    subplot(2,4,1);
    imshow(image_rgb);
    title('(a) Original', 'FontSize', 8);

    subplot(2,4,2);
    imshow(cmyk_m);
    title('(b) M from CMYK', 'FontSize', 8);


    subplot(2,4,3);
    imshow(lab_y);
    title('(c) *b from CIELAB', 'FontSize', 8);


    subplot(2,4,4);
    imshow(cmyk_m_con_med);
    title('(d) M con adj + med(7x7)', 'FontSize', 8);

    subplot(2,4,5);
    imshow(lab_y_con_med);
    title('(e) *b con adj + med(7x7)', 'FontSize', 8);

    subplot(2,4,6);
    imshow(img_subt);
    title('(f) *b - M', 'FontSize', 8);

    subplot(2,4,7);
    imshow(img_clustering);
    title('k-means', 'FontSize', 8);

    subplot(2,4,8);
    imshow(img_morpho);
    title('(g)  Morphological Ops.', 'FontSize', 8);
end % end if
end
