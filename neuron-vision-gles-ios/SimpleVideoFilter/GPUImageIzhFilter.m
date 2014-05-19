#import "GPUImageIzhFilter.h"

@implementation GPUImageIzhFilter

@synthesize randomSeed = _randomSeed;
@synthesize saturation = _saturation;

NSString *const kGPUImageIzhikevichShaderString = SHADER_STRING
(
 //****
 precision highp float;
 varying vec2 textureCoordinate;
 
 
 uniform sampler2D inputImageTexture;
 
 uniform float randomSeed;
 uniform float saturation;
 
 float u_vertex_r = -14.0;
 float v_vertex_r = -70.0;
 float u_vertex_g = -14.0;
 float v_vertex_g = -70.0;
 float u_vertex_b = -14.0;
 float v_vertex_b = -70.0;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 //const highp vec3 W = vec3(0.5, 0.5, 0.5);
 
 float rand6(vec2 n)
{
    return 0.5 + 0.5 *
    fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
 
 vec3 Izhikevich(float v, float u, float I)
{
    
    float vv;
    float uu;
    
    float DT = 1000.0 / 30.0; // in milliseconds *see Izhikevich paper
    float A = 0.02; // a: time scale of the recovery variable u
    float B = 0.2; // b:sensitivity of the recovery variable u to the subthreshold fluctuations of v.
    float C = -65.0; // c: reset value of v caused by fast high threshold (K+)
    float D = 6.0; // d: reset of u caused by slow high threshold Na+ K+ conductances
    float TH = 30.0; // voltage threshold
    float X = 5.0; // x , constant in Izhikevich equation
    float Y = 140.0; // y, constant in Izhikevich equation

    
    vv = v + DT * (0.04 * v * v + X * v + Y - u + I); // neuron[0] = v;
    uu = u + DT * A * (B * v - u); // neuron[1] = u; See Izhikevich model
    
    if (vv >= TH) // if spikes
    {
        return vec3(C, uu + D, 1.0);
    }
    else
    {
        return vec3(vv, uu, 0.0);
    };
}

 
 //****
 
 void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    float luminance = dot(textureColor.rgb, W);  //convert to grayscale
    
    //Generate noise
    float noise = rand6(textureCoordinate.xy + vec2(randomSeed));  //0..1
    //float noise = 0.90;  //0..1
    
    vec3 from_neuron_r = Izhikevich(v_vertex_r, u_vertex_r, 4.0 * saturation * (textureColor.r + noise));
    v_vertex_r = from_neuron_r.x;
    u_vertex_r = from_neuron_r.y;
    float spike_r = from_neuron_r.z;
    
    vec3 from_neuron_g = Izhikevich(v_vertex_g, u_vertex_g, 4.0 * saturation * (textureColor.g + noise));
    v_vertex_g = from_neuron_g.x;
    u_vertex_g = from_neuron_g.y;
    float spike_g = from_neuron_g.z;
    
    vec3 from_neuron_b = Izhikevich(v_vertex_b, u_vertex_b, 4.0 * saturation * (textureColor.b + noise));
    v_vertex_b = from_neuron_b.x;
    u_vertex_b = from_neuron_b.y;
    float spike_b = from_neuron_b.z;
    
    
    //gl_FragColor = vec4(mix(vec3(v_vertex), vec3(textureColor.r, textureColor.g, textureColor.b), 0.5), 1.0);
    //gl_FragColor = vec4(mix(vec3(v_vertex / -70.0), vec3(textureColor.r, textureColor.g, textureColor.b), saturation), 1.0);
    gl_FragColor = vec4(vec3(spike_r, spike_g, spike_b), 1.0);
    
}
 );

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageIzhikevichShaderString]))
    {
		return nil;
    }
    
    uniformRandomSeed = [filterProgram uniformIndex:@"randomSeed"];
    self.randomSeed = 1.0;
    srand(1);

    return self;
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    
    //must include this code to force rendering
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    [self renderToTextureWithVertices:imageVertices textureCoordinates:[[self class] textureCoordinatesForRotation:inputRotation] sourceTexture:filterSourceTexture];
    // ****
    
    [self setRandomSeed:(float) rand()/RAND_MAX];
    
    //let children know....
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

#pragma mark -
#pragma mark Accessors

- (void)setRandomSeed:(CGFloat)newValue;
{
    _randomSeed = newValue;
    
    [self setFloat:_randomSeed forUniform:uniformRandomSeed program:filterProgram];
}
     
- (void)setSaturation:(CGFloat)newValue;
     {
         _saturation = newValue;
         
         [self setFloat:_saturation forUniform:uniformSaturation program:filterProgram];
     }


@end
