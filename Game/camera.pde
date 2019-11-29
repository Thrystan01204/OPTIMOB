class Camera {
  float x, y;
  float margeX;
  float margeY;

  Camera() {
    x = width/2;
    y = height/2;
    margeX = 0;
    margeY = height/6;
  }

  void actualiser() {
    x = joueur.x;
    if (joueur.y < y-margeY)
      y -= y-margeY-joueur.y;
    else if(joueur.y > y+margeY)
      y += joueur.y - y-margeY; 
    
    if (x-width/2 < 0)
      x = width/2;  
    else if (x+width/2 > 3*width)
      x = 3*width-width/2;
    if (y-height/2 < -height)
      y = -height/2;
    else if (y+height/2 > height)
      y = height/2;
  }

  void deplaceRepere() {
    translate(width/2 - x, height/2 - y);
  }
}
