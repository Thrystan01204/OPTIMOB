class Mercenaire {

  float x, y; // Positions
  float h, w; // Dimensions de la hitbox.
  float l1, l2; // Limites du déplacement de l'ennemi sur l'axe x.
  boolean aligneDroite; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
  float vitesseDeplacement = 2;
  Sprite spriteMarche;
  int xp = 1; // XP de l'ennemi, ses dégats y sont proportionnels.
  int degats = 10;

  float detection = 400; // Rayon de détection du joueur.

  int type; // Le type de mercenaire, ils ont des comportements légèrements différents.
  // 1 = mercenaire immobile, il ne fait que tirer lorsque le joueur est a porté et frappe le joueur si il sont superposées.
  // 2 = mercenaire qui peut bouger, tirer et frapper le joueur.
  // 3 = mercenaire avec une machette, attaque uniquement au corps à corps.

  Sprite sprite; // Image.
  
  Horloge horlogeAttaqueCorps; // Après avoir frappé au coprs à coprs, l'ennemi ne se déplace plus pendant un court instant.



  Mercenaire(float tx, float ty, float tdw, int type) {
    // Dimension de la hitbox de l'ennemi.
    w = 35; // épaisseur
    h = 120; // largeur
    // Placement
    x = tx;
    y = ty-h/2;
    // Limites des déplacements.
    l1 = x-tdw/2;
    l2 = x+tdw/2;
    // Alignement initial.
    aligneDroite = random(0, 2) > 1 ? true : false;
    // Le type de mercenaire.
    this.type = type;
    
    // Chargement des animations.
    sprite = new Sprite(x, y);
    sprite.chargeImage("Mercenaire3/defaut.png");
    
    horlogeAttaqueCorps = new Horloge(1000); // Attente d'1 seconde.
  }


  // Gestion de la logique.
  void actualiser() {
    
    // Seul les mercenaires de type 2 et 3 sont capables de se déplacer.
    if (type != 1 && horlogeAttaqueCorps.tempsEcoule) {
      // On avance dans la même direction que l'alignement de du sprite.
      if (aligneDroite) {
        x += vitesseDeplacement;
      } else {
        x -= vitesseDeplacement;
      }
      
      // Si on arrive aux limites, on revient sur ses pas.
      if (x < l1) {
        aligneDroite = true;
        x = l1;
      } else if (x > l2) {
        aligneDroite = false;
        x = l2;
      }
    }
    
    boolean collisionJoueur = collisionRectangles(joueur.x,joueur.y,joueur.w,joueur.h,x,y,w,h);
    // Si il y a eu une collision avec le joueur et que l'ennemi n'est pas "en cours" d'attaque, on blesse le joueur.
    if(collisionJoueur && horlogeAttaqueCorps.tempsEcoule){
      float repousse = joueur.x-x > 0 ? 200 : -200;
      joueur.degatsRecu(degats*xp, repousse);
      horlogeAttaqueCorps.lancer(); // On lance l'attente avant d'effectuer d'autres actions.
    }
    
    // On actualise les chronos.
    horlogeAttaqueCorps.actualiser(); 
    
    
  }

  // Gestion de l'affichage.
  void afficher() {
    if (aligneDroite) {
      sprite.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
    } else {
      sprite.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
    }
    
    sprite.changeCoordonnee(x,y);
    sprite.afficher();
    if (debug) {
      // Affichage de la hitbox.
      noFill();
      stroke(255, 0, 0);
      rectMode(CENTER);
      rect(x, y, w, h);
      // Affichage de la zone de déplacement.
      stroke(0, 0, 255);
      line(l1, y, l2, y);
      //Affichage du rayon de détection.
      stroke(255, 0, 0);
      float dx = aligneDroite ? detection : - detection;
      line(x,y-h/3, x+dx, y-h/3);
    }
  }
}
