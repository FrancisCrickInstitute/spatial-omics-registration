
#@ File (label="Please specify the input directory", style="directory") inputDirectory
#@ File (label="Please specify the output directory", style="directory") outputDirectory

roiDirectory = outputDirectory + File.separator() + "rois";

File.makeDirectory(roiDirectory);

var smallestDim = 6788;
var FOREGROUND = 255;
var FILL_VALUE = 230;
var MIN_AREA = 100000;

macro "Batch_Crop"{

	setBatchMode(true);

//	i = parseInt(getArgument());

	fileList = getFileList(inputDirectory);
	
	for(i = 0; i < fileList.length; i++){
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second);
		if(indexOf(toLowerCase(fileList[i]), "small") >= 0){
			print("Invalid file name - exiting");
			exit();
		}
	
		print("Opening " + inputDirectory + File.separator() + fileList[i]);
		open(inputDirectory + File.separator() + fileList[i]);
		input = getTitle();
	
		selectWindow(input);
		
		centroid = getCentreOfMass(input, i);
	
		run("Specify...", "width=" + smallestDim + " height=" + smallestDim + " x=" + centroid[0] + " y=" + centroid[1] + " centered");
		run("Crop");
		run("Select None");
	
		print("Saving " + outputDirectory + File.separator() + input);
		saveAs("Tiff", outputDirectory + File.separator() + input);
	
		print("Saving " + roiDirectory + File.separator() + input + "_crop.txt");
		f = File.open(roiDirectory + File.separator() + input + "_crop.txt");
		print(f, "x,y,width,height");
		print(f, centroid[0] + "," + centroid[1] + "," + smallestDim + "," + smallestDim);
		File.close(f);
	}
	print("Done");
	
	setBatchMode(false);
}

function getCentreOfMass(input, index){
	print("Finding centre of mass...");
	run("Set Measurements...", "area center display redirect=None decimal=3");
	selectWindow(input);
	run("Duplicate...", " ");
	run("8-bit");
	removeBlack(getTitle());
	setAutoThreshold("Triangle");
	run("Convert to Mask");
	mask1 = getTitle();
	run("Analyze Particles...", "size=" + MIN_AREA + "-Infinity show=Masks display exclude clear");
	//print("Saving " + debugDir + File.separator() + "corrArea_input_Mask_" + index + ".png");
	//saveAs("PNG", debugDir + File.separator() + "getCentreOfMass_Mask_" + index + ".png");
	mask2 = getTitle();
	sum1 = 0.0;
	for (i = 0; i < nResults(); i++) {
		sum1 += getResult("Area", i);
	}
	if(!(sum1 > 0)){
		selectWindow(input);
		close("\\Others");
		print("Error - could not find centre of mass.");
		return;
	}
	getDimensions(width, height, channels, slices, frames);
	wx1 = 0.0;
	wy1 = 0.0;
	count1 = 0;
	print("Calculating centre of mass...");
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			if(getPixel(x, y) == FOREGROUND){
				count1++;
				wx1 += x;
				wy1 += y;
			}
		}
	}
	cx1 = wx1 / count1;
	cy1 = wy1 / count1;
	print("Centroid: " + cx1 + " " + cy1);
	selectWindow(input);
	close("\\Others");
	centre = newArray(cx1, cy1);
	return centre;
}

function removeBlack(image){
	print("Removing black pixels prior to segmentation...");
	selectWindow(image);
	getDimensions(width, height, channels, slices, frames);
	bd = bitDepth();
	FILL_VALUE = 230;
	if(bd < 24){
		setColor(FILL_VALUE);	
	} else {
		setColor(FILL_VALUE, FILL_VALUE, FILL_VALUE);
	}
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			if(bd < 24 && getPixel(x, y) == 0){
				floodFill(x, y);
				continue;
			}
			v = getPixel(x, y);
			red = (v>>16)&0xff;  // extract red byte (bits 23-17)
            green = (v>>8)&0xff; // extract green byte (bits 15-8)
            blue = v&0xff;       // extract blue byte (bits 7-0)
			if(red < 1 && green < 1 && blue < 1){
				floodFill(x, y);
			}
		}
	}
}