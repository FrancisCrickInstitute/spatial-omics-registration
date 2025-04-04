#@ File (label="Please specify the raw transforms directory", style="directory") rawTransDir
#@ File (label="Please specify the original omics outputs directory", style="directory") outputFilesDir
#@ File (label="Please specify the ROI directory", style="directory") roiDir
#@ File (label="Please specify the output directory", style="directory") outputDir

var DIM = 6788;


transTissuePosDir = outputDir + File.separator() + "Transformed_Tissue_Positions/";
origTissuePosDir = outputDir + File.separator() + "Original_Tissue_Positions/";

File.makeDirectory(transTissuePosDir);
File.makeDirectory(origTissuePosDir);

//verticalFlips = newArray(4, 8, 9, 10, 12, 16, 21, 23, 37, 40, 41, 42, 47, 50, 52, 121, 123, 125, 141);
//horizontalFlips = newArray(12, 21, 27, 40, 50, 56);

fileList = getFileList(rawTransDir);

//fileIndex = parseInt(getArgument());

//vFlip = arrayContains(verticalFlips, fileIndex + 1);
//hFlip = arrayContains(horizontalFlips, fileIndex + 1);
vFlip = false;
hFlip = false;

for(fileIndex = 0; fileIndex < fileList.length; fileIndex++){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Reading transform " + rawTransDir + File.separator() + fileList[fileIndex]);
	trans = File.openAsString(rawTransDir + File.separator() + fileList[fileIndex]);
	
	//slideOb = getSlideAndObIndices(fileList[fileIndex]);
	slideOb = getIndices(fileList[fileIndex]);
	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	//coordFilePath = "Slide" + IJ.pad(slideOb[0],2) + "_" + slideOb[1] + File.separator() + "spatial" + File.separator() + "tissue_positions_list.csv";
	coordFilePath = "Replicate" + slideOb[0] + "_" + slideOb[1] + File.separator() + "spatial" + File.separator() + "tissue_positions_list.csv";
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Reading tissue positions list " + outputFilesDir + File.separator() + coordFilePath);
	
	//File.copy(outputFilesDir + File.separator() + coordFilePath, origTissuePosDir + File.separator() + "slide" + IJ.pad(slideOb[0], 3) + "_ob" + slideOb[1] + "_original_tissue_positions_list.csv");
	File.copy(outputFilesDir + File.separator() + coordFilePath, origTissuePosDir + File.separator() + "replicate" + slideOb[0] + "_" + slideOb[1] + "_original_tissue_positions_list.csv");
	orig = File.openAsString(outputFilesDir + File.separator() + coordFilePath);
	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	//print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Reading ROI " + "slide" + IJ.pad(slideOb[0], 3) + "_ob" + slideOb[1] + ".tif_crop.txt");
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Reading ROI " + "replicate" + slideOb[0] + "_" + slideOb[1] + ".tif_crop.txt");
	//roi = File.openAsString(roiDir + File.separator() + "slide" + IJ.pad(slideOb[0], 3) + "_ob" + slideOb[1] + ".tif_crop.txt");
	roi = File.openAsString(roiDir + File.separator() + "replicate" + slideOb[0] + "_" + slideOb[1] + ".tif_crop.txt");
	
	origAsArray = split(orig, "\n");
	
	transAsArray = split(trans, "\n");
	
	roiAsArray = split(roi, "\n");
	
	roiCoords = parseRoiCoords(roiAsArray);
	
	//output = File.open(transTissuePosDir + File.separator() + "slide" + IJ.pad(slideOb[0], 3) + "_ob" + slideOb[1] + "_transformed_tissue_positions_list.csv");
	output = File.open(transTissuePosDir + File.separator() + "replicate" + slideOb[0] + "_" + slideOb[1] + "_transformed_tissue_positions_list.csv");
	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Transforming coordinates.");
	print("Horizontal Flip: " + hFlip + " Vertical Flip: " + vFlip);
	
	for (i = 0; i < origAsArray.length; i++) {
		line = split(origAsArray[i], ",");
		x = parseInt(line[5]);
		y = parseInt(line[4]);
		if(isInsideCrop(x, y, roiCoords)){
			transCoords = getTransCoords(x, y, transAsArray, roiCoords, hFlip, vFlip);
			print(output, line[0] + "," + line[1] + "," + line[2] + "," + line[3] + "," + transCoords[1] + "," + transCoords[0]);
		}
	}
	
	File.close(output);
}

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + ": Done");


function isInsideCrop(x, y, roiCoords){
	xRad = roiCoords[2] / 2;
	yRad = roiCoords[3] / 2;
	if(x > roiCoords[0] - xRad && x < roiCoords[0] + xRad && y > roiCoords[1] - yRad && y < roiCoords[1] + yRad){
		return true;
	} else {
		return false;
	}
}

function getTransCoords(x, y, transAsArray, roiCoords, hFlip, vFlip){
	xRad = roiCoords[2] / 2;
	yRad = roiCoords[3] / 2;
	xCropped = round(x - (roiCoords[0] - xRad));
	if (hFlip) xCropped = DIM - xCropped;
	if(xCropped >= DIM) xCropped = DIM - 1;
	if(xCropped < 0) xCropped = 0;
	yCropped = round(y - (roiCoords[1] - yRad));
	if (vFlip) yCropped = DIM - yCropped;
	if(yCropped >= DIM) yCropped = DIM - 1;
	if(yCropped < 0) yCropped = 0;
	xTransRow = split(transAsArray[yCropped + 4], " ");
	xTran = parseFloat(xTransRow[xCropped]);
	yTransRow = split(transAsArray[yCropped + DIM + 6], " ");
	yTran = parseFloat(yTransRow[xCropped]);
	//print("Original X: " + x + " ROI X: " + roiCoords[0] + " ROI X RAD: " + xRad + " X Cropped: " + xCropped + " X TRAN: " + xTran);
//	print("Original Y: " + y + " ROI Y: " + roiCoords[1] + " ROI Y RAD: " + yRad + " Y Cropped: " + yCropped + " Y TRAN: " + yTran);
	return newArray(xCropped + xCropped - xTran, yCropped + yCropped - yTran);
}

function parseRoiCoords(roiAsArray){
	roiLine = split(roiAsArray[1], ",");
	roiCoords = newArray(roiLine.length);
	for(i = 0; i < roiLine.length; i++){
		roiCoords[i] = parseFloat(roiLine[i]);
	}
	return roiCoords;
}

function getSlideAndObIndices(slideOb){
	slide = lengthOf("slide");
	ob = lengthOf("ob");
	index1 = indexOf(slideOb, "_");
	slideNumber = parseInt(substring(slideOb, slide, index1));
	index2 = indexOf(slideOb, ".tif");
	obNumber = 	parseInt(substring(slideOb, index1 + ob + 1, index2));
	return newArray(slideNumber, obNumber);
}


function getIndices(slideOb){
	slide = lengthOf("replicate");
	index1 = indexOf(slideOb, "_");
	slideNumber = parseInt(substring(slideOb, slide, index1));
	index2 = indexOf(slideOb, ".tif");
	obNumber = 	parseInt(substring(slideOb, index1 + 1, index2));
	return newArray(slideNumber, obNumber);
}

function arrayContains(dataArray, item){
	for(i = 0; i < dataArray.length; i++){
		if(item == dataArray[i]){
			return true;
		}
	}
	return false;
}
