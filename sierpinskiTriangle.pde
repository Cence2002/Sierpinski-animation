int samplesPerFrame=1;
int numFrames=180;
float shutterAngle=1;
boolean test=false;


int[][] result;
float t=0;

float calm(float p) {
  return 3*p*p-2*p*p*p;
}

float calm(float p, float g) {
  if (p<0.5) {
    return 0.5*pow(2*p, g);
  } else {
    return 1-0.5*pow(2*(1.0-p), g);
  }
}

float mn=.5*sqrt(3);
float ia=atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

void draw() {
  if (test) {
    if (mousePressed) {
      t+=(float)(mouseX-pmouseX)/width%1;
      draw_();
    }
  } else {
    result=new int[width*height][3];
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t=map(frameCount-1+sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0]+=pixels[i] >> 16 & 0xff;
        result[i][1]+=pixels[i] >> 8 & 0xff;
        result[i][2]+=pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++) {
      pixels[i]=0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    }
    updatePixels();

    saveFrame("frames3/frame_"+nf(frameCount, 3)+".png");
    println(frameCount, "/", numFrames);
    if (frameCount==numFrames) {
      println("FINISHED");
      exit();
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

void sierp(PVector a, PVector b, PVector c, int n) {
  stroke(1);
  if (n>0) {
    if (n==1) {
      stroke(1, 1-constrain(calm((3*t)%1, 2)*1.5, 0, 1));
    }
    PVector aa=PVector.add(b, c).div(2);
    PVector bb=PVector.add(c, a).div(2);
    PVector cc=PVector.add(a, b).div(2);
    line(aa.x, aa.y, bb.x, bb.y);
    line(bb.x, bb.y, cc.x, cc.y);
    line(cc.x, cc.y, aa.x, aa.y);
    sierp(a, bb, cc, n-1);
    sierp(b, cc, aa, n-1);
    sierp(c, aa, bb, n-1);
  }
}

void fullSierp(PVector a, PVector b, PVector c, int n) {
  stroke(1);
  line(a.x, a.y, b.x, b.y);
  line(b.x, b.y, c.x, c.y);
  line(c.x, c.y, a.x, a.y);
  sierp(a, b, c, n);
}

OpenSimplexNoise osn;
PVector a;
PVector b;
PVector c;

void setup() {
  size(600, 600);
  result=new int[width*height][3];
  colorMode(RGB, 1);
  osn=new OpenSimplexNoise();

  stroke(1);
  strokeWeight(0.9);
  fill(1);
}

void draw_() {
  background(0);
  translate(300, 300);
  float tt=calm((3*t)%1, 2)/2;
  float off=floor(3*t)*TWO_PI/3;
  //rotate(2*tt*TWO_PI/3);
  a=new PVector(200*sin(off), 200*cos(off));
  b=new PVector(200*sin(TWO_PI/3+off), 200*cos(TWO_PI/3+off));
  c=new PVector(200*sin(TWO_PI*2/3+off), 200*cos(TWO_PI*2/3+off));
  stroke(1);
  line(a.x, a.y, b.x, b.y);
  line(b.x, b.y, c.x, c.y);
  line(c.x, c.y, a.x, a.y);
  PVector b1=PVector.lerp(b, a, tt);
  PVector b2=PVector.lerp(b, c, tt);
  PVector c1=PVector.lerp(c, a, tt);
  PVector c2=PVector.lerp(c, b, tt);
  fullSierp(a, b1, c1, 6);
  fullSierp(b, b1, b2, 6);
  fullSierp(c, c1, c2, 6);
  //rotate(-2*tt*TWO_PI/3);
  translate(-300, -300);
}
