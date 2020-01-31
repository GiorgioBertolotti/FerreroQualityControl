# FerreroQualityControl

## Assignment

The file with the requirements of the project is [*Assignment.pdf*](Assignment.pdf).

## Task list

- [x] Rename dataset files to follow a standard (es. 01.jpg, 02.jpg, 03.jpg, ecc.)
- [x] Create groundtruth labels file
- [x] Add script for parsing of dataset and labels
- [x] Clean light illumination difference between images (equalization)
- [x] Extract box from the image
- [x] Rotate and stretch the box to fill the image
- [x] Implement a descriptor for the recognition of the valid/not valid boxes
- [ ] Test the descriptor comparing with the groundtruth labels

## Functions

- *readlists()*: returns the list of filenames from *images.list* and the list of the labels of groundtruth from *labels.list*.
- *equalize_image(image)*: returns an RGB image with the histogram of the color channels equalized.
- *equalize_dataset(images)*: the input is the first list returned from *readlists()*, creates a folder *equalized_dataset* which contains the equalized images.
- *crop_image(image)*: returns an RGB image with the Ferrero box cropped.
- *crop_dataset(images)*: the input is the first list returned from *readlists()*, creates a folder *cropped_dataset* which contains the cropped images.
- *separate_lists(images, labels)*: returns a structure containing the list of images (and relative labels) of type grid and the list of images (and relative labels) of type beehive.
- *check_valid_images(images, type)*: creates two folder for valid and not_valid images and separates the input images in this two folders.
