class Camera {
  float x, y;
  float margeX;
  float margeY;
  
  // déplacement de la caméra lors de la frame, permet d'implémenter le parallax.
  float dx = 0;
  float dy = 0;

  Camera() {
    x = width/2;
    y = height/2;
    margeX = 0;
    margeY = height/6;
  }

  void actualiser() {
    dx = 0;
    dy = 0;
    dx = joueur.x-camera.x;
    x = joueur.x;
    if (joueur.y < y-margeY){
      dy = y-margeY-joueur.y;
      y -= dy;
    } else if(joueur.y > y+margeY){
      dy = joueur.y - y-margeY;
      y += dy; 
    }
    
    if (x-width/2 < 0){
      x = width/2;
      dx = 0;
    } else if (x+width/2 > 3*width) {
      dx = 0;
      x = 3*width-width/2;
    }
    if (y-height/2 < -height){
      dy = 0;
      y = -height/2;
    } else if (y+height/2 > height){
      dy = 0;
      y = height/2;
    }
  }

  void deplaceRepere() {
    translate(width/2 - x, height/2 - y);
  }
}
