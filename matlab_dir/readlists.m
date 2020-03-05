function images=readlists()
  f=fopen('images.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:};
end