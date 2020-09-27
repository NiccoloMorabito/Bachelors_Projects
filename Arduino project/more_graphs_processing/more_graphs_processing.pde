import processing.serial.*;
Serial port;
int xPos=50;
float inByte=0;

// number of graphs (i.e. number of sensors)
int numSensors = 4;

// partial screen height
float partHeight;

// arrays for sensors
float[] values = new float[numSensors];
int[] min = new int[numSensors];
int[] max = new int[numSensors];
color[] valColor = new color[numSensors];  
String[] names = 
{ "Light sensor",
  "Digital Temperature sensor",
  "Temperature sensor",
  "Humidity sensor"
};

boolean clearScreen = true;

void setup() {
  // serial port of Arduino
  port = new Serial(this, "COM4", 9600);  
  port.bufferUntil('\n');
  
  // Size of the windows
  size(1800, 900);
  // Size of partial screen
  partHeight = height / numSensors;
  
  textSize(15);
  
  // Background color (black)
  background(0);
  
  // INITIALIZE ARRAYS FOR SENSORS
  // Light graph
  values[0] = 0;
  min[0] = 0;
  max[0] = 1023;
  valColor[0] = color(0, 0, 255); // blue
  
  // Digital Temperature graph
  values[1] = 0;
  min[1] = -50;
  max[1] = 50;
  valColor[1] = color(255, 0, 0); // red
  
  // Temperature graph
  values[2] = 0;
  min[2] = -50;
  max[2] = 50;
  valColor[2] = color(0, 255, 0); // green
  
  // Humidity graph
  values[3] = 0;
  min[3] = 0;
  max[3] = 200;
  valColor[3] = color(255, 255, 255); // white
}

void draw() {
  
  if (clearScreen) {
    // clean screen with translucent black
    fill(0,200);
    noStroke();
    rect(0,0,width,height);

    clearScreen = false; // reset flag
  }
  
  // draw y=0 line for the two sensors that have the negative part
  stroke(255);
  float h0y_digitalTemp = partHeight*2 - partHeight/2;
  float h0y_temp = partHeight*3 - partHeight/2;
  text("0", 0, h0y_digitalTemp+1);
  line(15, h0y_digitalTemp, width, h0y_digitalTemp);
  text("0", 0, h0y_temp+1);
  line(15, h0y_temp, width, h0y_temp);
  
  for (int i=0; i<numSensors; i++) {

    // map to the range of partial screen height:
    float mappedVal = map(values[i], min[i], max[i], 0, partHeight);

    // draw line of the graph
    stroke(valColor[i]);
    // the first and the last graph works normally
    if (i==0 || i==3)
      line(xPos, partHeight*(i+1), xPos, partHeight*(i+1) - mappedVal);
    // while the graphs for temperature have negative part
    else
      line(xPos, partHeight*(i+1)-partHeight/2, xPos, partHeight*(i+1) - mappedVal);

    // draw dividing line:
    stroke(255);
    line(0, partHeight*(i+1), width, partHeight*(i+1));

    // display values on screen:
    text(names[i], 2, partHeight*i+20);
    fill(50);
    noStroke();
    rect(0, partHeight*i+25, 80, 20);
    fill(255);
    text(round(values[i]), 2, partHeight*i+40);
    fill(125);
    text(max[i], 40, partHeight*i+40);

  }
  
  xPos++;
  
  // if at the edge of the screen, go back to the beginning:
  if (xPos > width) {
    xPos = 50;
    clearScreen = true;
  }
  
}

void serialEvent(Serial port) {
  try {
    String string = port.readStringUntil('\n');

    if (string != null) {
      string = trim(string);

      // split the string on the , and convert the resulting substrings into an float array
      values = float(splitTokens(string, ","));
    }
  }
  catch(RuntimeException e) {
    e.printStackTrace();
  }

}
