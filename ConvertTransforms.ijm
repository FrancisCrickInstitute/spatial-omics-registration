#@ File (label="Please specify the transformations directory", style="directory") splineTransDir
#@ File (label="Please specify the warped images directory", style="directory") imageDir
#@ File (label="Please specify the output directory", style="directory") rawTransDir

var SUFFIX = "_direct_transf.txt"

macro "Convert_Transforms" {

//	i = parseInt(getArgument());
	
	setBatchMode(true);
	
	splineTransFiles = getFileList(splineTransDir);
	
	splineTransFiles = Array.filter(splineTransFiles, SUFFIX);
	
	for (i = 0; i < splineTransFiles.length; i++) {
		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + " Converting " + splineTransFiles[i]);
		targetImage = substring(splineTransFiles[i], 0, lastIndexOf(splineTransFiles[i], SUFFIX));
		open(imageDir + File.separator() + targetImage);
		//call("bunwarpj.bUnwarpJ_.convertToRaw", splineTransDir + File.separator() + splineTransFiles[i], rawTransDir + File.separator() + replace(splineTransFiles[i], ".txt", "_raw.txt"), "slide003_ob3_small.tif");
		call("bunwarpj.bUnwarpJ_.convertToRaw", splineTransDir + File.separator() + splineTransFiles[i], rawTransDir + File.separator() + replace(splineTransFiles[i], ".txt", "_raw.txt"), targetImage);
		close("*");
	}
	
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(year + "." + month + "." + dayOfMonth + "-" + hour + ":" + minute + ":" + second + " Done.");
	
	setBatchMode(false);

}