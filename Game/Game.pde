PGraphics canvas;

void setup(){
  size(1280, 720);
  surface.setResizable(true);
  canvas = createGraphics(1920, 1080);
  smooth(0);
}

void draw(){
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
  
  image(canvas, 0, 0);
  textSize(24);
  fill(255, 0, 0);
  text(frameRate, 32, 32);
}
