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
