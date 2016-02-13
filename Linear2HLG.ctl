

// 
// Convert PQ to Hybrid Gamma Log
//




// Assume full range input. Inverse PQ as 0-1
import "utilities";
import "HGL";


// Legal Range
//const unsigned int CV_BLACK = 4096; //64.0*64.0;
//const unsigned int CV_WHITE = 60160;

// Work with SDI Range
//const unsigned int CV_BLACK_SDI = 256; //64.0*64.0;
//const unsigned int CV_WHITE_SDI = 65216;

// Full Range assumed:
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;

const unsigned int BITDEPTH = 16;



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float LRefDisplay=800.0
)
{

 float linearCV[3] = { rIn, gIn, bIn};


 // Input Data from 0.0-1.0
 // (assuming normalized linear display light)
 
 // Step 1: Remove system gamma:
 // Requires that you know the display brightness
 // or creatively can pick a reference display brightness
 // to invert that creatively works...
 
 // System Gamma correction: (in 0.0-1.0) range
 // Calculate the system gamma
 float gamma = 1.2 + 0.42*log10(LRefDisplay/1000.0);

 
 // calculate display light luminance
 // and scale factor to remove it's system gamma
 //709
 float Y = 0.2126*linearCV[0] + 0.7152*linearCV[1] + 0.0722*linearCV[2];
 float Yinvgamma = exp(log(Y)/gamma);
 float scale = Yinvgamma/Y; 
 
 // scale display light RGB to remove system gamma
 linearCV[0] = scale*linearCV[0];
 linearCV[1] = scale*linearCV[1];
 linearCV[2] = scale*linearCV[2];
 
 
 // Step 2:  Apply the OETF to the computed
 // scene linear light from the prior step.
 // scale from 0-12. to fit OETF formula
 linearCV[0] = rIn*12.0;
 linearCV[1] = gIn*12.0;
 linearCV[2] = bIn*12.0;
 
 

 
  
 // Encode linear  gamma inverted code values with OETF transfer function
 float outputCV[3];
 outputCV[0] = HLG_r( linearCV[0]);
 outputCV[1] = HLG_r( linearCV[1]);
 outputCV[2] = HLG_r( linearCV[2]);


 rOut = outputCV[0];
 gOut = outputCV[1];
 bOut = outputCV[2];      
}



