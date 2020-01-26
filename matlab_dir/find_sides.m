function out=find_sides(equalized_image)
    % use a threshold to get a mask with the box sides
    ycbcr = rgb2ycbcr(equalized_image);
    CR = ycbcr(:,:,3);
    T = 110/255;
    mask1 = CR < T;
    mask1 = medfilt2(mask1);
    % process mask edges and detect lines with hough
    BW = edge(mask1,'canny');
    [H,T,R] = hough(BW);
    P = houghpeaks(H,6,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    %{
    % uncomment to plot all lines
    figure, imshow(equalized_image), hold on;
    for i = 1:length(lines)
       xy = [lines(i).point1; lines(i).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    %}
    % get only the lines longer then 50 pixels
    new_lines = [];
    for i = 1:length(lines)
       len = norm(lines(i).point1 - lines(i).point2);
       if len > 50
           new_lines = [new_lines; lines(i)];
       end
    end
    lines = new_lines;
    % unify close lines with same angle
    new_lines = [];
    for i = 1:length(lines)
        found = 0;
        for j = 1:length(new_lines)
            if and(new_lines(j).theta == lines(i).theta, abs(new_lines(j).rho - lines(i).rho) < 100)
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
    % remove extra lines if there are more than 4
    if length(lines) > 4
        similar_thetas = {};
        % group the lines based on similar angles
        for i = 1:length(lines)
            if isempty(similar_thetas)
                similar_thetas = {[lines(i)]};
            else
                found = 0;
                for j = 1:length(similar_thetas)
                    delta_theta = abs(similar_thetas{j}(1).theta - lines(i).theta);
                    if delta_theta < 15
                        similar_thetas{j} = [similar_thetas{j}, lines(i)];
                        found = 1;
                        break;
                    end
                end
                if found == 0
                    similar_thetas{end+1} = [lines(i)];
                end
            end
        end
        % if there are more than two lines with similar angles pick the
        % most external two
        for i = 1:length(similar_thetas)
            if length(similar_thetas{i}) > 2
                min_rho = similar_thetas{i}(1);
                max_rho = similar_thetas{i}(1);
                for j = 2:length(similar_thetas{i})
                    if similar_thetas{i}(j).rho < min_rho.rho
                        min_rho = similar_thetas{i}(j);
                    end
                    if similar_thetas{i}(j).rho > max_rho.rho
                        max_rho = similar_thetas{i}(j);
                    end
                end
                similar_thetas{i} = [min_rho, max_rho];
            end
        end
        % add back lines to main array
        lines = [];
        for i = 1:length(similar_thetas)
            for j = 1:length(similar_thetas{i})
                lines = [lines; similar_thetas{i}(j)];
            end
        end
        % if there are still more than 4 lines
        if length(lines) > 4
            % find 4 starting lines
            for i = 1:length(lines)
                count = 0;
                for j = 1:length(new_lines)
                    delta_theta = abs(new_lines(j).theta - lines(i).theta);
                    if delta_theta < 5
                        count = count + 1;
                    end
                end
                if count < 2
                    new_lines = [new_lines; lines(i)];
                end
                if length(new_lines) == 4
                    break;
                end
            end
            % check if there are better lines in the others
            for i = 1:length(lines)
                there_is = false;
                for j = 1:length(new_lines)
                    if and(new_lines(j).point1 == lines(i).point1, new_lines(j).point2 == lines(i).point2)
                        there_is = true;
                        break;
                    end
                end
                if ~there_is
                    for j = 1:length(new_lines)
                        delta_theta = abs(new_lines(j).theta - lines(i).theta);
                        delta_rho = abs(new_lines(j).rho - lines(i).rho);
                        if and(delta_theta < 5, delta_rho > 100)
                            new_lines(j) = lines(i);
                            break;
                        end
                    end
                end
            end
            lines = new_lines;
        end
    end
    out = lines;
end
