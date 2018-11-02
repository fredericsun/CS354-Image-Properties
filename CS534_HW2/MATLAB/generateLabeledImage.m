function labeled_img = generateLabeledImage(gray_img, threshold)

bw_img = im2bw(gray_img, threshold);
[bw_label, num] = bwlabel(bw_img);

labeled_img = bw_label;
return