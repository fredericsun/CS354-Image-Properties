function [db, out_img] = compute2DProperties(orig_img, labeled_img)

    num_object = max(max(labeled_img));
    db = zeros(6, num_object);
    % loop for every object
    for i = 1 : size(db, 2)
        % segment out label image of the object
        seg_label = labeled_img;
        [rows, cols] = size(seg_label);
        for col = 1 : cols
            for row = 1 : rows
                if seg_label(row, col) ~= i 
                    seg_label(row, col) = 0;
                end
            end
        end

        % Object Label (1)
        db(1, i) = i; % store in the database

        % Center of Area (2, 3)
        [COL, ROW] = find(seg_label > 0);
        A = length([COL ROW]); %Area of the object
        center_col = sum(COL) / A;
        center_row = sum(ROW) / A;
        db(2, i) = center_row; % store in the database
        db(3, i) = center_col; 

        % Orientation (tan(2theta) = b/a-c) (5)
        a = sum((COL - center_col).^2);
        c = sum((ROW - center_row).^2);
        b = 2 * sum((COL - center_col).* (ROW - center_row));
        theta = atan2(b , a - c) / 2;
        db(5, i) = theta; % store in the database

        % Minimum Moment of Inertia (4)
        % Equation: E = asin(theta)^2 - bsin(theta)cos(theta) + ccos(theta)^2
        Moment_min = a*sin(theta)^2 - b*sin(theta)*cos(theta) + c*cos(theta)^2;
        Moment_max = a*sin(theta + pi / 2)^2 - b*sin(theta + pi / 2)*cos...
        (theta + pi / 2) + c*cos(theta + pi / 2)^2;
        db(4, i) = Moment_min; % store in the database

        % Roundness (6)
        r = Moment_min / Moment_max;
        db(6, i) = r; % store in the database  
    end
    %annotate image
    fig = figure();
    imshow(orig_img);
    hold on; plot(db(2,:), db(3,:),  'ws', 'MarkerFaceColor', [1 1 1]);

    for i = 1 : num_object
        a = db(5, i);
        x_init = db(3, i);
        y_init = db(2, i);
        % 50 is the length of the segment line we will draw
        x_end = x_init + cos(a) * 50;
        y_end = y_init + sin(a) * 50;
        plot([y_init y_end], [x_init x_end]);
    end

    out_img = saveAnnotatedImg(fig);  
    delete(fig);
end

%% Get the method from 'demoMATLABTricksFun.m'
function annotated_img = saveAnnotatedImg(fh)
figure(fh); % Shift the focus back to the figure fh

% The figure needs to be undocked
set(fh, 'WindowStyle', 'normal');

% The following two lines just to make the figure true size to the
% displayed image. The reason will become clear later.
img = getimage(fh);
truesize(fh, [size(img, 1), size(img, 2)]);

% getframe does a screen capture of the figure window, as a result, the
% displayed figure has to be in true size. 
frame = getframe(fh);
frame = getframe(fh);
pause(0.5); 
% Because getframe tries to perform a screen capture. it somehow 
% has some platform depend issues. we should callin
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;
end

