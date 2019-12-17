class Joueur {
  boolean invulnerableLave = false; // Pour pouvoir avancer dans le jeu.
  boolean superSaut = false; // Pour pouvoir avancer dans le jeu.
  int compteurTemps = 0; // Permet de créer des évennements dans le temps.
  float x, y; // Positions du joueur
  float vx = 0; // Vitesse du joueur sur l'axe x (en pixels par secondes)
  float vy = 0; // Vitesse du joueur sur l'axe y (en pixels par secondes)
  float friction = 0.80; // Coefficient.
  float forceSaut = 1500; // En pixel par secondes
  float vitesseDeplacement = 400;  // En pixel par secondes
  float gravite = 4000; // En pixels par secondes carrés
  int xp = 0; // Quantité d'xp récupérée.
  int xpMax = 7; // Nombre d'xp pour monter de niveau.
  int level = 1; // Le niveau du personnage, ses dégats y sont proportionnels. Tout comme sa résistance.
  int levelMax = 10; // Niveau maximum du joueur.
  int vie = 100; // Le nombre de points de vie.
  int degats = 10; // Dégats de base au corps à corps.

  Sprite spriteCourse; // Animation de déplacement
  Sprite spriteImmobile; // Animation par défaut
  Sprite spriteTombe; // Animation lorsque le joueur retombe (une seule image pour le moment)
  Sprite spriteSaut; // Animation lorsque le joueur saute (une seule image pour le moment)
  Sprite spriteFrappe; // Animation lorsque le joueur frappe.
  Sprite spriteTire; // Animation lorsque le joueur tire;

  // Positions de la balle.
  float balleXInitiale;
  float balleX;
  float balleY;
  float balleMaxDistance = 300;
  float balleMaxDistanceWait = balleMaxDistance*2.7;
  float balleVitesse = 10;
  int balleDirection = 1; // Direction de la balle lorsqu'elle a été tirée.

  // Dimension de la balle.
  float balleW = 16;
  float balleH = 8;

  boolean aTire = false; // Permet de savoir quand pouvoir re tirer.
  boolean ennemiTouche = false; // Permet de désactiver le collision avec la balle et son affiche si elle a touchée un ennemi.


  boolean aligneDroite = true; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.

  // Dimension de la hitbox du joueur
  int w = 35; // épaisseur
  int h = 120; // largeur

  boolean surPlateforme = false; // Permet de savoir si le joueur ne doit plus tomber car il est sur une plateforme.

  // Les différents états du joueur
  boolean enDeplacement = false;
  boolean enAttaqueProche = false;
  boolean enAttaqueLongue = false;

  // Permet d'indiquer au système de collision que l'on veut descendre de la plateforme en passant au travers.
  boolean descendPlateforme = false;

  // Permet de corriger un bug de dépalcement lorsque le joueur a été poussé.
  boolean estPousse = false; 

  Horloge horlogeBlesse; // Lorsque le joueur est blessé il est invulnérable pendant un court instant.

  // Initialisation
  Joueur(float x, float y) {

    // On charge toutes les animations et on les configures :
    spriteCourse = new Sprite(x, y);
    spriteCourse.vitesseAnimation = 32; // 32 ms entre chaques images
    // On charge les images de l'animation, ici il y en a 16 et le nom est codé avec 4 entiers: 0001, ..., 0016.
    // Voir la classe sprite.
    spriteCourse.chargeAnimation("Martin/Course/", 16, 4);
    spriteCourse.loop = true; // L' animation recommence perpétuellement.
    spriteCourse.anime = true; // On lance l'animation.

    spriteImmobile = new Sprite(x, y);
    spriteImmobile.vitesseAnimation = 40;
    spriteImmobile.chargeAnimation("Martin/Immobile/", 16, 4);
    spriteImmobile.loop = true;
    spriteImmobile.anime = true;

    spriteFrappe = new Sprite(x, y);
    spriteFrappe.chargeAnimation("Martin/Frappe/", 8, 4);
    spriteFrappe.vitesseAnimation = 45;

    spriteTombe = new Sprite(x, y);
    spriteTombe.chargeImage("Martin/tombe.png");

    spriteSaut = new Sprite(x, y);
    spriteSaut.chargeImage("Martin/saut.png");

    spriteTire = new Sprite(x, y);
    spriteTire.chargeAnimation("Martin/Tire/", 8, 4);
    spriteTire.vitesseAnimation = 45;

    horlogeBlesse = new Horloge(1500); // On défini le chrono à 1 secondes.
  }

  // Gestion de la logique du joueur.
  void actualiser() {
    // Intégration numérique du mouvement avec la méthode d'euler.
    if (!surPlateforme) {
      // Intégration numérique de la vitesse.
      vy += gravite*dt; // On applique la gravité si le joueur n'est pas sur une plateforme.
    }

    // Intégration numérique des coordonnées.
    y += vy*dt;
    x += vx*dt;

    // Si on est sur une plateforme et que le jouer ne doit plus se déplacer, 
    // on ralenti son mouvement horizontal pour le rendre immobile.
    // Cela permet de donner une inertie au joueur.
    if (surPlateforme && !enDeplacement) {
      vx *= friction;
    }


    if (aTire) {
      balleX += balleVitesse * balleDirection;
      if (abs(balleXInitiale-balleX) > balleMaxDistance) {
        ennemiTouche = true;
      }
      if (abs(balleXInitiale-balleX) > balleMaxDistanceWait) {
        ennemiTouche = true;
        aTire = false;
      }
    }

    // On actualise les compteurs.
    horlogeBlesse.actualiser();
  }

  // Gestion de l'affichage du joueur.
  void afficher() {

    if (aligneDroite) {
      spriteCourse.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = false; // Même remarque ici
      spriteSaut.mirroir = false;
      spriteTombe.mirroir = false;
      spriteFrappe.mirroir = false;
      spriteTire.mirroir = false;
    } else {
      spriteCourse.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = true; // Même remarque ici;
      spriteSaut.mirroir = true;
      spriteTombe.mirroir = true;
      spriteFrappe.mirroir = true;
      spriteTire.mirroir = true;
    }

    // On clignote en rouge quand on est blessé.
    if (!horlogeBlesse.tempsEcoule) {
      float valeur = horlogeBlesse.compteur % 255;
      cv.tint(255, 255-valeur, 255-valeur);
    }

    // Chute libre.
    //Le joueur frappe.
    if (spriteFrappe.anime) {
      spriteFrappe.changeCoordonnee(x, y);
      spriteFrappe.afficher();
    } 
    // Le joueur Tire.
    else if (spriteTire.anime) {
      spriteTire.changeCoordonnee(x, y);
      spriteTire.afficher();
    } else if (vy > 0) {
      // On actualise les coordonnées du sprite sur celle du joueur.
      // Cela permet de séparer l'actualisation de la physique et l'actualisation de l'affichage.
      // La class Sprite n'est ni plus ni moins un sytème d'animation/affichage d'images,
      // ce qui n'a rien avoir avec la physique du jeu.
      spriteTombe.changeCoordonnee(x, y);
      // On affiche l'animation de fin de saut.
      spriteTombe.afficher();
    }
    // En montée.
    else if (vy < 0) {
      spriteSaut.changeCoordonnee(x, y);
      // On affiche l'animation de saut.
      spriteSaut.afficher();
    } 
    // Lorsque le joueur court.
    else if (enDeplacement) {
      spriteCourse.changeCoordonnee(x, y);
      // On affiche l'animation de course
      spriteCourse.afficher();
    }
    // Lorsque le joueur n'effectue aucune action.
    else {
      spriteImmobile.changeCoordonnee(x, y);
      // On affiche l'animation par défaut
      spriteImmobile.afficher();
    }
    cv.tint(255, 255, 255);

    // Affichage de la balle.
    if (aTire && !ennemiTouche) {
      cv.rectMode(CENTER);
      cv.fill(100, 255, 0);
      cv.noStroke();
      cv.rect(balleX, balleY, balleW, balleH);
    }

    //************** DEBUGAGE ************//
    if (debug) {
      // Affichage de la hitbox du joueur
      cv.noFill();
      cv.stroke(255, 0, 0);
      cv.rectMode(CENTER);
      cv.rect(x, y, w, h);
      if (spriteFrappe.anime) {
        //Hitbox de la frappe.
        cv.fill(255, 0, 0, 100);
        cv.stroke(255, 0, 0);
        cv.rectMode(CENTER);
        if (aligneDroite)
          cv.rect(x+w, y, 3*w, h);
        else
          cv.rect(x-w, y, 3*w, h);
      }
    }
  }

  // Permet de gérer les actions du joueur en fonction de la touche appuyée.
  void keyPressed() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Gestion du saut si le joueur se trouve sur une plateforme.
    if (k == 'Z' && surPlateforme) {
      // On applique une force verticale pour propulser le joueur en l'air.
      if (superSaut)
        vy = -forceSaut*1.25; 
      else
        vy = -forceSaut;

      surPlateforme = false; // On quite la plateforme.
      soundPool.play(sound_saut); // On lance le son du saut.
    } 
    // Gestion du déplacement vers la droite. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (k == 'D' && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer.
      vx = vitesseDeplacement; // On se déplace à une vitesse constante vers la droite.
      aligneDroite = true; // Le joueur est tourné vers la droite.
    } 
    // Gestion du déplacment vers la gauche. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (k == 'Q' && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer. 
      vx = -vitesseDeplacement; // On se déplace à une vitesse constante vers la gauche.
      aligneDroite = false; // Le joueur est tourné vers la gauche.
    } 
    // Le joueur veut descendre de la plateforme.
    else if (k == 'S') {
      descendPlateforme = true;
    } else if (k == 'K' && !spriteFrappe.anime && !estPousse) {
      //Le joueur frappe.
      soundPool.play(sound_frappe);
      spriteFrappe.reinitialiser();
    } else if (k == 'L' && !spriteTire.anime && !aTire) {
      balleXInitiale = x;
      balleDirection = aligneDroite ? 1 : -1;
      balleX = x;
      balleY = y;
      aTire = true;
      ennemiTouche = false;
      soundPool.play(sound_tir);
      spriteTire.reinitialiser();
    }
    // ************************************ DEBUGAGE **************************//
    else if (k == 'A' && debug) {
      joueur.vy = -forceSaut/2;
      joueur.vx = aligneDroite ? -vitesseDeplacement : vitesseDeplacement; 
      surPlateforme = false;
    }
  }

  void touchPressed(int idBouton) {
    // Gestion du saut si le joueur se trouve sur une plateforme.
    if (idBouton == 2 && surPlateforme) {
      // On applique une force verticale pour propulser le joueur en l'air.
      if (superSaut)
        vy = -forceSaut*1.25; 
      else
        vy = -forceSaut;

      surPlateforme = false; // On quite la plateforme.
      soundPool.play(sound_saut); // On lance le son du saut.
    } 
    // Gestion du déplacement vers la droite. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (idBouton == 1 && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer.
      vx = vitesseDeplacement; // On se déplace à une vitesse constante vers la droite.
      aligneDroite = true; // Le joueur est tourné vers la droite.
    } 
    // Gestion du déplacment vers la gauche. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (idBouton == 0 && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer. 
      vx = -vitesseDeplacement; // On se déplace à une vitesse constante vers la gauche.
      aligneDroite = false; // Le joueur est tourné vers la gauche.
    } 
    // Le joueur veut descendre de la plateforme.
    else if (idBouton == 3) {
      descendPlateforme = true;
    } else if (idBouton == 4 && !spriteFrappe.anime && !estPousse) {
      //Le joueur frappe.
      soundPool.play(sound_frappe);
      spriteFrappe.reinitialiser();
    } else if (idBouton == 5 && !spriteTire.anime && !aTire) {
      balleXInitiale = x;
      balleDirection = aligneDroite ? 1 : -1;
      balleX = x;
      balleY = y;
      aTire = true;
      ennemiTouche = false;
      soundPool.play(sound_tir);
      spriteTire.reinitialiser();
    }
  }

  // Permet de gérer les actions du joueur en fonction de la touche relachée.
  void keyReleased() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Si on arrête le déplacement si on lache les touches pour se déplacer.
    if (k == 'D' || k == 'Q') {
      enDeplacement = false;
    } 
    // Le joueur ne veut plus descendre des plateformes.
    else if (k == 'S') {
      descendPlateforme = false;
    }
  }

  void touchReleased(int idBouton) {
    // Si on arrête le déplacement si on lache les touches pour se déplacer.
    if (idBouton == 0 || idBouton == 1) {
      enDeplacement = false;
    } 
    // Le joueur ne veut plus descendre des plateformes.
    else if (idBouton == 3) {
      descendPlateforme = false;
    }
  }

  // Le joueur reçoit des dégats.
  void degatsRecu(int degats, float force) {
    // On reçoit des dégats que si le temps de latence est écoulé.
    if (horlogeBlesse.tempsEcoule) {
      vie -=(int) (float(degats)*1.0/float(level));
      joueur.vy = -forceSaut/2;
      joueur.vx = force;
      surPlateforme = false;
      horlogeBlesse.lancer(); // On relance le chrono.
      estPousse = true;
      enDeplacement = false;
      soundPool.play(sound_hit);
      Vibrator vibrer = (Vibrator) getActivity().getSystemService(Context.VIBRATOR_SERVICE);
      vibrer.vibrate(200);
    }
  }

  void gagneXp(int quantite) {
    xp += quantite;
    if (xp > xpMax) {
      level += xp / xpMax;
      xp = xp  % xpMax;
    }
    if (level > levelMax) {
      level = levelMax;
      xp = xpMax;
    }
  }


  // Permet d'initialiser le joueur dans les niveaux tout en conservant se progression.
  void initNiveau(float tx, float ty) {
    // On place le joueur.
    x = tx;
    y = ty;

    // Le joueur n'a pas de vitesse initiale.
    vx = 0;
    vy = 0;

    // Le joueur n'a pas encore effectué d'actions.
    surPlateforme = false;
    enDeplacement = false;
    enAttaqueProche = false;
    enAttaqueLongue = false;
    estPousse = false;
    horlogeBlesse.tempsEcoule = true;
  }

  void reinitialiser() {
    invulnerableLave = false; // Pour pouvoir avancer dans le jeu.
    superSaut = false; // Pour pouvoir avancer dans le jeu.
    compteurTemps = 0; // Permet de créer des évennements dans le temps.
    xp = 0; // Quantité d'xp récupérée.
    level = 1; // Le niveau du personnage, ses dégats y sont proportionnels. Tout comme sa résistance.
    vie = 100; // Le nombre de points de vie.
    balleMaxDistance = 300;
    aTire = false; // Permet de savoir quand pouvoir re tirer.
    ennemiTouche = false; // Permet de désactiver le collision avec la balle et son affiche si elle a touchée un ennemi.
    aligneDroite = true; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
    surPlateforme = false; // Permet de savoir si le joueur ne doit plus tomber car il est sur une plateforme.
    // Les différents états du joueur
    enDeplacement = false;
    enAttaqueProche = false;
    enAttaqueLongue = false;
    // Permet d'indiquer au système de collision que l'on veut descendre de la plateforme en passant au travers.
    descendPlateforme = false;
    // Permet de corriger un bug de dépalcement lorsque le joueur a été poussé.
    estPousse = false;
  }
}
