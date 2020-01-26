function plot_sides(image, sides)
    figure, imshow(image), hold on;
    for i = 1:length(sides)
       xy = [sides(i).point1; sides(i).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
end
