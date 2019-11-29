class Plateforme {
  float x, y; // Positions de la plateforme.
  float w; // Dimention de la plateforme.
  boolean collisionPermanente = false; // Permet d'empêcher le joueur de descendre de cette plateforme en passant au travers.

  // Remarque: pas besoin d'avoir une épaisseur en y pour la plateforme, pour des raisons d'optimisation et de bon sens,
  // on a besoin que de la position y de la plateforme pour tester si le joueur se trouve au dessus ou en dessous,
  // ce qui revient à considérer qu'une seule dimention en plus : la largeur de la plateforme.


  // Initialisation
  Plateforme(float tx, float ty, float tw) {
    x = tx;
    y = ty;
    w = tw;
  }
  
  // Permet de savoir si la hitbox du joueur et la plateforme sont superposées.
  boolean collisionPotentielle() {
    boolean faceGauche = joueur.x-joueur.w/2 >= x-w/2 && joueur.x-joueur.w/2 <= x+w/2;
    boolean faceDroite = joueur.x+joueur.w/2 >= x-w/2 && joueur.x+joueur.w/2 <= x+w/2;
    return faceDroite || faceGauche;
  }
}
