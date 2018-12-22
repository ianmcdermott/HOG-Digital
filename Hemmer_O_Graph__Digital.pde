//to do 
//optimize boids for regional crowfollow
//optimize boids to only detect a chunk of the array list of points
import processing.serial.*;  // serial library lets us talk to Arduino

//Sprite

PImage[] wingImages;
int imageCount = 119;
PImage logo;
int w = 800;
int cols;
int rows;
float d = w-10;
float r = d/2; 
float angle = 0;
float strokeW = 1;
float angleRes = .0007;
Guide[] vertGuides;
Guide[] horizGuides;
Curve[][] curves;
int phaseX = 5;
int phaseY = 0;

boolean beat1 = true;
String titleText = "";
float osc1 = 50;
float osc2 = 50;
int count1 = 0;
int count2 = 0;

boolean pulseOn = false;
boolean startCount1 = false;
boolean startCount2 = false;

PImage lbug;
//boolean osc = true;

boolean debug = false;
boolean lissalines = true;
boolean particlesOn = false;
boolean fractalsOn = false;
boolean springsOn = false;
boolean boidsOn = false;
boolean flockingOn = true;
boolean pathFollow = false;
PShape bulb;
int textAlpha = 0;
boolean textAlphaIncrease = false;
int alphaCount = 0;
boolean startAlphaCount = false;

String pulseText1 = "";
String pulseText2 = "";

Serial port;

int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 248);
int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 512;
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
Handle[] handles;

// SERIAL PORT STUFF TO HELP YOU FIND THE CORRECT SERIAL PORT
String serialPort;
String[] serialPorts = new String[Serial.list().length];
boolean serialPortFound = false;
int numPorts = serialPorts.length;
boolean refreshPorts = false;
float wave;

PFont font;
PFont fontSmall;

void setup() {
  //size(2000, 1200, P2D);
  fullScreen(P2D);
  cols = 1;//width/w;
  rows = 1;//height/w;
  curves = new Curve[rows][cols];
  for (int i =0; i < cols; i++) {
    for (int j =0; j < rows; j++) {
      curves[j][i] = new Curve();
    }
  }

  font = createFont("FoundersGroteskCondensed-Bold.otf", 150);
  fontSmall = createFont("FoundersGroteskCondensed-Bold.otf", 70);

  wingImages = new PImage[imageCount];

  //loadWings();
  lbug = loadImage("bug-01.png");
  smooth();
  vertGuides = new Guide[rows];
  for (int i = 0; i < rows; i ++) {
    vertGuides[i] = new Guide(true);
  }
  horizGuides = new Guide[cols];

  for (int i = 0; i < cols; i ++) {
    horizGuides[i] = new Guide(false);
  }

  bulb = loadShape("bulb.png");

  int num = height/15;
  //handles = new Handle[num];
  int hsize = 10;
  //for (int i = 0; i < handles.length; i++) {
  //handles[i] = new Handle(width/2, 10+i*15, 50-hsize/2, 10, handles);
  //}

  //try {
  //  port = new Serial(this, Serial.list()[i], 115200);  // make sure Arduino is talking serial at this baud rate
  //  delay(1000);
  //  println(port.read());
  //  port.clear();            // flush buffer
  //  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
  //  serialPortFound = true;
  //}

  port = new Serial(this, "/dev/tty.usbmodem1431", 115200);

  //wings sprite

  noCursor();

  logo = loadImage("hmsg-hog-s2.png");
  smooth();
}

