#@ File (label="Please specify the input directory", style="directory") inputDirectory
#@ File (label="Please specify the output directory", style="directory") registrationTrialsDir

fileList = Array.filter(getFileList(inputDirectory), ".tif");
target = "null";

runIndex = getArgument();
//runIndex = 2;

//verticalFlips = newArray(140, 124, 122, 120, 50, 47, 42, 41, 40, 37, 23, 17, 13, 11, 10, 9, 5);
//horizontalFlips = newArray(13, 27, 40, 50, 55);

smallestDim = 6788;
FOREGROUND = 255;
FILL_VALUE = 230;
MIN_AREA = 100000;

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timeDateString = d2s(year,0) + "." + d2s(month,0) + "." + d2s(dayOfMonth,0) + "-" + d2s(hour,0) + ":" + d2s(minute,0) + ":" + d2s(second,0);
resultsDir = registrationTrialsDir + File.separator() + "Registration_" + runIndex + "_" + timeDateString;
File.makeDirectory(resultsDir);

transformsDir = resultsDir + File.separator() + "Transformations_Output";
File.makeDirectory(transformsDir);

imageOutDir = resultsDir + File.separator() + "Images_Output";
File.makeDirectory(imageOutDir);

//deformations = newArray("Very coarse", "Coarse", "Fine", "Very Fine", "Super fine");
//initalDeformation = deformations[round(4.0 * random())];
//finalDeformation = deformations[round(4.0 * random())];
//divergenceWeight = random();
//curlWeight = random();
//stopThreshold = 0.001 + 0.1 * random();

initalDeformation = "Very Coarse";
finalDeformation = "Fine";
divergenceWeight = 0.0;
curlWeight = 0.0;
stopThreshold = 0.01;
downsampling = 2;
mode = 1;

fileHandle = File.open(resultsDir + File.separator() + "BUnwarpJ_params.txt");
print(fileHandle, "Initial Deformation: " + initalDeformation);
print(fileHandle, "Final Deformation: " + finalDeformation);
print(fileHandle, "Divergence Weight: " + divergenceWeight);
print(fileHandle, "Curl Weight: " + curlWeight);
print(fileHandle, "Stop Threshold: " + stopThreshold);
print(fileHandle, "Downsampling: " + downsampling);
File.close(fileHandle);

setBatchMode(true);

for(index = 0; index < fileList.length - 1; ){
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second);
	i = index;
	while(indexOf(toLowerCase(fileList[i]), ".csv") >= 0){
		i++;
	}
	j = i + 1;
	if(indexOf(toLowerCase(fileList[j]), ".csv") >= 0){
		j++;
	}

	if(target == "null"){
		open(inputDirectory + File.separator() + fileList[i]);
		run("8-bit");
		target = getTitle();
	}

	open(inputDirectory + File.separator() + fileList[j]);
	run("8-bit");
	source = getTitle();
	removeBlack(source);
	removeBlack(target);

	selectWindow(source);

	//smallestDim = width;
	//if(width > height) smallestDim = height;

	print("Target: " + target);
	print("Source: " + source);
	print("File " + j + " of " + fileList.length);
	//selectWindow(source);
	//saveAs("Tiff", registeredSlicesDir + File.separator() + source + "_source_" + index);
	//source = getTitle();
	//selectWindow(target);
	//saveAs("Tiff", registeredSlicesDir + File.separator() + target + "_target_" + index);
	//target = getTitle();

	//selectWindow(target);
	//run("Size...", "width=2048 height=2048 depth=1 constrain average interpolation=Bilinear");
	selectWindow(source);
	//run("Size...", "width=2048 height=2048 depth=1 constrain average interpolation=Bilinear");	

	//if(arrayContains(verticalFlips, (j+1))){
	//	run("Flip Vertically");
	//}
	//if(arrayContains(horizontalFlips, (j+1))){
	//	run("Flip Horizontally");
	//}
	
//	run("bUnwarpJ", "source_image=" + source + " target_image=" + target + " registration=Mono image_subsample_factor=0 initial_deformation=[Very Coarse] final_deformation=Fine divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.01 save_transformations save_direct_transformation=" + transformsDir + File.separator() + source + "_direct_transf.txt save_inverse_transformation=" + transformsDir + File.separator() + target + "_inverse_transf.txt");
	run("bUnwarpJ", "source_image=[" + source + "] target_image=[" + target + 	"] registration=Accurate image_subsample_factor=" + downsampling + " initial_deformation=[" + initalDeformation + "] final_deformation=[" + finalDeformation + "] divergence_weight=" + divergenceWeight + " curl_weight=" + curlWeight + " landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=" + stopThreshold + " save_transformations save_direct_transformation=" + transformsDir + File.separator() + source + "_direct_transf.txt save_inverse_transformation=" + transformsDir + File.separator() + target + "_inverse_transf.txt");
	selectWindow("Registered Source Image");
	//saveAs("Tiff", registeredSlicesDir + File.separator() + getTitle() + "_" + index);
	run("Make Substack...", "delete slices=1");
	close("Registered*");
	close(target);
	selectWindow("Substack (1)");
	//registered = getTitle();
	//trans = correctArea(registered, source, j);
	//f = File.open(areaCorrDir + File.separator() + fileList[j] + "_area_correction.csv");
	//print(f, trans);
	//File.close(f);
	
