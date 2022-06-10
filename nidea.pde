import processing.sound.*;

SoundFile file;
AudioIn in;
FFT fft;
int cols, rows;
int scl = 10;
int w = 3400;
int h = 3000;
int bands = 128;
int stretch = 2;
float flying = 0;
float hscale=0.0;
float[][] terrain;
float[] spectrum;

float xoff;
boolean goFrame = false;
int time =0;
int frameCounter = 0;
int prevTime = 0;
//generado con numpy --> import numpy as np; np.floor(np.logspace(1.0, 3.0,num=340)/3.4);
float[] logx = {   2., 2., 2., 2., 2., 2., 2., 2., 2., 2., 2.,
  2., 2., 2., 3., 3., 3., 3., 3., 3., 3., 3.,
  3., 4., 4., 4., 4., 4., 4., 4., 4., 4., 4.,
  4., 4., 4., 4., 4., 4., 4., 5., 5., 5., 5.,
  5., 5., 5., 5., 5., 5., 5., 5., 5., 6., 6.,
  6., 6., 6., 6., 6., 6., 6., 6., 6., 7., 7.,
  7., 7., 7., 7., 7., 7., 7., 7., 8., 8., 8.,
  8., 8., 8., 8., 8., 8., 9., 9., 9., 9., 9.,
  9., 9., 9., 10., 10., 10., 10., 10., 10., 10., 11.,
  11., 11., 11., 11., 11., 12., 12., 12., 12., 12., 12.,
  13., 13., 13., 13., 13., 14., 14., 14., 14., 14., 15.,
  15., 15., 15., 15., 16., 16., 16., 16., 16., 17., 17.,
  17., 17., 18., 18., 18., 18., 19., 19., 19., 19., 20.,
  20., 20., 21., 21., 21., 21., 22., 22., 22., 23., 23.,
  23., 24., 24., 24., 25., 25., 25., 26., 26., 26., 27.,
  27., 28., 28., 28., 29., 29., 30., 30., 30., 31., 31.,
  32., 32., 33., 33., 33., 34., 34., 35., 35., 36., 36.,
  37., 37., 38., 38., 39., 39., 40., 41., 41., 42., 42.,
  43., 43., 44., 45., 45., 46., 46., 47., 48., 48., 49.,
  50., 50., 51., 52., 53., 53., 54., 55., 56., 56., 57.,
  58., 59., 60., 60., 61., 62., 63., 64., 65., 66., 66.,
  67., 68., 69., 70., 71., 72., 73., 74., 75., 76., 77.,
  78., 79., 80., 82., 83., 84., 85., 86., 87., 88., 90.,
  91., 92., 93., 95., 96., 97., 99., 100., 101., 103., 104.,
  106., 107., 109., 110., 112., 113., 115., 116., 118., 119., 121.,
  123., 124., 126., 128., 130., 131., 133., 135., 137., 139., 141.,
  143., 145., 147., 149., 151., 153., 155., 157., 159., 161., 163.,
  166., 168., 170., 173., 175., 177., 180., 182., 185., 187., 190.,
  193., 195., 198., 201., 203., 206., 209., 212., 215., 218., 221.,
  224., 227., 230., 233., 236., 239., 243., 246., 249., 253., 256.,
  260., 263., 267., 271., 274., 278., 282., 286., 290., 294. };


void setup() {
  size(1900, 1060, P3D);
  cols = w / scl;
  rows = h/ scl;
  terrain = new float[cols][rows];
  spectrum= new float[bands];
  file = new SoundFile(this, "song2.wav");
  
  in= new AudioIn(this, 0);
  fft= new FFT(this, bands);
  fft.input(in);
  time = millis();
  frameRate(30);
}

void draw() {
  flying -= 0.02;
  fft.analyze();
  //spectrum = fft.spectrum;
  //el fft.analyze() fuera del bucleY no hace glitcheos, dentro si, y esta guapo
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    xoff = 0;
    float yscale = (1/(0.001*y+1));
    for (int x = 0; x < bands; x++) {
      float alt =yscale*map(50*fft.spectrum[x], 0, 1, 300, 494);
      for (int w=0; w<stretch; w++) {
        terrain[stretch*x+w][y]=alt*noise(xoff, yoff);
        xoff += 0.1;
      }
      xoff += 0.7;
    }
    yoff += 0.07;
  }

  background(100*sin(PI*flying/100+50), map(100*sin(PI*flying/100)+50, 150, 200, 0, 130), 90);
  noFill();

  translate(-1700+width/2, height/2+10);

  rotateX(PI/2.4+oscillate(PI/16, 30));
  rotateY(oscillate(PI/20, 10));
  rotateZ(oscillate(PI/50, 20));
  translate(-w/2, -6000-h/2, 2*oscillate(50, 70)-1000);
  float fly = mouseX;
  for (int y = 0; y < rows-1; y++) {
    beginShape();
    hscale=(1/(0.0005*y+1));
    //hscale=1;
    for (int x = 0; x < cols -1; x++) {
      int xlog = (int)logx[x];
      stroke(terrain[xlog][y]-20, map(terrain[xlog][y], 150, 200, 0, 130), 90);
      //vertex(x*scl*2, y*4*scl, hscale*terrain[xlog][y]*cos(sin(fly)*fly*x/10));
      vertex(x*scl*2, y*4*scl, hscale*terrain[xlog][y]);
    }
    endShape();
  }
  if (goFrame) {
    goFrame = false;
    save("cartel/"+".tga");
  }
  beginShape();
  rotateX(-PI/3);
  textSize(600);
  text(frameRate, -width-3000, 0);
  text(mouseY, -width-3000, 900);
  endShape();
}
void mouseClicked() {
  if (!file.isPlaying()) {
    file.play();
  } else {
    file.pause();
    terrain = new float[cols][rows];
  }
}

float oscillate(float a, int f) {
  return sin(flying/f)*a;
}

void keyPressed() {
  if (key == 'r') {
    goFrame = true;
  } else if (key=='q') {
    goFrame =false;
  }
}
void drawText(String text) {
  beginShape();
  rotateX(-PI/3);
  textSize(600);
  text(text, mouseX, 0);
  endShape();
}
