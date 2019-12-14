// jamais utilisée directement.
class Item {
  boolean ramasse = false;
  Sprite sprite;
  float x;
  float y;
  float dy = 10;
  float oldy = 1;
  float vy = 0.5;
  SoundFile bruit;
  
  Item(float tx, float ty){
    x = tx;
    y = ty;
    oldy = y;
    sprite = new Sprite(x,y);
    loadingRessource = "loading item.mp3";
    bruit = new SoundFile(LeBouchonOr.this, "item.mp3");
    loadingProgress--;
  }

  void actualiser() {
    if (!ramasse) {
      // Animation
      y += vy;
      if (y < oldy-dy) {
        y = oldy-dy;
        vy *= -1;
      } else if (y > oldy) {
        y = oldy;
        vy *= -1;
      }
      //Collision avec le joueur
      boolean collision = collisionRectangles(joueur.x,joueur.y,joueur.w,joueur.h,x,y,sprite.width(),sprite.height());
      if(collision){
        collisionJoueur();
      }
    }
  }

  void afficher() {
    if (!ramasse) {
      sprite.changeCoordonnee(x, y);
      sprite.afficher();
    }
  }
  
  public void collisionJoueur(){
    
  }
  
  void reinitialiser(){
      ramasse = false;
  }
}

class PainBouchon extends Item {
  PainBouchon(float tx, float ty){
    super(tx, ty);
    sprite.chargeImage("pain_bouchon.png");
  }
  
  // A ecraser
  void collisionJoueur(){
    if(joueur.vie < 100){
      ramasse = true;
      bruit.play();
      joueur.vie = 100;
    }
  }
}

class SavateMagique extends Item {
  SavateMagique(float tx, float ty){
    super(tx, ty);
    sprite.chargeImage("savate.png");
  }
  
  // A ecraser
  void collisionJoueur(){
    ramasse = true;
    bruit.play();
    joueur.superSaut = true;
    niveauErmitage.dialogueSavate = true;
  }
}

class Combinaison extends Item {
  Combinaison(float tx, float ty){
    super(tx, ty);
    sprite.chargeImage("combinaison.png");
  }
  
  // A ecraser
  void collisionJoueur(){
    ramasse = true;
    bruit.play();
    joueur.invulnerableLave = true;
    niveauVille.dialogueCombinaison = true;
  }
}
