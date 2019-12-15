class Mur {
  float x, y; // Positions du mur.
  float h; // Dimention du mur.


  // Remarque: pas besoin d'avoir une épaisseur en x pour le mur, pour des raisons d'optimisation et de bon sens,
  // on a besoin que de la position x du mur pour tester si le joueur se trouve a gauche ou a droite,
  // ce qui revient à considérer qu'une seule dimention en plus : la hauteur du mur.

  // Initialisation
  Mur(float tx, float ty, float th) {
    x = tx;
    y = ty;
    h = th;
  }

  // Permet de savoir si la hitbox du joueur et le mur sont superposées.
  boolean collisionPotentielle() {
    boolean faceHaut = joueur.y-joueur.h/2 <= y+h/2 && joueur.y-joueur.h/2 >= y-h/2;
    boolean faceBas= joueur.y+joueur.h/2 <= y+h/2 && joueur.y+joueur.h/2 >= y-h/2;
    return faceHaut || faceBas;
  }
}
