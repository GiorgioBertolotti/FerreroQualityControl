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