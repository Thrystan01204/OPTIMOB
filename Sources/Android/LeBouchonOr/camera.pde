class Camera {
  float x, y; // Positions de la caméra.
  
  float margeY; // Zone sur l'axe y où le déplacement de la caméra n'est pas déclenché.
  
  // Quantité des déplacements de la caméra lors de la nouvelle "frame", permet d'implémenter le parallax.
  float dx = 0;
  float dy = 0;

  // Initialisation.
  Camera() {
    // La caméra est au centre de l'écran.
    x = cv.width/2;
    y = cv.height/2;
    // On précise la marge d'inactivité.
    margeY = cv.height/6;
  }
  
  // Actualisation de la position de la caméra.
  void actualiser() {
    // Pour le moment la caméra n'a pas bougée.
    dx = 0;
    dy = 0;
    
    // La caméra est centrée en x sur le joueur.
    dx = joueur.x-camera.x;
    x = joueur.x;
    
    // Si le joueur est hors de la zone Y d'inactivité, on déplace la caméra jusqu'à ce que le joueur soit dans la zone.
    if (joueur.y < y-margeY){
      dy = y-margeY-joueur.y;
      y -= dy;
    } else if(joueur.y > y+margeY){
      dy = joueur.y - y-margeY;
      y += dy; 
    }
    
    // Evidemment, on s'assure que la caméra ne sorte pas des limites du niveau.
    if (x-cv.width/2 < 0){
      x = cv.width/2;
      dx = 0;
    } else if (x+cv.width/2 > 3*cv.width) {
      dx = 0;
      x = 3*cv.width-cv.width/2;
    }
    if (y-cv.height/2 < -cv.height){
      dy = 0;
      y = -cv.height/2;
    } else if (y+cv.height/2 > cv.height){
      dy = 0;
      y = cv.height/2;
    }
  }
  
  // Permet de se placer dans le repère de la caméra lors de l'affichage d'un niveau, cela nous permet de continuer d'afficher les éléments dans le repère initial (donc avec des coordonées en absolues)
  // et de laisser processing calculer les translations pour transfomer les coordonnées en relatives.
  void deplaceRepere() {
    cv.translate(cv.width/2 - x, cv.height/2 - y); // L'opération qui effectue toute la magie.
  }
  
  void reinitialiser(){
    // La caméra est au centre de l'écran.
    x = cv.width/2;
    y = cv.height/2;
  }
}
