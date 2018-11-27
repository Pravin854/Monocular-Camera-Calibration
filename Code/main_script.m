clc;
close all;

% Read Images from the folder
img1 = imread('../images/img1.png');
img2 = imread('../images/img2.png');
img3 = imread('../images/img3.png');

%Extracting corners of the checker board 
[imagePoints1,boardSize1] = detectCheckerboardPoints(img1);
[imagePoints2,boardSize2] = detectCheckerboardPoints(img2);
[imagePoints3,boardSize3] = detectCheckerboardPoints(img3);

% generating ground truth
box_size = 2.4;
k = 1;
board = zeros(48,2);
sz = boardSize1 - 1;

for i=1:sz(2)
    for j= 1:sz(1)
        board(k, 2) = box_size*(j-1);
        board(k, 1) = box_size*(i-1);
        board(k, 3) = 1;
        k = k + 1;
    end
end

Mx = [];
My = [];

% For img1 

% Generating M matraix 
for i=1:48
    
    x = imagePoints1(i, 1);
    y = imagePoints1(i, 2);
    Mx(i,:) = [-board(i,1), -board(i,2), -1, 0, 0, 0, x*board(i,1), x*board(i,2), x];
    My(i,:) = [0, 0, 0, -board(i,1), -board(i,2), -1, y*board(i,1), y*board(i,2), y];

end

M  = [];
for i = 1:48 
    M = [M;Mx(i,:);My(i,:)];
end

% Singular Value Decomposition
[U,S,V] = svd(M);
V = V';
h = V(9,:);
hom1 = [h(1:3); h(4:6); h(7:9)];
hom1 = hom1 / h(9);

% For image 2

% Generating M matrix
M = ones(2 * 48, 9);
for i=1:48
    x = imagePoints2(i, 1);
    y = imagePoints2(i, 2);
    M(2*i-1,:) = [-board(i,1), -board(i,2), -1, 0, 0, 0, x*board(i,1), x*board(i,2), x];
    M(2*i,:) = [0, 0, 0, -board(i,1), -board(i,2), -1, y*board(i,1), y*board(i,2), y];
end

% Singular Value Decomposition
[U,S,V] = svd(M);
V = V';
h = V(9,:);
hom2 = [h(1:3); h(4:6); h(7:9)];
hom2 = hom2 / h(9);

% For image 3

%Generating M matrix
M = ones(2 * 48, 9);
for i=1:48
    x = imagePoints3(i, 1);
    y = imagePoints3(i, 2);
    Mx(i,:) = [-board(i,1), -board(i,2), -1, 0, 0, 0, x*board(i,1), x*board(i,2), x];
    My(i,:) = [0, 0, 0, -board(i,1), -board(i,2), -1, y*board(i,1), y*board(i,2), y];
end

M  = [];
for i = 1:48 
    M = [M;Mx(i,:);My(i,:)];
end

%Singular Value Decomposition
[U,S,V] = svd(M);
V = V';
h = V(9,:);
hom3 = [h(1:3); h(4:6); h(7:9)];
hom3 = hom3 / h(9);



% Calculating V matrix

% Calculating V12
V12_img1 = exp_constraints(1,2,hom1);
V12_img2 = exp_constraints(1,2,hom2);
V12_img3 = exp_constraints(1,2,hom3);

% Calculating V11
V11_img1 = exp_constraints(1,1,hom1);
V11_img2 = exp_constraints(1,1,hom2);
V11_img3 = exp_constraints(1,1,hom3);

% Calculating V22
V22_img1 = exp_constraints(2,2,hom1);
V22_img2 = exp_constraints(2,2,hom2);
V22_img3 = exp_constraints(2,2,hom3);

V1_mat = [V12_img1'; V11_img1' - V22_img1'];
V2_mat = [V12_img2'; V11_img2' - V22_img2'];
V3_mat = [V12_img3'; V11_img3' - V22_img3'];

V = [V1_mat;V2_mat;V3_mat];

% Calculating B matrix
[U,S,V] = svd(V);
V = V';
b=V(6,:);
B = [b(1), b(2), b(3) ; b(2),b(4), b(5); b(3),b(5), b(6)];

% Cholesky Decomposition
 cholesky_decomposition = chol(B, 'upper');
 
% Finding K matrix
 K = pinv((cholesky_decomposition'));
 K = K'/K(3,3);
 fprintf('K matrix \n')
 disp(K);
 
 %%%%%%%%%%%%%%%%%%%% Bonus 1 %%%%%%%%%%%%%%%%%%
 
 % Rotation | Translation matrix for all images
 R_T_img1 = rot_trans_matrix(K,hom1);
 R_T_img2 = rot_trans_matrix(K,hom2);
 R_T_img3 = rot_trans_matrix(K,hom3);
 
 fprintf('Image1 R|t matrix \n')
 disp(R_T_img1);
 fprintf('Image2 R|t matrix \n')
 disp(R_T_img2);
 fprintf('Image3 R|t matrix \n')
 disp(R_T_img3);
 
 
 figure;
 imshow(img1);  % Display image
 hold on;
 plot(imagePoints1(:,1,1),imagePoints1(:,2,1),'ro');  % Display points on image
 hold off;
 figure;
 imshow(img2);  % Display image
 hold on;
 plot(imagePoints2(:,1,1),imagePoints2(:,2,1),'ro');  % Display points on image
 hold off;
 figure;
 imshow(img3);  % Display image
 hold on;
 plot(imagePoints3(:,1,1),imagePoints3(:,2,1),'ro');  % Display points on image
 hold off;
 
%%%%%%%%%% Bonus 2 %%%%%%%%%%%%
 
K_int = intrinsic_eval(); % This function displays the usual method 
                          % by which people find out intrinsic parameters
                          % of the camera
 
 
 