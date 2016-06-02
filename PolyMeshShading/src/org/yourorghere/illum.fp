/*
 * Illumination fragment shader: phong and toon shading
 */

// From vertex shader: position and normal (in eye coordinates)
varying vec4 pos;
varying vec3 norm;

// Do Phong specular shading (r DOT v) instead of Blinn-Phong (n DOT h)
uniform int phong;
// Do toon shading
uniform int toon;
// If false, then don't do anything in fragment shader
uniform int useFragShader;

// Toon shading parameters
uniform float toonHigh;
uniform float toonLow;

// Apply volume texture to diffuse term
//uniform int volTexture;
// Volume texture scale
//uniform float volRes;

// Compute toon shade value given diffuse and specular component levels
vec4 toonShade(float diffuse, float specular)
{
    //toon shading
    //Constant c
    float c;
    if(diffuse > toonHigh){
        c = 0.8;
    } else if( diffuse < toonLow){
        c = 0.2;
    } else {
        c = 0.5;
    }

    vec4 color = gl_FrontLightProduct[0].ambient + gl_FrontLightProduct[0].diffuse * c;

    if(specular > toonHigh){
        color = vec4(0.9,0.9,0.9,1.0);
    } 

    return color;
}


void main()
{
    if (useFragShader == 0) {
        // Pass through
        gl_FragColor = gl_Color;
    } else {
        //cal diffuse nldot
        vec4 l;
        vec4 n;
        vec3 temp = normalize(norm);
        n = vec4(temp.x,temp.y,temp.z,1.0);
        l = normalize(gl_LightSource[0].position - pos);
        float nldot = dot(n,l); 
        
        //cal specular nhdot
        vec4 cam = vec4(0.0,0.0,0.0,1.0);
        vec4 v = normalize(cam - pos);
        vec4 h = (l+v)/length(l+v);
        h = normalize(h);
        float nhdot = dot(n,h);
        
        
        
        float diff = max(0.0,nldot);
        float spec = pow((max(0.0,nhdot)),gl_FrontMaterial.shininess);
        
        
        
        if (toon == 1) {
            // ... (placeholder)
            if(nldot > 0){
            gl_FragColor = toonShade(diff, spec);
            }
            else {
            gl_FragColor = toonShade(diff, 0.0);
            }
        } else if (phong == 1) {
                vec4 r = normalize(reflect(l,normalize(n)));
                float rvdot = dot(r,v);
                
                float alpha = 0.25 * gl_FrontMaterial.shininess;
                float specu = pow((max(0.0,rvdot)),alpha);

                vec4 II = gl_FrontLightProduct[0].ambient + gl_FrontLightProduct[0].diffuse * diff;
                if(nldot > 0.0) {
                II = II + gl_FrontLightProduct[0].specular * specu;
                }
				II.x = clamp(II.x, 0.0, 1.0);
				II.y = clamp(II.y, 0.0, 1.0);
				II.z = clamp(II.z, 0.0, 1.0);
                gl_FragColor = II;
                
            } else {
                vec4 I = gl_FrontLightProduct[0].ambient + gl_FrontLightProduct[0].diffuse * diff; 

                //skip specular nldot < 0
                if(nldot > 0.0) {
                I = I + gl_FrontLightProduct[0].specular * spec;
                }
				I.x = clamp(I.x, 0.0, 1.0);
				I.y = clamp(I.y, 0.0, 1.0);
				I.z = clamp(I.z, 0.0, 1.0);
                gl_FragColor = I;
        }
    }
}
