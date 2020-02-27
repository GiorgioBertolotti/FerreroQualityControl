[images, labels] = readlists();
crop_dataset(images);
separation = separate_lists(images, labels);
check_valid_images(separation.grids, 'grid');
%check_valid_images(separation.beehives, 'beehive');
%{
create_descriptor_files(separation.grids, separation.grid_labels, 'grid');
load('descriptors.mat');
load('input.mat');
cv = cvpartition(labels, 'holdout', 0.3);
grids_result = test_classifier(desc_cd, labels, cv);
create_descriptor_files(separation.beehives, separation.beehive_labels, 'beehive');
load('descriptors.mat');
load('input.mat');
cv = cvpartition(labels, 'holdout', 0.3);
beehives_result = test_classifier(desc_cd, labels, cv);
%}