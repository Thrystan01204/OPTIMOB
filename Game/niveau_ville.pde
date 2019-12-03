class NiveauVille {
  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  PImage fond; // Image de fond (bâtiments et plateformes).
  PImage montagnes; // Image pour le parallax.
  float positionMontagesX = 0; // Position des montages pour l'effet parallax.

  SoundFile musique; // Musique de fond.


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
    dialogues[0] = loadImage("NiveauVille/thibault1.png");
    dialogues[1] = loadImage("NiveauVille/thibault2.png");
    
    bonus1 = new PainBouchon(922, 219.5);
    bonus2 = new PainBouchon(2087, -337.5);
    bonus3 = new PainBouchon(3216, 227.9);

    infoCombinaison = loadImage("NiveauVille/dialogueCombinaison.png");
    combinaison = new Combinaison(1209.5, -562.5);

    fond = loadImage("NiveauVille/fond.png");
    montagnes = loadImage("NiveauVille/montagnes.png");

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

    musique = new SoundFile(Game.this, "NiveauVille/musique.wav");
    musique.amp(0.5); // La musique étant trop forte, on baisse le volume.

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
      positionMontagesX += camera.dx*0.125; // Pour donner un effet de parallax, on déplace un peu plus les montages que le fond.
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
      pause();
    }
  }

  // Gestion de l'affichage du niveau.
  void afficher() {
    background(170, 204, 255); // affichage du ciel.

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    image(montagnes, positionMontagesX, -height); // Affichage des montagnes.
    image(fond, 0, -height); // Affichage des bâtiments et des plateformes.
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
      image(infoDialogue, 929, 342);
    else if (declancheurDialogue2)
      image(infoDialogue, 1975, -189);
    else if (versNiveauErmitage)
      image(infoDialogue, 38, 385);
    else if (versNiveauVolcan)
      image(infoDialogue, 3736, 402);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    popMatrix();

    hud.afficher();

    if (lanceDialogue1 || lanceDialogue2 || dialogueCombinaison) {
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
      if(dialogueCombinaison)
        image(infoCombinaison, 215, 535);
      else
        image(dialogues[numDialogue], 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      noStroke();
      float transparence = 255;
      fill(0, 0, 0, 255);
      if (changeNiveauErmitage || changeNiveauVolcan) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        fill(0, 0, 0, transparence);
      } else if (changeNiveauErmitage || changeNiveauVolcan) {
        background(0);
      }
      rectMode(CORNER);
      rect(0, 0, width, height);
    } else if (changeNiveauVolcan || changeNiveauErmitage) {
      background(0);
    }
  }

  // Gestion des touches appuyées
  void keyPressed() {
    if (key == ' ') {
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
     else if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
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

  // Permet de suspendre les actions du menu.
  void pause() {
    musique.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  void relancer(boolean gauche) {
    musique.loop(); // On relance la musique de fond.
    changeNiveauErmitage = false;
    fade.tempsEcoule = false;
    changeNiveauVolcan = false;
    if (gauche) // Si on arrive de la gauche.
      joueur.initNiveau(210, 4*height/5-joueur.h/2); // On replace le joueur dans le niveau.
    else
      joueur.initNiveau(3770,4*height/5-joueur.h/2);
  }
}
