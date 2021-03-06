class NiveauVille {
  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  PImage fond; // Image de fond (bâtiments et plateformes).


  Horloge fade; // Transition vers les niveaux.

  int numDialogue = 0; // Position dans les dialogues.
  PImage[] dialogues;

  boolean finDialogue1 = true;
  boolean lanceDialogue1 = false;

  boolean finDialogue2 = true;
  boolean lanceDialogue2 = false;

  boolean changeNiveauErmitage = false;
  boolean changeNiveauVolcan = false;

  boolean dialogueCombinaison = false;
  PImage infoCombinaison;

  Item combinaison;

  Item bonus1;
  Item bonus2;
  Item bonus3;



  // Initialisation du niveau.
  NiveauVille() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    dialogues = new PImage[2];
    loadingRessource = "loading NiveauVille/thibault1.png";
    dialogues[0] = loadImage("NiveauVille/thibault1.png");
    loadingProgress++;
    loadingRessource = "loading NiveauVille/thibault2.png";
    dialogues[1] = loadImage("NiveauVille/thibault2.png");
    loadingProgress++;

    bonus1 = new PainBouchon(922, 219.5);
    bonus2 = new PainBouchon(2087, -337.5);
    bonus3 = new PainBouchon(3216, 227.9);

    loadingRessource = "loading NiveauVille/dialogue_combinaison.png";
    infoCombinaison = loadImage("NiveauVille/dialogue_combinaison.png");
    loadingProgress++;
    combinaison = new Combinaison(1209.5, -562.5);

    loadingRessource = "loading NiveauVille/fond.png";
    fond = loadImage("NiveauVille/fond.png");
    loadingProgress++;

    //*************Mise en place des plateformes et murs *****************//

    // Collisions des bus
    plateformes.add(new Plateforme(1404, 429, 561, true)); // p6
    murs.add(new Mur(1124, 520, 180));
    murs.add(new Mur(1683, 520, 180));
    plateformes.add(new Plateforme(3435.5, 429, 561, true)); // p11
    murs.add(new Mur(3155.5, 520, 180));
    murs.add(new Mur(3716, 520, 180));

    // Collision des plateformes
    plateformes.add(new Plateforme(289.7365, -174, 562.556, false)); // p1
    plateformes.add(new Plateforme(1208, -466, 216, false)); // p2
    plateformes.add(new Plateforme(367.574, 63.249, 562.556, false)); // p3
    plateformes.add(new Plateforme(963.5, -80.368, 215.748, false)); // p4
    plateformes.add(new Plateforme(922.5, 249, 217, false)); // p5
    plateformes.add(new Plateforme(1773.375, 47.557, 682, false)); // p7
    plateformes.add(new Plateforme(1999, -311, 584, false)); // p8
    plateformes.add(new Plateforme(2651, 30, 682, false)); // p9
    plateformes.add(new Plateforme(3202, 252, 215.75, false)); // p10

    //Ennemis.
    Mercenaire m1 = new Mercenaire(2478, 574, 784, 3);
    m1.level = 1;
    ennemis.add(m1);
    Mercenaire m2 = new Mercenaire(289.7365, -174, 562.556, 1);
    m1.level = 1;
    ennemis.add(m2);
    Mercenaire m3 = new Mercenaire(367.574, 63.249, 562.556, 2);
    m3.level = 2;
    ennemis.add(m3);
    Mercenaire m4 = new Mercenaire(1404, 429, 561, 3);
    m4.level = 2;
    ennemis.add(m4);
    Mercenaire m5 = new Mercenaire(1999, -311, 584, 3);
    m5.level = 7;
    ennemis.add(m5);

    Mercenaire m6 = new Mercenaire(2651, 30, 682, 2);
    m6.level = 2;
    ennemis.add(m6);

    Mercenaire m7 = new Mercenaire(3435.5, 429, 561, 1);
    m7.level = 3;
    ennemis.add(m7);


    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  void actualiser() {
    if (!changeNiveauErmitage && ! changeNiveauVolcan && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      invalideBouton = false;
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
      trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();

      // On résout les collisions.
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
      collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
      collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    } else {
      invalideBouton = true;
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauErmitage) {
      pause();
      niveau = 3; // On lance le niveau Ermitage.
      infoChargeNiveau(); // On charge le niveau.
      niveauErmitage.relancer(); // On relance le niveau ermitage.
    } else if (fade.tempsEcoule && changeNiveauVolcan) {
      pause();
      niveau = 4; // On lance le niveau volcan.
      infoChargeNiveau(); // On charge le niveau.
      niveauVolcan.relancer();
    }
    combinaison.actualiser();
    bonus1.actualiser();
    bonus2.actualiser();
    bonus3.actualiser();
    fade.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  // Gestion de l'affichage du niveau.
  void afficher() {
    cv.background(170, 204, 255); // affichage du ciel.

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    cv.pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    cv.image(fond, 0, -cv.height); // Affichage des bâtiments et des plateformes.
    bonus1.afficher();
    bonus2.afficher();
    bonus3.afficher();
    for (Mercenaire m : ennemis) {
      m.afficher();
    }
    combinaison.afficher();
    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5, 118, 235);
    boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5, 100, 189);

    boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
    boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

    if (declancheurDialogue1)
      cv.image(infoDialogue, 929, 342);
    else if (declancheurDialogue2)
      cv.image(infoDialogue, 1975, -189);
    else if (versNiveauErmitage)
      cv.image(infoDialogue, 38, 385);
    else if (versNiveauVolcan)
      cv.image(infoDialogue, 3736, 402);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    cv.popMatrix();

    hud.afficher();

    if (lanceDialogue1 || lanceDialogue2 || dialogueCombinaison) {
      cv.fill(50);
      cv.noStroke();
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 45, 500, 32);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
      if (dialogueCombinaison)
        cv.image(infoCombinaison, 215, 535);
      else
        cv.image(dialogues[numDialogue], 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      cv.fill(0, 0, 0, 255);
      if (changeNiveauErmitage || changeNiveauVolcan) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        cv.fill(0, 0, 0, transparence);
      } else if (changeNiveauErmitage || changeNiveauVolcan) {
        cv.background(0);
      }
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    } else if (changeNiveauVolcan || changeNiveauErmitage) {
      infoChargeNiveau(); // On charge le niveau;
    }
  }

  void actualiseDialogues() {
    // Pemier dialogue.
    if (lanceDialogue1) {
      numDialogue += 1;
      if (numDialogue  == 1 ) {
        finDialogue1 = true;
        lanceDialogue1 = false;
      }
    } 
    // 2ème dialogue.
    else if (lanceDialogue2) {
      numDialogue += 1;
      if (numDialogue == 2) {
        numDialogue = 1; // Evite les bugs.
        finDialogue2 = true;
        lanceDialogue2 = false;
      }
    } 
    // Info combinaison
    else if (dialogueCombinaison) {
      dialogueCombinaison = false;
    }
  }

  // Gestion des touches appuyées
  void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      joueur.keyPressed();
    }

    // On réaffiche les dialogues.
    if (finDialogue1 && finDialogue2 && !lanceDialogue1 && !lanceDialogue2 && !changeNiveauVolcan && !changeNiveauErmitage && !dialogueCombinaison) {
      char k = Character.toUpperCase((char) key);

      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5, 118, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5, 100, 189);

      boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
      boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

      if (k == 'E' && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 0;
      } else if (k == 'E' && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 1;
      } else if (k == 'E' && versNiveauErmitage && !changeNiveauErmitage) {
        fade.lancer();
        changeNiveauErmitage = true;
      } else if (k == 'E' && versNiveauVolcan && !changeNiveauVolcan) {
        invalideBouton = true;
        fade.lancer();
        changeNiveauVolcan = true;
      }
    }
  }

  void touchPressed(int idBouton) {
    if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      joueur.touchPressed(idBouton);
    }

    // On réaffiche les dialogues.
    if (finDialogue1 && finDialogue2 && !lanceDialogue1 && !lanceDialogue2 && !changeNiveauVolcan && !changeNiveauErmitage && !dialogueCombinaison) {

      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5, 118, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5, 100, 189);

      boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
      boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

      if (idBouton == 6 && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 0;
      } else if (idBouton == 6 && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 1;
      } else if (idBouton == 6 && versNiveauErmitage && !changeNiveauErmitage) {
        fade.lancer();
        changeNiveauErmitage = true;
      } else if (idBouton == 6 && versNiveauVolcan && !changeNiveauVolcan) {
        fade.lancer();
        changeNiveauVolcan = true;
      }
    }
  }

  // Gestion des touches relâchées.
  void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  void touchReleased(int idBouton) {
    // Gestion des touches relâchées pour le joueur.
    joueur.touchReleased(idBouton);
  }

  // Permet de suspendre les actions du menu.
  void pause() {
    music_ville.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  void relancer(boolean gauche) {
    music_ville.loop(); // On relance la musique de fond.
    changeNiveauErmitage = false;
    fade.tempsEcoule = false;
    changeNiveauVolcan = false;
    if (gauche) // Si on arrive de la gauche.
      joueur.initNiveau(210, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    else
      joueur.initNiveau(3770, 4*cv.height/5-joueur.h/2);
  }

  void reinitialiser() {
    numDialogue = 0; // Position dans les dialogues.
    finDialogue1 = true;
    lanceDialogue1 = false;
    finDialogue2 = true;
    lanceDialogue2 = false;
    changeNiveauErmitage = false;
    changeNiveauVolcan = false;
    fade.tempsEcoule = true;
    dialogueCombinaison = false;
    bonus1.reinitialiser();
    bonus2.reinitialiser();
    bonus3.reinitialiser();
    combinaison.reinitialiser();
    for (Mercenaire m : ennemis) {
      m.reinitialiser();
    }
  }
}
