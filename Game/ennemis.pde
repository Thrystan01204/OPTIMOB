class Mercenaire{
  
  float x, y; // Positions
  float h, w; // Dimensions de la hitbox.
  float l1, l2; // Limites du déplacement de l'ennemi sur l'axe x.
  boolean aligneDroite; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
  float vitesseDeplacement = 2;
  Sprite spriteMarche;
  
  
  
  Mercenaire(float tx, float ty, float tdw){
    // Dimension de la hitbox de l'ennemi.
    w = 35; // épaisseur
    h = 120; // largeur
    
    x = tx;
    y = ty-h/2;
    l1 = x-tdw/2;
    l2 = x+tdw/2;
    aligneDroite = random(0,2) > 1 ? true : false;
    
    
    
  }
  
  void actualiser(){
      if(aligneDroite){
        x += vitesseDeplacement;  
      } else {
        x -= vitesseDeplacement;  
      }
      
      if(x < l1){
        aligneDroite = true;
        x = l1;
      } else if(x > l2){
        aligneDroite = false;
        x = l2;
      }
  }
  
  void afficher(){
    if(debug){
      // Affichage de la hitbox.
      noFill();
      stroke(255, 0, 0);
      rectMode(CENTER);
      rect(x, y, w, h);
      // Affichage de la zone de déplacement.
      stroke(0, 0, 255);
      line(l1, y, l2, y);
    }
  }
}