//	source = getTitle();
//	rigidTranslation();
	close("\\Others");
	saveAs("Tiff", imageOutDir + File.separator() + fileList[j]);
	target = getTitle();
	
	index = j;

	print("Done");
}

setBatchMode(false);

function arrayContains(dataArray, item){
	for(i = 0; i < dataArray.length; i++){
		if(item == dataArray[i]){
			return true;
		}
	}
	return false;
}

function correctArea(source, target, index){
	run("Set Measurements...", "area center display redirect=None decimal=3");
	selectWindow(source);
	//saveAs("Tiff", debugDir + File.separator() + source + "_corrArea_Source");
	//source = getTitle();
	run("Duplicate...", " ");
	run("8-bit");
	removeBlack(getTitle());
	setAutoThreshold("Triangle");
	run("Convert to Mask");
	mask1 = getTitle();
	run("Analyze Particles...", "size=" + MIN_AREA + "-Infinity show=Masks display exclude clear");
	//saveAs("PNG", debugDir + File.separator() + "corrArea_Source_Mask_" + index);
	mask2 = getTitle();
	sum1 = 0.0;
	for (i = 0; i < nResults(); i++) {
		sum1 += getResult("Area", i);
	}
	if(!(sum1 > 0)){
		selectWindow(source);
		print("Area correction factor: 1.0 ");
		return "";
	}
	getDimensions(width, height, channels, slices, frames);
	wx1 = 0.0;
	wy1 = 0.0;
	count1 = 0;
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
	close(mask1);
	close(mask2);
	selectWindow(target);
	//saveAs("Tiff", debugDir + File.separator() + target + "_corrArea_Target");
	//target = getTitle();
	run("Duplicate...", " ");
	run("8-bit");
	setAutoThreshold("Triangle");
	run("Convert to Mask");
	mask1 = getTitle();
	run("Analyze Particles...", "size=" + MIN_AREA + "-Infinity display exclude clear");
	//saveAs("PNG", debugDir + File.separator() + "corrArea_Target_Mask_" + index);
	close(mask1);
	sum2 = 0.0;
	for (i = 0; i < nResults(); i++) {
		sum2 += getResult("Area", i);
	}
	selectWindow(source);
	getDimensions(width, height, channels, slices, frames);
	print("Area correction factor: " + (sum2 / sum1));
	newSideLength = Math.sqrt(width * height * sum2 / sum1);
	print("New Side Length: " + newSideLength);
	run("Size...", "width=" + newSideLength + " height=" + newSideLength + " depth=1 constrain average interpolation=None");
	if(sum1 < sum2){
		run("Specify...", "width=" + smallestDim + " height=" + smallestDim + " x=" + (smallestDim / 2) + " y=" + (smallestDim / 2) + " centered");
		run("Crop");
	} else {
		//run("Translate...", "x=-1 y=-1 interpolation=None");
		run("Canvas Size...", "width=" + smallestDim + " height=" + smallestDim + " position=Center zero");
	}
	result = getTitle();
	run("Duplicate...", " ");
	run("8-bit");
	setAutoThreshold("Triangle");
	run("Convert to Mask");
	mask1 = getTitle();
	run("Analyze Particles...", "size=" + MIN_AREA + "-Infinity show=Masks display exclude clear");
	//saveAs("PNG", debugDir + File.separator() + "corrArea_Resized_Mask_" + index);
	mask2 = getTitle();
	close(mask1);
	selectWindow(mask2);
	getDimensions(width, height, channels, slices, frames);
	wx2 = 0.0;
	wy2 = 0.0;
	count2 = 0;
	for(y = 0; y < height; y++){
		for(x = 0; x < width; x++){
			if(getPixel(x, y) == FOREGROUND){
				count2++;
				wx2 += x;
				wy2 += y;
			}
		}
	}
	cx2 = wx2 / count2;
	cy2 = wy2 / count2;
	close(mask2);
	xshift = cx1 - cx2;
	yshift = cy1 - cy2;
	print("X Shift: " + xshift);
	print("Y Shift: " + yshift);
	selectWindow(result);
	run("Translate...", "x=" + xshift + " y=" + yshift + " interpolation=None");
	return d2s(newSideLength / smallestDim, 3) + "," + d2s((smallestDim - newSideLength) / 2, 3) + "," + d2s(xshift,3) + "," + d2s(yshift,3);
	//source = result;
	//selectWindow(source);
}

function rigidTranslation(){
	run("Images to Stack", "name=Stack title=[] use");
	run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid");
	selectWindow("Aligned 2 of 2");
	run("Stack to Images");
	close("Aligned-0001");
	selectWindow("Aligned-0002");
}

function removeBlack(image){
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
