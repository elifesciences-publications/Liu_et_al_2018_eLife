//ImageJ Macro used Segment and Analyze protein binding data
// Live cell imaging is performed using single photon time correlated confocal microscope
//The FRET pairs used are (mCerulean3 and Venus)
// mCerulean3 is the donor while Venus is the acceptor
// mCerulean3 lifetime is used to measure the FRET efficiency and infer binding
// The acquired lifetime data is separated into 3 directories
//      1- Ch2 = confocal intensity image of mCerulean3 labelled proteins (donor)
//      2- Ch1 = confocal intensity image of Venus labelled proteins(acceptor)
//      3- tau = generated lifetime map for mCerulean3 labelled proteins

// Image segmentation and ROI Generation Using Ch2 intensity channel
// 1- Background subtraction using rolling ball (top hat) 
// 2- Binarizing the image to create cellular masks
// 3- Regions of intrested (ROIs) are generated using ImageJ's "particle analysis"

//ROI Generation is followed by calculating several parameters for each roi using all three images
// ImageJ's measure plugin is used to measured "Min, max, mean" intensity 
//as well as the "area,centroid" and other paraemters for each ROI
//These measurements are obtained for Ch1,Ch2 and the tau images 

//Paths to Directories
dir=getDirectory("Choose Source Directory");
dir4 = dir+"analysis/Ch2/";
dir5 = dir+"analysis/Ch1/";
dir6 = dir+"analysis/tau/";
dir7 = dir+"analysis/ROI/";
dir8 = dir+"analysis/";

//Read individual lifetime images and save as a tiff stack
dir1 = dir+"tau/";
no_slice=getNumber("input the number of slices in each stack",36);
list1 = getFileList(dir1);
ids_tau=newArray(no_slice*list1.length);
for (i=0; i<list1.length; i++) { 
	open(dir1+list1[i]);
	run("Canvas Size...", "width=256 height=250 position=Top-Center zero");
	nSlices;
	if (nSlices>1) { 
		run("Stack to Images");
		no_image=nImages;
		for (a=0;a<nImages;a++) { 
		selectImage(a+1); 
		title = getTitle; 
		print(title); 
		j=no_slice*i+a;
		ids_tau[j]=title; 
		saveAs("tiff", dir6+title); 
		}
		run("Close All");
	}
}

// Read individual Ch1 (accpetor intensity images) and save as a tiff stack
dir2 = dir+"Ch1/";
list2 = getFileList(dir2);
ids_Ch1=newArray(no_slice*list2.length);
for (i=0; i<list2.length; i++) { 
	open(dir2+list2[i]);
	run("Canvas Size...", "width=256 height=250 position=Top-Center zero");
	nSlices;
	if (nSlices>1) { 
		run("Stack to Images");
		no_image=nImages;
		for (a=0;a<nImages;a++) { 
		selectImage(a+1); 
		title = getTitle; 
		print(title); 
		j=no_slice*i+a;
		ids_Ch1[j]=title; 
		saveAs("tiff", dir5+title); 
		}
		run("Close All");
	}
}
// Read individual Ch2 (donor intensity images) and save as a tiff stack
dir3 = dir+"Ch2/";
list3 = getFileList(dir3);
ids_Ch2=newArray(no_slice*list3.length);
for (i=0; i<list3.length; i++) { 
	open(dir3+list3[i]);
	run("Canvas Size...", "width=256 height=250 position=Top-Center zero");
	nSlices;
	if (nSlices>1) { 
		run("Stack to Images");
		no_image=nImages;
		for (a=0;a<nImages;a++) { 
		selectImage(a+1); 
		title = getTitle; 
		print(title); 
		j=no_slice*i+a;
		ids_Ch2[j]=title; 
		saveAs("tiff", dir4+title); 
		}
		run("Close All");
	}
}



//Generate regions of interest from intensity images
// This is done by:
// 1- subtracting the background using rolling ball (Top Hat) method 
// 2- Binarizing intensity image using thresholding
// 3- Generate ROIs using ImageJ's "Particle Analysis" plugin
for (j=0; j<no_image*list1.length; j++) { 
	title=ids_Ch2[j]+".tif";
	title1=ids_Ch2[j];
	print(title);
	open(dir4+title);
	run("Duplicate...", "title=temp1.tif");	
	selectWindow("temp1.tif");
	run("Subtract Background...", "rolling=50 sliding disable");
	run("Unsharp Mask...", "radius=5 mask=0.60");
	setAutoThreshold("Default dark");
	//run("Threshold...");
	getThreshold(lower, upper);
	b=lower+50;
	setThreshold(b, upper);
	run("Convert to Mask");
	run("Analyze Particles...", "size=8-Infinity pixel circularity=0.00-1.00 show=Nothing summarize add");
	selectWindow(title);
	if (roiManager("count")>0) {
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Measure");
		q=nResults/2;
		o=0;
		for (m=0; m<q; m++) {
			r=m+q;
			k=getResult("Max", r);
			t=getResult("Min", r);
			if ((k>850) || (t<115)) {
			w=m-o;
			roiManager("Select", w);
			roiManager("Delete");
			o=o+1;
			}
		}
		if (o<q) {
		roiManager("Save", dir7+title1+".zip");
		roiManager("reset");
		run("Clear Results");
		}
		else {
		roiManager("reset");
		run("Clear Results");
		}
	}
	selectWindow("temp1.tif");
	close();
	selectWindow(title);
	close();
}

for (j=0; j<no_image*list1.length; j++) {
	title=ids_Ch2[j]+".tif";
	title1=ids_Ch2[j]+".zip";
	print(title);
	path=dir7+title1;
	if(File.exists(path)) { 
		roiManager("Open", dir7+title1);
		open(dir4+title);
		run("32-bit");
		run("Subtract Background...", "rolling=50 stack");
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Measure");
		roiManager("reset");
		}
	}
	selectWindow("Results");
	saveAs("Results", dir8+"Ch2.xls");
	run("Clear Results");
	run("Close All");

for (j=0; j<no_image*list1.length; j++) {
	title=ids_Ch2[j]+".tif";
	title1=ids_Ch2[j]+".zip";
	print(title);
	title_Ch1=ids_Ch1[j]+".tif";
	print(title_Ch1);
	path=dir7+title1;
	if(File.exists(path)) { 
		roiManager("Open", dir7+title1);
		open(dir5+title_Ch1);
		run("32-bit");
		run("Subtract Background...", "rolling=50 stack");
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Measure");
		roiManager("reset");
		}
	}
	selectWindow("Results");
	saveAs("Results", dir8+"Ch1.xls");
	run("Clear Results");
	run("Close All");

for (j=0; j<no_image*list1.length; j++) {
	title=ids_Ch2[j]+".tif";
	title1=ids_Ch2[j]+".zip";
	print(title);
	title_tau=ids_tau[j]+".tif";
	print(title_tau);
	path=dir7+title1;
	if(File.exists(path)) { 
		roiManager("Open", dir7+title1);
		open(dir6+title_tau);
		run("32-bit");
		roiManager("Show None");
		roiManager("Show All");
		roiManager("Measure");
		roiManager("reset");
		}
	}
	selectWindow("Results");
	saveAs("Results", dir8+"tau.xls");
	run("Clear Results");
	run("Close All");

Dialog.create("Analysis is done.");
Dialog.show();


