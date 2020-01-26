function plot_sides_alt(image, sides)
    figure, imshow(image), hold on;
    X=[1:size(image,2)];
    for i = 1:length(sides)
        side = sides(i);
        Y=(side.rho-X*cos(side.angle))/sin(side.angle);
        plot(X,Y,'r-', 'LineWidth', 1);
    end
end
