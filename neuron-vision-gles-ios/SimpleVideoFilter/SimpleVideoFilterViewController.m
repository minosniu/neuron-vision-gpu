#import "SimpleVideoFilterViewController.h"

@implementation SimpleVideoFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1920x1080 cameraPosition:AVCaptureDevicePositionBack];

    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;

    //filter = [[GPUImageSepiaFilter alloc] init];
    //filter = [[GPUImageGrayscaleFilter alloc] init];  //**TDS
    filter = [[GPUImageIzhFilter alloc] init];  //**CMN
    brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    contrastFilter = [[GPUImageContrastFilter alloc] init];
    exposureFilter = [[GPUImageExposureFilter alloc] init];
    
//    filter = [[GPUImageTiltShiftFilter alloc] init];
//    [(GPUImageTiltShiftFilter *)filter setTopFocusLevel:0.65];
//    [(GPUImageTiltShiftFilter *)filter setBottomFocusLevel:0.85];
//    [(GPUImageTiltShiftFilter *)filter setBlurSize:1.5];
//    [(GPUImageTiltShiftFilter *)filter setFocusFallOffRate:0.2];
    
//    filter = [[GPUImageSketchFilter alloc] init];
//    filter = [[GPUImageSmoothToonFilter alloc] init];
//    GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRightFlipVertical];
    
    [videoCamera addTarget:exposureFilter];
    [exposureFilter addTarget:brightnessFilter];
    [brightnessFilter addTarget:contrastFilter];
    [contrastFilter addTarget:filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:filterView];
//    filterView.fillMode = kGPUImageFillModeStretch;
//    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    // Record a movie for 10 s and store it in /Documents, visible via iTunes file sharing
    /*
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(720.0, 1280.0)];
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(1080.0, 1920.0)];
    [filter addTarget:movieWriter];
     */
    
    [videoCamera startCameraCapture];
    
    /*
    double delayToStartRecording = 0.5;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Start recording");
        
        videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];

//        NSError *error = nil;
//        if (![videoCamera.inputCamera lockForConfiguration:&error])
//        {
//            NSLog(@"Error locking for configuration: %@", error);
//        }
//        [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
//        [videoCamera.inputCamera unlockForConfiguration];

        double delayInSeconds = 10.0;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            
            [filter removeTarget:movieWriter];
            videoCamera.audioEncodingTarget = nil;
            [movieWriter finishRecording];
            NSLog(@"Movie completed");
            
//            [videoCamera.inputCamera lockForConfiguration:nil];
//            [videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
//            [videoCamera.inputCamera unlockForConfiguration];
        });
    });
     */
    
    [slider1 setValue:.25];
    [slider2 setValue:.25];
    [slider3 setValue:.25];
    [slider4 setValue:1.0];
    [(GPUImageBrightnessFilter *)brightnessFilter setBrightness:.25];
    [(GPUImageContrastFilter *)contrastFilter setContrast:.5];
    [(GPUImageExposureFilter *)exposureFilter setExposure:0.0];
    [(GPUImageGrayscaleFilter *)filter setSaturation:1.0];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;

        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;

        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;

        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;

        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES; // Support all orientations.
}

- (IBAction)updateSliderValue:(id)sender
{
    //[(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]];
//    [(GPUImageGrayscaleFilter *)filter setRandomSeed:((float)[(UISlider *)sender value] / (float)[(UISlider *)sender maximumValue])];
    [(GPUImageBrightnessFilter *)brightnessFilter setBrightness:((float)[(UISlider *)sender value] / (float)[(UISlider *)sender maximumValue])];
}

- (IBAction)updateSlider2Value:(id)sender
{
    [(GPUImageContrastFilter *)contrastFilter setContrast:2.0*((float)[(UISlider *)sender value] / (float)[(UISlider *)sender maximumValue])];
}

- (IBAction)updateSlider3Value:(id)sender
{
    [(GPUImageExposureFilter *)exposureFilter setExposure:-1.0+4.0*((float)[(UISlider *)sender value] / (float)[(UISlider *)sender maximumValue])];
}

- (IBAction)updateSlider4Value:(id)sender
{
    [(GPUImageGrayscaleFilter *)filter setSaturation:((float)[(UISlider *)sender value] / (float)[(UISlider *)sender maximumValue])];
}

- (IBAction)toggleControls:(id)sender
{
    UISwitch *vswitch = (UISwitch *)sender;
    if (vswitch.on)
    {
        [slider1 setHidden:NO];
        [slider2 setHidden:NO];
        [slider3 setHidden:NO];
        [slider4 setHidden:NO];
        [cameraControl setHidden:NO];
    }
    else
    {
        [slider1 setHidden:YES];
        [slider2 setHidden:YES];
        [slider3 setHidden:YES];
        [slider4 setHidden:YES];
        [cameraControl setHidden:YES];
    }

}

- (IBAction)toggleCamera:(id)sender
{
    UISegmentedControl *sc = (UISegmentedControl *) sender;
    [videoCamera stopCameraCapture];
    [videoCamera release];

    if (sc.selectedSegmentIndex)
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    else
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    [videoCamera addTarget:exposureFilter];
    [self didRotateFromInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    [videoCamera startCameraCapture];
}


@end
