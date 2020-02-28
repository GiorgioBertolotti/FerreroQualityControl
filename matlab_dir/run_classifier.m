[images, labels] = readlists();
crop_dataset(images);
separation = separate_lists(images, labels);
check_valid_images(separation.grids, 'grid');
check_valid_images(separation.beehives, 'beehive');

function [images,labels]=readlists()
  f=fopen('images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f=fopen('labels2.list');
  l = textscan(f,'%s');
  fclose(f);
  labels = l{:};
end