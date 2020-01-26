[images, labels] = readlists();
crop_dataset(images);
create_descriptor_files(images, labels);
load('descriptors.mat');
load('input.mat');
cv = cvpartition(labels, 'holdout', 0.3);
out_cd = test_classifier(desc_cd, labels, cv);