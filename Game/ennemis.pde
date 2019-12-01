class Mercenaire {

  float x, y; // Positions
  float h, w; // Dimensions de la hitbox.
  float l1, l2; // Limites du déplacement de l'ennemi sur l'axe x.
  boolean aligneDroite; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
  float vitesseDeplacement = 2; // A quelle vitesse il se déplace.
  int degats = 10; // Dégats de base.

  int vie = 100; // Quantité de vie.
  int level = 1; // level de l'ennemi, ses dégats y sont proportionnels, ainsi que sa résistance.
  float detection = 300; // Rayon de détection du joueur.

  boolean estBlesse = false; // Permet d'eviter que le joueur le tue instantanément.


  // Le projectil de l'ennemi.
  float balleX = 0;
  float balleVitesse = 5;

  // Déplacement maximal de la balle par rapport à son point d'origine.
  float balleMaxDeplacement = 500;

  // Dimension de la balle.
  float balleW = 16;
  float balleH = 8;

  boolean tire; // Permet de figer l'ennemi.
  boolean balleCollision = false; // Permet de cacher la balle et d'ignorer les collisions.

  SoundFile sonAttaque;
  SoundFile sonMeurt;


  private int type; // Le type de mercenaire, ils ont des comportements légèrements différents.
  // 1 = mercenaire immobile, il ne fait que tirer lorsque le joueur est a porté et frappe le joueur si il sont superposées.
  // 2 = mercenaire qui peut bouger, tirer et frapper le joueur.
  // 3 = mercenaire avec une machette, attaque uniquement au corps à corps.

  // Animations.
  Sprite spriteCourse;
  Sprite spriteAttaqueCorps;
  Sprite spriteAttaquePistolet;
  Sprite spriteImmobile;

  Horloge horlogeAttaqueCorps; // Après avoir frappé au coprs à coprs, l'ennemi ne se déplace plus pendant un court instant.
  Horloge horlogeSeRetourner; // Les ennemis de type 1 sont immobiles, mais ils peuvent se retrouner.

  Mercenaire(float tx, float ty, float tdw, int type) {
    // Dimension de la hitbox de l'ennemi.
    w = 35; // épaisseur
    h = 50; // largeur
    // Placement
    x = tx;
    y = ty-(h+70)/2;
    // Limites des déplacements.
    l1 = x-tdw/2;
    l2 = x+tdw/2;
    // Alignement initial.
    aligneDroite = random(0, 2) > 1 ? true : false;
    // Le type de mercenaire.
    this.type = type;

    // Chargement des animations.
    // Déplacements.
    spriteCourse = new Sprite(x, y);
    spriteCourse.vitesseAnimation = 45;
    spriteCourse.loop = true;
    spriteCourse.anime = true;

    //Attaque corps à corps.
    spriteAttaqueCorps = new Sprite(x, y);
    spriteAttaqueCorps.vitesseAnimation = 32;

    //Attaque au pistolet.
    spriteAttaquePistolet = new Sprite(x, y);
    spriteAttaquePistolet.vitesseAnimation = 45;

    //Immobilité
    spriteImmobile = new Sprite(x, y);
    spriteImmobile.vitesseAnimation = 45;
    spriteImmobile.loop = true;
    spriteImmobile.anime = true;

    // On charge les ressources nécessaires.
    if (type == 3) {
      spriteCourse.chargeAnimation("Mercenaire3/Course/", 16, 4);
      spriteAttaqueCorps.chargeAnimation("Mercenaire3/Attaque/", 16, 4);
    } else if (type == 1) {
      spriteAttaquePistolet.chargeAnimation("Mercenaire1/Tire/", 8, 4);
      spriteImmobile.chargeAnimation("Mercenaire1/Immobile/", 16, 4);
    } else if (type == 2) {
      spriteCourse.chargeAnimation("Mercenaire2/Course/", 16, 4);
      spriteAttaquePistolet.chargeAnimation("Mercenaire2/Tire/", 8, 4);
      spriteImmobile.chargeAnimation("Mercenaire2/Immobile/", 16, 4);
    }
    if (type != 3) {
      sonAttaque = new SoundFile(Game.this, "pistol.wav");
    } else {
      sonAttaque = new SoundFile(Game.this, "swish_2.wav"); 
    }
    
    sonMeurt = new SoundFile(Game.this, "mort_mercenaire.wav");

    horlogeAttaqueCorps = new Horloge(1000); // Attente d'1 seconde.
    horlogeSeRetourner = new Horloge(4000); // Attente de 4 secondes
  }


  // Gestion de la logique.
  void actualiser() {

    // Effectivement quand on est mort on ne peut rien faire...
    if (vie > 0) {
      
      // Si le joueur frappe et que l'ennemis est dans la hitbox de touche.
      if (joueur.spriteFrappe.anime) { 
        boolean collision;
        // La hitbox du joueur est orientée.
        if (joueur.aligneDroite)
          collision = collisionRectangles(joueur.x+joueur.w, joueur.y, joueur.w*3, joueur.h, x, y, w, h);
        else
          collision = collisionRectangles(joueur.x-joueur.w, joueur.y, joueur.w*3, joueur.h, x, y, w, h);
        // On vérifie que le joueur ne puisse pas "mitrailler l'ennemi".
        if (collision && !estBlesse) {
          vie -=(int) (float(joueur.degats*joueur.level) * 2.0/float(level)); // On perd de la vie
          estBlesse = true;
          if (vie <= 0){ // Si on est mort alors le joueur gagne de l'xp.
            joueur.gagneXp(level*2);
            sonMeurt.play();
          }
        }
      } else {
        estBlesse = false;  
      }
      
      //Si le joueur lui tire dessus:
      if(joueur.aTire && !joueur.ennemiTouche){
        boolean collision = collisionRectangles(joueur.balleX, joueur.balleY, joueur.balleW, joueur.balleH, x, y, w, h);
        if(collision){
            vie -=(int) (float(joueur.degats*joueur.level) * 2.0/float(level)); // On perd de la vie
            joueur.ennemiTouche = true;
            if (vie <= 0){ // Si on est mort alors le joueur gagne de l'xp.
            joueur.gagneXp(level*2);
            sonMeurt.play();
          }
        }
      }


      // Seul les mercenaires de type 2 et 3 sont capables de se déplacer.
      if (type != 1) {
        // Il faut que, le joueur soir dans le zone de détection, que l'ennemis ne soit plus en train de viser ou qu'il ne soit plus en train de tirer.
        if (horlogeAttaqueCorps.tempsEcoule && !tire) {
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
      } 
      // Ennemi de type 1
      else {
        // L'ennemi de type 1 se retourne toutes les 4 secondes.
        if (horlogeSeRetourner.tempsEcoule && !tire) {
          aligneDroite = !aligneDroite; // On se retourne.
          horlogeSeRetourner.lancer();
        }
      }


      // Attaque corps à corps/dégats infligés au contact uniquement pour l'ennemi 3.
      if (type == 3) {
        boolean collisionJoueur = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, x, y, w, h);
        // Si il y a eu une collision avec le joueur et que l'ennemi n'est pas "en cours" d'attaque, on blesse le joueur.
        if (collisionJoueur && horlogeAttaqueCorps.tempsEcoule) {
          float direction = (joueur.x-x)/abs(joueur.x-x);
          float repousse = 200 * direction;
          aligneDroite = (direction > 0);
          joueur.degatsRecu((int) (degats*level/1.5), repousse);
          sonAttaque.play();
          spriteAttaqueCorps.reinitialiser(); // On relance l'animation d'attaque. N'est effectif que si l'ennemi est de type 3, si non le sprite n'est pas affiché.  
          horlogeAttaqueCorps.lancer(); // On lance l'attente avant d'effectuer d'autres actions.
        }
      } else {
        // Le joueur est détecté par le tireur.
        // Il faut que, le joueur soir dans le zone de détection, que l'ennemis ne soit plus en train de viser ou qu'il ne soit plus en train de tirer.
        boolean LigneDeMire = y < joueur.y+joueur.h/2 && y > joueur.y-joueur.h/2;
        if (LigneDeMire && !tire) {
          if (aligneDroite && joueur.x-x >= 0 && joueur.x-x < detection) {
            tire = true;
            balleX = x;
            balleCollision = false;
            sonAttaque.play();
            spriteAttaquePistolet.reinitialiser();
          } else if (!aligneDroite && x-joueur.x >= 0 && x-joueur.x < detection) {
            tire = true;
            balleX = x;
            balleCollision = false;
            sonAttaque.play();
            spriteAttaquePistolet.reinitialiser();
          }
        }

        // On actialise les positions de la balle.
        if (tire) {
          if (aligneDroite)
            balleX += balleVitesse;
          else
            balleX -= balleVitesse;

          if (abs(balleX-x) > balleMaxDeplacement){ // On peut re tirer.
            tire = false;
            balleCollision = true;
          }
        }

        // Si il y a eu une collision avec le joueur, on lui retire de la vie et on masque la balle et on désactives les collisions.
        if (!balleCollision && type != 3) {
          boolean toucheJoueur = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, balleX, y, balleW, balleH);
          if (toucheJoueur) {
            balleCollision = true;
            float direction = (joueur.x-balleX)/abs(joueur.x-balleX);
            float repousse = 200 * direction;
            joueur.degatsRecu(degats*level, repousse);
          }
        }
      }

      // On actualise les chronos.
      horlogeAttaqueCorps.actualiser();
      horlogeSeRetourner.actualiser();
    }
  }

  // Gestion de l'affichage.
  void afficher() {
    
    if (vie > 0) {
      if (aligneDroite) {
        spriteCourse.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
        spriteAttaqueCorps.mirroir = false;
        spriteAttaquePistolet.mirroir = false;
        spriteImmobile.mirroir = false;
      } else {
        spriteCourse.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
        spriteAttaqueCorps.mirroir = true;
        spriteAttaquePistolet.mirroir = true;
        spriteImmobile.mirroir = true;
      }

      // Différents affichages en fonction du type.
      // Si on est en attaque.
      if (!horlogeAttaqueCorps.tempsEcoule && type == 3) {
        spriteAttaqueCorps.changeCoordonnee(x, y);
        spriteAttaqueCorps.afficher();
      } 
      // si non il se peut que l'on tire.
      else if (type != 3 && tire) {
        spriteAttaquePistolet.changeCoordonnee(x, y);
        spriteAttaquePistolet.afficher();
      }
      // Si non on est en déplacement. Uniquement pour les ennemis 2 et 3.
      else if (type != 1) {
        spriteCourse.changeCoordonnee(x, y);
        spriteCourse.afficher();
      } else if (type != 3) { // Si non, on est immobile.
        spriteImmobile.changeCoordonnee(x, y);
        spriteImmobile.afficher();
      }

      //Barre de vie.
      noStroke();
      //fond de la barre de vie.
      fill(50, 50, 50);
      rectMode(CORNER);
      rect(x-50, y-75, 100, 4);

      // Barre de vie.
      fill(255, 0, 0);
      rect(x-50, y-75, vie, 4);

      //Affichage du niveau
      textSize(14);
      textAlign(CENTER, TOP);
      fill(0);
      text("lvl "+str(level), x+1, y-74);
      fill(255);
      text("lvl "+str(level), x, y-75);

      // Affichage de la balle.
      if (tire && !balleCollision) {
        rectMode(CENTER);
        fill(255, 255, 0);
        noStroke();
        rect(balleX, y, balleW, balleH);
      }

      //***************** DEBUGAGE ************ //
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
        line(x, y-h/3, x+dx, y-h/3);
      }
    }
  }
}
