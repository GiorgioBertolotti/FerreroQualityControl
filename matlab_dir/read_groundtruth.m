function gt=read_groundtruth()
  f=fopen('labels.list');
  z = textscan(f,'%s');
  fclose(f);
  gt = z{:};
end