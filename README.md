# FerreroQualityControl

## Assignment

Il file con le richieste del progetto è [*Assignment.pdf*](Assignment.pdf).

## Task list

- [x] Rinominare files dataset secondo formato prevedibile (es. 01.jpg, 02.jpg, 03.jpg, ecc.)
- [x] Creare file con labels di groundtruth
- [x] Aggiungere script per parsing del dataset e delle labels
- [x] Ripulire differenze di illuminazione tra le immagini
- [x] Identificare texture scrivania
- [x] Estrarre dall'immagine la scatola di cioccolatini
- [x] Raddrizzare area tagliata contenente la scatola di cioccolatini
- [x] Implementazione di un descrittore per il riconoscimento delle scatole valide
- [ ] Tests con i classificatori
- [ ] Test di bontà confrontando con il groundtruth

## Functions

- *readlists()*: returns the list of filenames from *images.list* and the list of the labels of groundtruth from *labels.list*.
- *equalize_image(image)*: returns an RGB image with the histogram of the color channels equalized.
- *equalize_dataset(images)*: the input is the first list returned from *readlists()*, creates a folder *equalized_dataset* which contains the equalized images.
- *crop_image(image)*: returns an RGB image with the Ferrero box cropped.
- *crop_dataset(images)*: the input is the first list returned from *readlists()*, creates a folder *cropped_dataset* which contains the cropped images.