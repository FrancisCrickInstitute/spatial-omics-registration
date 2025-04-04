# Batch Registration of Spatial Omics Data

These scripts are designed to automatically register a batch of images and tissue position coordinates associated with a spatial transcriptomics dataset, such as the [10x Visium platform](https://www.10xgenomics.com/products/spatial-gene-expression). This is achieved via a series of [FIJI scripts](https://imagej.net/scripting/). The process is divided into four steps, with a single script for each step. Generally, the output from one step provides the input for subsequent steps. All of the scripts should open in FIJI's script editor by simply using FIJI's default `File > Open...` command:

![image](https://github.com/user-attachments/assets/07ad699a-c4d1-4ed8-9ef1-7105c56b9387)

To run each script, select `Run > Run` from the script editor's menu bar, or click the Run button at the bottom of the editor:

![image](https://github.com/user-attachments/assets/91961ff2-2c90-4622-b521-74bdfa6d5bdb)

## Step 0: Download and Install FIJI

If you don't already have FIJI installed, you can download it [here](https://fiji.sc/).

## Step 1: Crop Images

Open the `Batch_Crop.ijm` script in FIJI and run it. You will be asked to specify an input and output directory:

![image](https://github.com/user-attachments/assets/ea0ea0bf-1961-4300-9344-baebfac606a5)

The input directory should be the location of the images to be cropped. In the case of the Visum platform, this will be the `Tiffs` directory. You can specify the output as whatever you like - this is where the cropped images will be saved.

## Step 2: Register Images

Open the `Batch_Registration.ijm` script in FIJI and run it. Again, you will be asked to specify an input and an output directory. The input directory should be the output from Step 1 above. You can specify the output as whatever you like - this is where the registered images will be saved. The registration is achieved using the FIJI plugin [BUnwarpJ](https://imagej.net/plugins/bunwarpj/).

## Step 3: Convert Transforms
## Step 4: Apply Transforms to Spatial Coordinates