void draw() {
  if (serialPortFound) {
    // ONLY RUN THE VISUALIZER AFTER THE PORT IS CONNECTED

    // PRINT THE DATA AND VARIABLE VALUES
  } else { // SCAN BUTTONS TO FIND THE SERIAL PORT

    autoScanPorts();

    if (refreshPorts) {
      refreshPorts = false;
    }

    background(255);

    //for (int i = 0; i < handles.length; i++) {
    //handles[i].update();
    //handles[i].display();
    //}
    stroke(255);
    noFill();
    println(textAlpha);

    fill(0, 0, 0, textAlpha);
    textFont(font);

    //textSize(150);
    textAlign(LEFT);
    text(pulseText1, 80, height/2); 
    textAlign(RIGHT);
    text(pulseText2, width-80, height/2); 

    //horiz
    for (int i = 0; i < cols; i ++) {
      horizGuides[i].update(osc1);//i+phaseX);
      horizGuides[i].display();

      for (int j = 0; j < rows; j++) {
        curves[j][i].setX(horizGuides[i].cx+horizGuides[i].x);
      }
    }
    //vert
    for (int i = 0; i < rows; i ++) {
      vertGuides[i].update(osc2);//i);
      vertGuides[i].display();

      for (int j = 0; j < cols; j++) {
        curves[i][j].setY(vertGuides[i].cy+vertGuides[i].y);
      }
    }

    for (int j =0; j < rows; j++) {
      for (int i =0; i < cols; i++) {
        curves[j][i].addPoint(frameCount);
        curves[j][i].show(frameCount+i+j);
      }
    }

    angle-= angleRes;

    if (angle < -TWO_PI) {
      for (int j = 0; j < rows; j++) {
        for (int i = 0; i < cols; i++) {
          curves[j][i].reset();
        }
      }
      angle = 0;
    }

    checkPulse();
  }

  if (textAlphaIncrease) {
    textAlpha++;
  }

  if (textAlpha >= 150) {
    textAlphaIncrease = false;
  }

  if (textAlphaIncrease == false && startAlphaCount) {
    alphaCount++;
    if (alphaCount >= 30) {
      textAlpha--;
      if (textAlpha <= 0) {
        textAlpha = 0;
        alphaCount = 0;
        startAlphaCount = false;
      }
    }
  }
  image(logo, width/2-logo.width/2, height-50-logo.height);
  fill(0);
  textAlign(CENTER);
  textFont(fontSmall);
  //textSize(70);

  text(titleText, width/2, 50+70);
}

void keyPressed() {
  if (key == '*') particlesOn = !particlesOn;


  if (keyCode == ENTER) {
    saveFrame();
  } else if (keyCode == BACKSPACE) {
    if (titleText.length()>0) {
      titleText=titleText.substring(0, titleText.length()-1);
    }
  } else   if (key == '`') {
    textAlphaIncrease = true;
    if (beat1) {
      count1 = 0;
      startCount1 = true;
    } else {
      count2 = 0;
      startCount2 = true;
    }
  } else {
    titleText+=key;
  }
}

void keyReleased() {
  if (key == '`') {
    startCount1 = false;
    startCount2 = false;
    curves[0][0].reset();
    beat1 = !beat1;
    startAlphaCount = true;
    flockingOn = false;
  }
}

void checkPulse() {
  if (startCount1) {
    count1++;
    osc1 = BPM;
    pulseText1 = str(BPM);
  } else if (startCount2) {
    count2++;
    osc2 = BPM;
    pulseText2 = str(BPM);
  } 
  //println("BPM: "+BPM);
}
void clearVisuals() {
  debug = false;
  lissalines = false;
  particlesOn = false;
  fractalsOn = false;
  springsOn = false;
  boidsOn = false;
}

void getPulse() {
  while (pulseOn) {
    if (startCount1) count1++;
    else if (startCount2) count2++;
    //}
    //return count;
  }
}



void autoScanPorts() {
  if (Serial.list().length != numPorts) {
    if (Serial.list().length > numPorts) {
      println("New Ports Opened!");
      int diff = Serial.list().length - numPorts;  // was serialPorts.length
      serialPorts = expand(serialPorts, diff);
      numPorts = Serial.list().length;
    } else if (Serial.list().length < numPorts) {
      println("Some Ports Closed!");
      numPorts = Serial.list().length;
    }
    refreshPorts = true;
    return;
  }
}

void resetDataTraces() {
  for (int i=0; i<rate.length; i++) {
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window
  }
  for (int i=0; i<RawY.length; i++) {
    RawY[i] = height/2; // initialize the pulse window data line to V/2
  }
}

void loadWings() {
  for (int i = 0; i < imageCount; i++) {
    // Use nf() to number format 'i' into four digits
    String filename = "data/lighteningbug_" + nf(i, 5) + ".png";
    println(filename);
    //wImage = loadImage(filename);
    wingImages[i] = loadImage(filename);
  }
}
