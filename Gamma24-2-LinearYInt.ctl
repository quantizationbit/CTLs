

// 
// Convert Gamma 2.4 100 nits to PQ 800 nits
//


import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "utilities-color";
import "PQ";


const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;



const float L_W = 1.0;
const float L_B = 0.0;



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform int inLegalRange = 1,
    input uniform float peak = 800.0
)
{
	
    float G24[3] = { rIn, gIn, bIn};
    
  // Default output is full range, check if legalRange param was set to true
    if (inLegalRange == 1) {
        G24 = smpteRange_to_fullRange( G24);
    }   


  // Decode with inverse gamma 2.4 transfer function
    float linearCV[3];
    linearCV[0] = bt1886_f( G24[0], 2.4, L_W, L_B);
    linearCV[1] = bt1886_f( G24[1], 2.4, L_W, L_B);
    linearCV[2] = bt1886_f( G24[2], 2.4, L_W, L_B);
    
  // Clip range to where you want 1.0 in gamma to be
    linearCV = clamp_f3( linearCV, 0., 1);
    linearCV = mult_f_f3(peak, linearCV);
    
  // Calculate 709 Y nits
  linearCV[0] = 0.212639*linearCV[0] + 0.715169*linearCV[1] + 0.0721923*linearCV[2];
  linearCV[1] = linearCV[0];
  linearCV[2] = linearCV[0];
    
   // now linearCV is Y so to output as Int need to limit to 255


  float outputCV[3] = clamp_f3( linearCV, 0., 255);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./255., outputCV);

  // Default output is full range

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}
