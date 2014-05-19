#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface SimpleVideoFilterViewController : UIViewController
{
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter, *brightnessFilter, *contrastFilter, *exposureFilter;
    GPUImageMovieWriter *movieWriter;
    
    IBOutlet UISlider *slider1, *slider2, *slider3, *slider4;
    IBOutlet UISegmentedControl *cameraControl;
}

- (IBAction)updateSliderValue:(id)sender;
- (IBAction)updateSlider2Value:(id)sender;
- (IBAction)updateSlider3Value:(id)sender;
- (IBAction)updateSlider4Value:(id)sender;
- (IBAction)toggleControls:(id)sender;
- (IBAction)toggleCamera:(id)sender;

@end
