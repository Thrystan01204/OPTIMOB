import processing.sound.*;

SoundFile titleMusic;

PImage bg;
PImage cloud1;
PImage cloud2;

PImage newGameButton;
PImage loadGameButton;
PImage quitGameButton;

PImage newGameHoverButton;
PImage loadGameHoverButton;
PImage quitGameHoverButton;

int nbLoaded = 0;

float transition = 0;
float transitionSpeed = 0.005;

float cloud1x;
float cloud2x;

void setup(){
  size(1280, 720);
  thread("loadResources");
}

void draw(){
  if(nbLoaded != 10) {
    background(50, 50, 50);
    textSize(24);
    fill(255);
    textAlign(CENTER, CENTER);
    text("Loading...", width/2, 64);
    fill(255, 0, 0);
    float w = map(nbLoaded, 0, 7, 0, width);
    rect(0, height/2+64, w, 50);
  } else {
    background(bg);
    if(cloud1x+cloud1.width <= 0)
      cloud1x = width;
    if(cloud2x+cloud2.width <= 0)
      cloud2x = width;
    cloud1x -= 1;
    cloud2x -= 1;
    tint(255);
    image(cloud1, cloud1x, 0);
    image(cloud2, cloud2x, 0);
    
    int h = newGameButton.height;
    int w = newGameButton.width;
    //tint(255, 50, 50);
    if(541 <= mouseX && mouseX <= 541+w && height-164-h <= mouseY && mouseY <= height-164 && transition > 1)
      image(newGameHoverButton, 541, height-164-h);
    else
      image(newGameButton, 541, height-164-h);
      
    if(541 <= mouseX && mouseX <= 541+w && height-93-h <= mouseY && mouseY <= height-93 && transition > 1)
      image(loadGameHoverButton, 541, height-93-h);
    else
      image(loadGameButton, 541, height-93-h);
      
    if(541 <= mouseX && mouseX <= 541+w && height-22-h <= mouseY && mouseY <= height-22 && transition > 1)
      image(quitGameHoverButton, 541, height-22-h);
    else
      image(quitGameButton, 541, height-22-h);

    if(transition <= 1){
       fill(0, map(transition, 0, 1, 255, 0));
       rect(0, 0, width, height);
       transition += transitionSpeed;
    }
  }
}

void loadResources(){
  bg = loadImage("main_menu_bg.png");
  nbLoaded++;
  cloud1 = loadImage("cloud1.png");
  cloud1x = 96;
  nbLoaded++;
  cloud2 = loadImage("cloud2.png");
  cloud1x = 695;
  nbLoaded++;
  newGameButton = loadImage("new_game_button.png");
  nbLoaded++;
  loadGameButton = loadImage("load_game_button.png");
  nbLoaded++;
  quitGameButton = loadImage("quit_game_button.png");
  nbLoaded++;
  
  quitGameHoverButton = loadImage("quit_game_hover_button.png");
  nbLoaded++;
  loadGameHoverButton = loadImage("load_game_hover_button.png");
  nbLoaded++;
  newGameHoverButton = loadImage("new_game_hover_button.png");
  nbLoaded++;
  
  titleMusic = new SoundFile(this, "adventure.wav");
  nbLoaded++;
  titleMusic.loop();
  titleMusic.jump(12);
  
}
