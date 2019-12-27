[images, labels] = readlists();
equalize_dataset(images);
create_descriptor_files(images, labels);
load('descriptors.mat');
load('input.mat');
cv = cvpartition(labels, 'holdout', 0.2);
out_lbp = test_classifier(desc_lbp, labels, cv);