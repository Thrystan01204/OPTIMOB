class NiveauVolcan {

  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  Item bonus1;
  Item bonus2;
  Item bonus3;
  Item bonus4;

  PImage fond; // Image de fond.

  SoundFile musique; // Musique de fond.

  Horloge fade; // Transition vers les niveaux.

  boolean dialogue1 = false;
  boolean dialogue2 = false;
  boolean dialogue3 = false;

  PImage imgDialogue1;
  PImage imgDialogue2;
  PImage imgDialogue3;

  boolean changeNiveauVille = false;
  boolean changeNiveauBoss = false;

  // Initialisation du niveau.
  NiveauVolcan() {

    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    fond = loadImage("NiveauVolcan/fond.png");
    imgDialogue1 = loadImage("NiveauVolcan/thibault1.png");
    imgDialogue2 = loadImage("NiveauVolcan/thibault2.png");
    imgDialogue3 = loadImage("NiveauVolcan/martin.png");

    //*************Mise en place des plateformes et murs *****************//

    musique = new SoundFile(Game.this, "NiveauVolcan/musique.wav");
    musique.amp(0.75);

    bonus1 = new PainBouchon(2418, 553);
    bonus2 = new PainBouchon(3485, 506);
    bonus3 = new PainBouchon(3196, 506);
    bonus4 = new PainBouchon(416, 117);

    plateformes.add(new Plateforme(1028, 363, 288, false)); // P1
    plateformes.add(new Plateforme(735.5, 149, 847, false)); // P2
    plateformes.add(new Plateforme(750, -4, 278, false)); // P3
    plateformes.add(new Plateforme(1060, -200, 476, false)); // P4
    plateformes.add(new Plateforme(1487, -330, 382, false)); // P5

    Mercenaire m1 = new Mercenaire(1028, 363, 10, 1);
    m1.level = 6;
    ennemis.add(m1);
    Mercenaire m2 = new Mercenaire(735.5, 149, 847, 3);
    m2.level = 7;
    ennemis.add(m2);
    Mercenaire m3 = new Mercenaire(1060, -200, 476, 2);
    m3.level = 8;
    ennemis.add(m3);
    Mercenaire m4 = new Mercenaire(1487, -330, 382, 3);
    m4.level = 9;
    ennemis.add(m4);
    Mercenaire m5 = new Mercenaire(1708, 576, 656, 2);
    m5.level = 10;
    ennemis.add(m5);



    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  void actualiser() {
    if (!changeNiveauVille && !dialogue1 && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
      trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
      // On actualise les ennemis.
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();

      // On résout les collisions.
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
      collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
      collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.


      //Si le joueur n'est pas invincible à la lave il ne peut pas continuer le niveau.
      if (!joueur.invulnerableLave && joueur.x > 2670) {
        joueur.vx = 0;
        joueur.x = 2670 - joueur.w/2;
      }

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauVille) {
      pause();
      niveau = 2; // On lance le niveau ville.
      infoChargeNiveau(); // On charge le niveau;
      niveauVille.relancer(false);
    } else if (fade.tempsEcoule && changeNiveauBoss) {
      pause();
      niveau = 6; // On lance le niveau du boss;
      infoChargeNiveau(); // On charge le niveau;
      niveauBoss.lancer();
    }

    fade.actualiser();

    bonus1.actualiser();
    bonus2.actualiser(); 
    bonus3.actualiser();
    bonus4.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      pause();
    }
  }

  // Gestion de l'affichage du niveau.
  void afficher() {

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    image(fond, 0, -height); // Affichage des bâtiments et des plateformes.
    bonus1.afficher();
    bonus2.afficher();
    bonus3.afficher();
    bonus4.afficher();
    // Affichage des ennemis.
    for (Mercenaire m : ennemis) {
      m.afficher();
    }

    

    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 98, 540.5, 130, 158);
    boolean versNiveauBoss = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3642, 540.5, 130, 158);
    boolean declangeurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 500.5, 496, 141, 147);
    boolean declangeurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2629, 496, 141, 147);

    if (versNiveauVille)
      image(infoDialogue, 71, 393);
    else if (versNiveauBoss)
      image(infoDialogue, 3600, 362);
    else if (declangeurDialogue1)
      image(infoDialogue, 466, 342);
    else if (declangeurDialogue2)
      image(infoDialogue, 2592, 348);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    popMatrix();

    hud.afficher();

    if (dialogue1 || dialogue2 || dialogue3) {
      fill(50);
      noStroke();
      rectMode(CENTER);
      rect(width/2, 35, 500, 32);
      textSize(24);
      textAlign(CENTER, CENTER);
      fill(0);
      text("Appuyer sur espace pour continuer", width/2+1, 33);
      fill(255);
      text("Appuyer sur espace pour continuer", width/2, 32);
      if (dialogue1)
        image(imgDialogue1, 215, 535);
      else if (dialogue2)
        image(imgDialogue2, 215, 535);
      else if (dialogue3)
        image(imgDialogue3, 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      noStroke();
      float transparence = 255;
      fill(0, 0, 0, 255);
      if (changeNiveauVille || changeNiveauBoss) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        fill(0, 0, 0, transparence);
      }
      rectMode(CORNER);
      rect(0, 0, width, height);
    } else if (changeNiveauVille || changeNiveauBoss) {
      background(0);
    }
  }

  // Gestion des touches appuyées.
  void keyPressed() {
    if (key == ' ') {
      // Pemier dialogue.
      if (dialogue1) {
        dialogue1 = false;
      } else if (dialogue2) {
        dialogue2 = false;
      }else if (dialogue3) {
        dialogue3 = false;
      }
    } else if (fade.tempsEcoule && !dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      joueur.keyPressed();
    }

    if (!dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      char k = Character.toUpperCase((char) key);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 98, 540.5, 130, 158);
      boolean versNiveauBoss = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3642, 540.5, 130, 158);
      boolean declangeurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 500.5, 496, 141, 147);
      boolean declangeurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2629, 496, 141, 147);
      if (k == 'E' && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } else if (k == 'E' && versNiveauBoss && joueur.level < 10) {
        dialogue3 = true;
      } else if (k == 'E' && versNiveauBoss && joueur.level == 10) {
        fade.lancer();
        changeNiveauBoss = true;
      } else if (k == 'E' && declangeurDialogue1) {
        dialogue1 = true;
      } else if (k == 'E' && declangeurDialogue2) {
        dialogue2 = true;
      }
    }
  }

  // Gestion des touches relâchées.
  void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  // Permet de suspendre les actions du menu.
  void pause() {
    musique.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  void relancer() {
    musique.loop(); // On relance la musique de fond.
    joueur.initNiveau(281, 4*height/5-joueur.h/2); // On replace le joueur dans le niveau.
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    joueur.aligneDroite = true;
    dialogue1 = false;
    dialogue2 = false;
  }
}
