/**
    Comp 494 Spring '17 Assignment #1 Text Rain
**/


import processing.video.*;
import java.util.LinkedList;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;

String spiders = "the itsy bitsy spider climbed up the waterspout down came the rain and washed the spider out out came the sun and dried up all the rain and the itsy bitsy spider climbed up the spout again";
int spiders_length = spiders.length();
String[] spider_list = split(spiders," "); //37 words 

PImage spooky_spider;
int sy;
int sx;
boolean spd;

LinkedList<fallingChar> fallingChars;

boolean viewerImage = true;
float threshold = 0.5;
float millisLastFrame = millis();

void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  textFont(loadFont("Times-Roman-48.vlw"));
  fallingChars = new LinkedList<fallingChar>();
  spooky_spider = loadImage("spider.png");
  sy = -150;
  sx = 0;
  spd = false;
}

boolean valid_pos(fallingChar c, PImage i) {
  if(c.y < 8) {
    return true;
  } else if(i.get((int)c.x,(int)c.y - 2) == 0xffffffff && 
      i.get((int)c.x - 5,(int)c.y - 7) == 0xffffffff &&
      i.get((int)c.x - 5,(int)c.y - 2) == 0xffffffff && 
      i.get((int)c.x + 5,(int)c.y - 2) == 0xffffffff && 
      i.get((int)c.x + 5,(int)c.y - 7) == 0xffffffff) {
        return true;
    } else {
      return false;
    }
}



void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  fill(0, 0, 255);
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  } 
  
  textAlign(CENTER,BOTTOM);


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.

  
  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable
  
  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
  }
  else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..
  
  inputImage.filter(GRAY); //converts the input image to greyscale
  inputImage.loadPixels();

  PImage mirroredImage = createImage(inputImage.width, inputImage.height, RGB);
  
  mirroredImage.updatePixels();
  
  for(int x = 0; x < inputImage.width; x++) { //swap these two to save power
    for(int y = 0; y < inputImage.height; y++) {
      int newX = (inputImage.width - x) - 1;
      mirroredImage.pixels[y * width + newX] = inputImage.pixels[y * width + x];
    }
  }
  mirroredImage.updatePixels();

  PImage threshHoldImage = mirroredImage.copy();
  threshHoldImage.filter(BLUR);
  threshHoldImage.filter(THRESHOLD, threshold);

  // Tip: This code draws the current input image to the screen
  if(viewerImage) {
    set(0, 0, mirroredImage);
  } else {
    set(0, 0, threshHoldImage);
    text("Threshold: " + threshold, 150, height - 20);
  }
  
  //image(spooky_spider, 50, 100, 100, 200);
  
  if(fallingChars.size() >= 100) {
    fallingChars.remove(0);
  }
  
  if(random(1) < (1/20.0)) {
    int w = (int) random(0, 37);
    String word = spider_list[w];
    //String word = "spider";
    float start_word = random(0, width);
    if(word.equals("spider")) {
      sx = (int) start_word;
      spd = true;
    }
    for(int i = 0; i < word.length(); i++) {
      char c = word.charAt(i);
      fallingChars.add(new fallingChar(c, start_word + i*20, 0.0, random(25, 35)));
    }
  } else if(random(1) < (1/2.0)) { //Change to take from itsy bitsy spider
      float ch = random(0, spiders_length);
      fallingChars.add(new fallingChar((char)spiders.charAt((int)ch), random(0, width), 0.0, random(20, 50)));
  }
  
  for(fallingChar c : fallingChars) {
    if(valid_pos(c, threshHoldImage)){
          c.y += c.v * (millis()-millisLastFrame)/1000.0;
    } while(!valid_pos(c, threshHoldImage)) {
        c.y -= 1;
    }
    
    text(c.letter, c.x, c.y);
  }
  millisLastFrame = millis();
  
  if(spd) {
    if(sy <= 50) {
      sy+=5;
      image(spooky_spider, sx, sy + 50, 100, 200);
    } else if (sy > 50) {
      sy = -150;
      sx = 0;
      spd = false;
    }
  }

}



void keyPressed() {
  
  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput.mov");
        mov.loop();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..
  
  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      threshold += 0.1;
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      threshold -= 0.1;
    }
  }
  else if (key == ' ') {
    viewerImage = !viewerImage;
    // space bar pressed
  } 
  
}

class fallingChar{
  char letter;
  float x;
  float y;
  float v;
  
  public fallingChar(char letter, float x, float y, float v) {
    this.letter = letter;
    this.x = x;
    this.y = y;
    this.v = v;
  }
}