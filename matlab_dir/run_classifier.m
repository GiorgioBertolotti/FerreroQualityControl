images = readlists();
crop_dataset(images);
separation = separate_types(images);
check_valid_images(separation.grids, 'grid');
check_valid_images(separation.beehives, 'beehive');

function images=readlists()
  f=fopen('images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:};
end