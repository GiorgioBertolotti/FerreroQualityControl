function out=classify_beehives()
    [images, labels] = readlists();
    desc_cd = create_descriptor_files(images);
    cv = cvpartition(labels, 'holdout', 0.3);
    out = test_classifier(desc_cd, labels, cv);
end

function [images,labels]=readlists()
  f=fopen('beehives.list');
  z = textscan(f,'%s');
  fclose(f);
  images = z{:}; 

  f=fopen('beehives.labels');
  l = textscan(f,'%s');
  fclose(f);
  labels = l{:};
end

function out=create_descriptor_files(images)
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        desc_cd = [];
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            eq_image = equalize_image(image);
            cd = compute_lbp(eq_image);
            desc_cd = [desc_cd; cd];
        end
        out = desc_cd;
    end
end

function out = test_classifier(descriptor, labels, cv)
  % Testa un classificatore dati descrittori, etichette e partizionamento.
  % Parametri: 
  %   descriptor : descrittore/i da usare per la classificazione
  %   labels : etichette delle immagini
  %   cv : output di cvpartition con le partizioni train set / test set
  
  train_values = descriptor(cv.training(1),:);
  train_labels = labels(cv.training(1));
  
  test_values  = descriptor(cv.test(1),:);
  test_labels  = labels(cv.test(1));
  
  c = fitcknn(train_values, train_labels, 'NumNeighbors', 7);
  
  train_predicted = predict(c, train_values);
  out.train_perf = confmat(train_labels, train_predicted);

  test_predicted = predict(c, test_values);
  out.test_perf = confmat(test_labels, test_predicted);
    
end