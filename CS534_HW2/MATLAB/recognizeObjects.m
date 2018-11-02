function output_img = recognizeObjects(orig_img, labeled_img, obj_db)

    % get the model image information
	[model_db, model_img] = compute2DProperties(orig_img, labeled_img);  
    % get how many objects in each model image and target image
	num_model_obj = size(obj_db, 2);
	num_obj = size(model_db, 2); 
	fig = figure();
	imshow(orig_img);
    hold on;

	for i = 1 : num_model_obj
		for j=1 : num_obj
			% use feature roundness to find the identical objects
			roundness_target = obj_db(6, i);
			roundness_model = model_db(6, j);
			if((roundness_target / roundness_model) <= 1.06 && (roundness_target / roundness_model) >= 0.94)
                theta = model_db(5,j);
		        y_init = model_db(2,j);
		        x_init = model_db(3,j);
                plot(y_init, x_init, 'ws', 'MarkerFaceColor', [1 1 1]);
                x_end = x_init + cos(theta) * 50;
                y_end = y_init + sin(theta) * 50;
                plot([y_init y_end], [x_init x_end]);
			end
		end
    end
 	output_img = saveAnnotatedImg(fig);
 	delete(fig);
 end

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
% has some platform depend issues. we should calling
% getframe twice in a row and adding a pause afterwards make getframe work
% as expected. This is just a walkaround. 
annotated_img = frame.cdata;
end