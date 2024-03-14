#ifdef GL_ES
precision highp float;
#endif

#define PI 3.14159265359
#define TWO_PI 6.28318530718

varying vec2 vUV;

uniform float rand;
uniform float noiseMult;

uniform float cheekX;
uniform float cheekY;
uniform float cheekBlur;

uniform float radius;

uniform vec3 bodyColor;
uniform vec3 eyesColor;
uniform vec3 pawsColor;
uniform vec3 earsColor;

uniform float hasBelly;
uniform float hasFU;
uniform float hasRU;
uniform float hasChin;
uniform float hasCheeks1;
uniform float hasCheeks2;
uniform float hasBlaze;

uniform float hasMiddleBand;
uniform float hasSpots;
uniform float hasCheekFlash;
uniform float hasSnout;

uniform float shaderTweak1;
uniform float shaderTweak2;
uniform float shaderTweak3;
uniform float shaderTweak4;

float shape(vec2 st, int N){
    st = st*2.008-1.;
    float a = atan(st.x,st.y)+PI;
    float r = TWO_PI/float(N);
    return cos(floor(.5+a/r)*r-a)*length(st);
}

vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

const float F3 =  0.3333333;
const float G3 =  0.1666667;
float snoise(vec3 p) {

    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));

    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e*(1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy*(1.0 - e);

    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0*G3;
    vec3 x3 = x - 1.0 + 3.0*G3;

    vec4 w, d;

    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);

    w = max(0.600 - w, 0.0);

    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);

    w *= w;
    w *= w;
    d *= w;

    return dot(d, vec4(3000.0));
}

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise2(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

mat2 rotate(float a){
    float c = cos(a); 
    float s = sin(a);
    return mat2(c, -s, s, c);
}

float line(vec2 uv, vec2 o, float len, float thickness, float rot, float blur){
    uv -= o;
    if(rot != 0.){
    	uv *= rotate(rot);
    }
    float d = length(uv-vec2(0., clamp(uv.y, -len*.5, len*.5)));
    return smoothstep(blur+.001, .0, d-thickness);
}

float curveline(vec2 uv, vec2 o, float len, float thickness, float rot, float blur, float curveAmount){
    uv -= o;
    uv *= rotate(rot);
    float a = (uv.y)/(len*.5)*curveAmount;
    uv *= rotate(a);
    return line(uv, vec2(0,0), len, thickness, 0., blur);
}

float ellipse(vec2 uv, vec2 o, float rx, float ry, float rot, float blur){
    uv -= o;
    if(rot != 0.){
    	uv *= rotate(rot);
    }
    float dx = uv.x;
    float dy = uv.y;
    float d = (dx*dx)/(rx*rx);
    d += (dy*dy)/(ry*ry);
    return smoothstep(blur+.001, .0, d-ry*rx);
}

float paintEyeLiner(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float gridSize = .03125;
    float radius = gridSize*2.5;
    float eyeX = gridSize*6.8;
    float eyeY = gridSize*1.25;
    return ellipse(uv, vec2(eyeX, eyeY), radius, radius, 0., .05);
}

float paintRearUnder(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = .362;
    float py = .245;
    float len = .291;
    float thickness = .107;
    float rot = -1.043;
    float curveAmount = -.003;
/*
    blur = cheekBlur;
    px = cheekX;
    py = cheekY;
    len = shaderTweak1;
    thickness = shaderTweak2;
    rot = shaderTweak3;
    curveAmount = shaderTweak4;
*/
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintArmsChest(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.289;
    float py = .318;
    float len = .421;
    float thickness = .12;
    float rot = 1.612;
    float curveAmount = .0;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintBelly3(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.31;
    float py = .448;
    float len = 1.;
    float thickness = .15; //reduce to make narrow strip
    float rot = 1.544;
    float curveAmount = .0;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintEyeBrows(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .01;
    float px = -.26;
    float py = .036;
    float len = .009;
    float thickness = .013;
    float rot = .523;
    float curveAmount = -0.003;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintFrontUnder(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.462;
    float py = .253;
    float len = .171;
    float thickness = .097;
    float rot = -1.587;
    float curveAmount = -0.5;
    vec2 pos = vec2(px + .5, py);
    blur = .03;
    px = -.375;
    py = .297;
    len = .486;
    thickness = .136;
    rot = .931;
    curveAmount = .408;
    pos.x = px + .5;
    pos.y = py;
    float col = curveline(uv, pos, len, thickness, rot, blur, curveAmount);
    return col;
}

float paintChin(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.484;
    float py = .036;
    float len = .117;
    float thickness =  .072;
    float rot = -2.472;
    float curveAmount = .0;
    vec2 cheekPos = vec2(px + .5, py);
    return curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount);
}

float paintSnout(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .02;
    float px = -.36;
    float py = .034;
    float len = .030;
    float thickness =  .003;
    float rot = -2.676;
    float curveAmount = -.112;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintCheeks1(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .05;
    float px = -.332;
    float py = .123;
    float len = .204;
    float thickness =  .0;
    float rot = -2.2;
    float curveAmount = -0.5;
    vec2 cheekPos = vec2(px + .5, py);
    return curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount);
}

float paintCheeks2(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.180;
    float py = .21;
    float len = .334;
    float thickness =  .024;
    float rot = -1.519;
    float curveAmount = -.426;

    vec2 cheekPos = vec2(px + .5, py);
    float pat = curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount);
    
    blur = .03;
    px = -.419;
    py = .21;
    len = .15;
    thickness =  .09;
    rot = -.907;
    curveAmount = .5;

    /*
    blur = cheekBlur;
    px = cheekX;
    py = cheekY;
    len = shaderTweak1;
    thickness = shaderTweak2;
    rot = shaderTweak3;
    curveAmount = shaderTweak4;
    */

    cheekPos.x = px + .5;
    cheekPos.y = py;
    
    return max(curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount), pat);
}

float paintCheekFlashes(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.159;
    float py = .145;
    float len = .041;
    float thickness =  .0;
    float rot = 2.02;
    float curveAmount = .116;
    vec2 cheekPos = vec2(px + .5, py);
    return curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount);
}

float paintBelly(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float bellyX1 = .52;
    float bellyY1 = -.06;
    float bellyBlur1 = .12;
    float bellyRadiusX1 = .5;
    float bellyRadiusY1 = .4;
    float bellyTop = ellipse(uv, vec2(bellyX1, .5 + bellyY1), bellyRadiusX1, bellyRadiusY1, 0., bellyBlur1);
    return bellyTop;
}

float paintBlaze(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.05;
    float py = -.18;
    float len = .291;
    float thickness = .107;
    float rot = -1.043;
    float curveAmount = -.003;
    vec2 cheekPos = vec2(px + .5, py);
    return curveline(uv, cheekPos, len, thickness, rot, blur, curveAmount);
}

float paintMiddleBand(vec2 uv){
    uv = abs(uv-vec2(0.,.5));
    float blur = .03;
    float px = -.007;
    float py = .492;
    float len = .876;
    float thickness = .022;
    float rot = -.16;
    float curveAmount = -.036;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float paintEars(vec2 uv){
    float blur = .06;
    float px = .46;
    float py = .969;
    float len = .052;
    float thickness = .0;
    float rot = -.839;
    float curveAmount = -.5;
    vec2 pos = vec2(px + .5, py);
    return curveline(uv, pos, len, thickness, rot, blur, curveAmount);
}

float drawHair(vec2 uv, float rand){
    vec2 pos = vec2(uv.x*noiseMult, uv.y*noiseMult) + vec2(rand);
    return snoise2(pos)*.25 + .75;
    //vec3 pos = vec3(uv.x*noiseMult, uv.y*noiseMult, 0.) + vec3(rand);
    //return snoise(pos);
}

float paintPaws(vec2 uv){
    float x = .93;
    float y = .05;
    float rx = .3;
    float ry = .2;
    vec2 pawsPos = vec2(x, y);
    float d = ellipse(uv, pawsPos, rx, ry, .0, 0.1);
    return d;
}

void main(void) {
    
    float pat = paintEyeLiner(vUV);

    if(hasBelly > 0.0){
        pat = max(paintBelly(vUV), pat);
    }
    if(hasRU > 0.0){
        pat = max(paintRearUnder(vUV), pat);
    }
    if(hasChin > 0.0){
        pat = max(paintChin(vUV), pat);
    }
    if(hasSnout > 0.0){
        pat = max(paintSnout(vUV), pat);
    }
    if(hasCheeks1 > 0.0){
        pat = max(paintCheeks1(vUV), pat);
    }
    if(hasCheeks2 > 0.0){
        pat = max(paintCheeks2(vUV), pat);
    }
    if(hasFU > 0.0){
        pat = max(paintFrontUnder(vUV), pat);
    }
    if(hasMiddleBand > 0.0){
        pat = max(paintMiddleBand(vUV), pat);
    }

    float hair = drawHair(vUV, rand);

    if(hasBlaze > 0.0){
        hair = hair - paintBlaze(vUV)*2.0;
    }
    if(hasCheekFlash > 0.0){
        hair = hair - paintCheekFlashes(vUV)*2.0;
    }

    vec3 color = mix(vec3(hair), vec3(pat), .75);
    color += bodyColor;

    float paws = max(min(paintPaws(vUV), 1.), .0);
    if(paws > 0.){
        color -= paws*bodyColor;
        color += paws*pawsColor;
    }
    
    float ears = max(min(paintEars(vUV), 1.), .0);
    if(ears > 0.){
        color -= ears*bodyColor;
        color += ears*earsColor;
    }
    
    gl_FragColor = vec4(color, 1.0);
}