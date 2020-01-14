function out=find_sides(equalized_image)
    % use a threshold on CR channel to get a mask of the box
    ycbcr = rgb2ycbcr(equalized_image);
    CR = ycbcr(:,:,3);
    T = 100/255;
    mask1 = CR < T;
    mask1 = medfilt2(mask1);
    BW = edge(mask1,'canny');
    [H,theta,rho] = hough(BW);
    P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(BW,theta,rho,P,'FillGap',5,'MinLength',7);
    new_lines = [];
    for i = 1:length(lines)
       %{
       xy = [lines(i).point1; lines(i).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
       %}
       % Determine the endpoints of the longest line segment
       len = norm(lines(i).point1 - lines(i).point2);
       if len > 50
           new_lines = [new_lines; lines(i)];
       end
    end
    lines = new_lines;
    new_lines = [];
    for i = 1:length(lines)
        found = 0;
        for j = 1:length(new_lines)
            if new_lines(j).theta == lines(i).theta
                new_lines(j).point2 = lines(i).point2;
                found = 1;
                break;
            end
        end
        if found == 0
            new_lines = [new_lines; lines(i)];
        end
    end
    lines = new_lines;
    if length(lines) > 4
        new_lines = [lines(1); lines(2); lines(3); lines(4)];
        for i = 5:length(lines)
            for j = 1:length(new_lines)
                delta_theta = abs(new_lines(j).theta - lines(i).theta);
                delta_rho = abs(new_lines(j).rho - lines(i).rho);
                if and(delta_theta < 5, delta_rho < 100)
                    if lines(i).rho > new_lines(j).rho
                        new_lines(j) = lines(i);
                    end
                    break;
                end
            end
        end
        lines = new_lines;
    end
    out = lines;
end
