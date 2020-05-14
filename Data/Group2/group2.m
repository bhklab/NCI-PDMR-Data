A = imread('/Users/deniskeimakh/Desktop/Group2/114868~125-R~0.jpg'); %load jpg;
A = rgb2gray(A);
figure(1), imagesc(A), axis image, colormap(gray) %display image

[x_pix,y_pix] = ginput; %select origin, then top right corner

prompt = 'What is the x range? ';  %[18,128];
x_range = input(prompt)

prompt = 'What is the y range? '; % [0,1300]
y_range = input(prompt)

data_points_pix = [];

for i = 4:size(A,1)-3
    for j = 4:size(A,2)-3
        if mean(mean(A(i-3:i+3,j-3:j+3)))<120  %this line changes based on data point "look"
            too_close = 0;
            for k = 1: size(data_points,1)
                distance = sqrt((data_points(k,1)-i)^2 + (data_points(k,2)-j)^2);
                if distance < 10
                    too_close =1
                end
            end
            if too_close == 0
            data_points_pix = [data_points_pix;j,i];
            end
        end
    end
end

data_points = zeros(size(data_points_pix,1),2);
for i = 1:size(data_points_pix)
data_points(i,:) = [((data_points_pix(i,1)-x_pix(1))/(x_pix(2)-x_pix(1)))*(x_range(2)-x_range(1)) + x_range(1),...
    ((data_points_pix(i,2)-y_pix(1))/(y_pix(2)-y_pix(1)))*(y_range(2)-y_range(1)) + y_range(1)];
end
