#import "GPUImageFilter.h"

extern NSString *const kGPUImageLuminanceFragmentShaderString;

/** Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)
 */
@interface GPUImageIzhFilter : GPUImageFilter
{
    GLint uniformRandomSeed, uniformSaturation;
}
    
// Opacity ranges from 0.0 to 1.0, with 1.0 as the normal setting
@property(readwrite, nonatomic) CGFloat randomSeed;
@property(readwrite, nonatomic) CGFloat saturation;

@end
