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
    lines = houghlines(BW,T,R,P,'FillGap',15,'MinLength',15);
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
    % get angles for the lines
    new_lines = [];
    for i = 1:length(lines)
        line.rho = lines(i).rho;
        line.theta = lines(i).theta;
        line.angle = line.theta*pi/180;
        found = 0;
        for j = 1:length(new_lines)
            if and(line.rho == new_lines(j).rho, line.theta == new_lines(j).theta)
                found = 1;
                break;
            end
        end
        if found == 0
            new_lines = [new_lines; line];
        end
    end
    lines = new_lines;
    % remove extra lines if there are more than 4
    if size(lines,1) > 4
        lines = sort_lines(lines);
        % filter lines with a similar angles until we find 4 sides matching
        % the conditions, the similarity is defined by the delta of the 
        % angle of two lines, it increases at every try
        max_delta = 10;
        new_lines = similar_theta_filtering(lines, max_delta);
        if size(new_lines,1) >= 4
            lines = new_lines;
        end
        num_cycles_smaller_than_4 = 0;
        num_cycles_bigger_than_4 = 0;
        while size(lines,1) > 4
            max_delta = max_delta + 1;
            new_lines = similar_theta_filtering(lines, max_delta);
            if size(new_lines,1) > 4
                if size(new_lines,1) < size(lines,1)
                    lines = new_lines;
                end
                num_cycles_bigger_than_4 = num_cycles_bigger_than_4 + 1;
                num_cycles_smaller_than_4 = 0;
                if num_cycles_bigger_than_4 > 5
                    extract_4_lines(lines);
                end
            elseif size(new_lines,1) < 4
                num_cycles_bigger_than_4 = 0;
                num_cycles_smaller_than_4 = num_cycles_smaller_than_4 + 1;
                if num_cycles_bigger_than_4 > 20
                    extract_4_lines(lines);
                end
            else
                lines = new_lines;
            end
        end
    end
    out = lines;
end

function out=similar_theta_filtering(lines, max_delta_theta)
    similar_thetas = {};
    % group the lines based on similar angles
    for i = 1:length(lines)
        line = lines(i);
        if isempty(similar_thetas)
            similar_thetas = {[line]};
        else
            found = 0;
            for j = 1:length(similar_thetas)
                for m = 1:length(similar_thetas{j})
                    delta_theta = abs(similar_thetas{j}(m).theta - line.theta);
                    if delta_theta < max_delta_theta
                        similar_thetas{j} = [similar_thetas{j}, line];
                        found = 1;
                        break;
                    end
                end
                if found == 1
                    break;
                end
            end
            if found == 0
                similar_thetas{end+1} = [line];
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
                line = similar_thetas{i}(j);
                if line.rho < min_rho.rho
                    min_rho = line;
                end
                if line.rho > max_rho.rho
                    max_rho = line;
                end
            end
            % but if there's another line close to the max or to the min with a
            % more similar angle to the opposite line then pick that
            for j = 1:length(similar_thetas{i})
                line = similar_thetas{i}(j);
                if and(or(line.rho ~= min_rho.rho, line.theta ~= min_rho.theta),...
                        or(line.rho ~= max_rho.rho, line.theta ~= max_rho.theta))
                    delta_theta_max_min = abs(min_rho.theta - max_rho.theta);
                    if abs(line.rho - min_rho.rho) < 100
                        delta_theta_new_line = abs(line.theta - max_rho.theta);
                        if delta_theta_new_line < delta_theta_max_min
                            min_rho = line;
                        end
                    end
                    if abs(line.rho - max_rho.rho) < 100
                        delta_theta_new_line = abs(line.theta - min_rho.theta);
                        if delta_theta_new_line < delta_theta_max_min
                            max_rho = line;
                        end
                    end
                end
            end
            similar_thetas{i} = [min_rho, max_rho];
        end
    end
    % remove lines that have no other lines with similar theta if there
    % are at least 4 sides
    count = 0;
    for i = 1:length(similar_thetas)
        count = count + length(similar_thetas{i});
    end
    if count > 4
        for i = 1:length(similar_thetas)
            if length(similar_thetas{i}) < 2
                similar_thetas{i} = [];
            end
        end
    end
    % add back lines to main array
    lines = [];
    for i = 1:length(similar_thetas)
        for j = 1:length(similar_thetas{i})
            lines = [lines; similar_thetas{i}(j)];
        end
    end
    out = lines;
end

function out=extract_4_lines(lines)
    % find 4 starting lines
    new_lines = [];
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
            if and(new_lines(j).rho == lines(i).rho, new_lines(j).theta == lines(i).theta)
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
    out = new_lines;
end

function out=sort_lines(lines)
    table = struct2table(lines);
	sorted_table = sortrows(table, 'theta');
	out = table2struct(sorted_table);
end