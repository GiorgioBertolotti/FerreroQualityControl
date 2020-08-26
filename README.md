# FerreroQualityControl

> **NOTE**: The presentation file is in Italian, since it was the submission of my Image Analysis exam.  
> The presentation of the project is [*Presentation.pdf*](Presentation.pdf).

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

- [x] <del>Rename dataset files to follow a standard (es. 01.jpg, 02.jpg, 03.jpg, ecc.)</del>
- [x] <del>Create groundtruth file</del>
- [x] <del>Add script for parsing of dataset and labels</del>
- [x] <del>Clean light illumination difference between images (equalization)</del>
- [x] <del>Extract box from the image</del>
- [x] <del>Rotate and stretch the box to fill the image</del>
- [x] <del>Implement the recognition of the valid/not valid boxes</del>
- [x] <del>Compare the results with the groundtruth</del>
