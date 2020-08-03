# FerreroQualityControl

The file with the presentation of the project is [*Presentazione.pdf*](Presentazione.pdf).

## Getting started

To start the program just run the function

    run_classifier()

it will create another folder named `cropped_dataset` containing the result of the cropping phase.  

Then it will analyze the cropped images and generate other 2 folders: `valid_images` and `not_valid_images`, containing 
the cropped images separated for validity.  
The images in `not_valid_images` also have red circles drawn on them to 
identify the problem which makes them not valid.

## Assignment

The file with the requirements of the project is [*Assignment.pdf*](Assignment.pdf).

## Task list

- [x] Rename dataset files to follow a standard (es. 01.jpg, 02.jpg, 03.jpg, ecc.)
- [x] Create groundtruth file
- [x] Add script for parsing of dataset and labels
- [x] Clean light illumination difference between images (equalization)
- [x] Extract box from the image
- [x] Rotate and stretch the box to fill the image
- [x] Implement the recognition of the valid/not valid boxes
- [x] Compare the results with the groundtruth
