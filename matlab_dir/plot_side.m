function plot_side(image, side)
    figure, imshow(image), hold on;
    X=[1:size(image,2)];
    Y=(side.rho-X*cos(side.angle))/sin(side.angle);
    plot(X,Y,'r-', 'LineWidth', 1);
end
