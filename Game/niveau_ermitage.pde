class NiveauErmitage {

  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.
  
  Item bonus1;
  Item bonus2;
  Item savate;
  

  PImage fond; // Image de fond.
  PImage infoSavate; // Description des savates magiques.
  PImage imgDialogue1;

  SoundFile musique; // Musique de fond.

  Horloge fade; // Transition vers les niveaux.

  boolean dialogueSavate = false;
  boolean dialogue1 = false;

  boolean changeNiveauVille= false;



  // Initialisation du niveau.
  NiveauErmitage() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    fond = loadImage("NiveauErmitage/fond.png");
    infoSavate = loadImage("NiveauErmitage/dialogue.png");
    imgDialogue1 = loadImage("NiveauErmitage/dialogue2.png");

    //*************Mise en place des plateformes et murs *****************//

    musique = new SoundFile(Game.this, "NiveauErmitage/musique.wav");
    plateformes.add(new Plateforme(3060, 382, 210, false)); //P1
    plateformes.add(new Plateforme(2724, 292, 288, false)); //P2
    Mercenaire m2 = new Mercenaire(2724, 292, 288, 3);
    m2.level = 1;
    ennemis.add(m2);
    plateformes.add(new Plateforme(2304.5, 163, 561.5, false)); //P3
    plateformes.add(new Plateforme(1785, -29, 552, false)); //P4
    Mercenaire m4 = new Mercenaire(1785, -29, 552, 2);
    m4.level = 4;
    ennemis.add(m4);
    plateformes.add(new Plateforme(1259, -271.5, 480, false)); //P5
    Mercenaire m5 = new Mercenaire(1259, -271.5, 480, 2);
    m5.level = 5;
    ennemis.add(m5);
    plateformes.add(new Plateforme(1803.5, -435, 486, false)); //P6
    Mercenaire m6 = new Mercenaire(1803.5, -435, 486, 3);
    m6.level = 6;
    ennemis.add(m6);
    plateformes.add(new Plateforme(2538.5, -270.5, 481, false)); //P7
    plateformes.add(new Plateforme(607.5, -153, 485, false)); //P8
    Mercenaire m8 = new Mercenaire(607.5, -153, 485, 1);
    m8.level = 4;
    ennemis.add(m8);
    plateformes.add(new Plateforme(822.5, 381.5, 206, false)); //P9
    
    Mercenaire m9 = new Mercenaire(2158, 4*height/5, 10, 1);
    m9.level = 1;
    ennemis.add(m9);
    
    Mercenaire m10 = new Mercenaire(1211, 4*height/5, 549, 2);
    m10.level = 2;
    ennemis.add(m10);
    
    Mercenaire m11 = new Mercenaire(170, 4*height/5, 10, 1);
    m9.level = 3;
    ennemis.add(m11);
    
    bonus1 = new PainBouchon(820.25, 360.5);
    bonus2 = new PainBouchon(1999.5, -461.5);
    savate = new SavateMagique(2541.5, -327.8);


    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  void actualiser() {
    if (!changeNiveauVille && !dialogueSavate && !dialogue1) {
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

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauVille) {
      pause();
      niveau = 2; // On lance le niveau ville.
      infoChargeNiveau(); // On charge le niveau;
      niveauVille.relancer(true);
    }

    fade.actualiser();
    
    bonus1.actualiser();
    bonus2.actualiser();
    savate.actualiser();

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

    // Affichage des ennemis.
    for (Mercenaire m : ennemis) {
      m.afficher();
    }
    
    bonus1.afficher();
    bonus2.afficher();
    savate.afficher();

    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3764, 537, 130, 158);
    boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3279, 497, 130, 158);

    if (versNiveauVille)
      image(infoDialogue, 3722, 373);
    if(declancheurDialogue1)
      image(infoDialogue, 3237, 334);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    popMatrix();

    hud.afficher();

    if (dialogueSavate || dialogue1) {
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
      if(dialogueSavate)
        image(infoSavate, 215, 535);
      else if(dialogue1)
        image(imgDialogue1, 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      noStroke();
      float transparence = 255;
      fill(0, 0, 0, 255);
      if (changeNiveauVille) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        fill(0, 0, 0, transparence);
      }
      rectMode(CORNER);
      rect(0, 0, width, height);
    } else if (changeNiveauVille) {
      infoChargeNiveau(); // On charge le niveau;
    }
  }

  // Gestion des touches appuyées.
  void keyPressed() {
    if (key == ' ') {
      // Pemier dialogue.
      if (dialogueSavate) {
        dialogueSavate = false;
      } else if(dialogue1){
        dialogue1 = false; 
      }
    } else if (fade.tempsEcoule && !dialogueSavate && !changeNiveauVille && !dialogue1) {
      joueur.keyPressed();
    }

    if (!dialogueSavate && !changeNiveauVille && !dialogue1) {
      char k = Character.toUpperCase((char) key);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3764, 537, 130, 158);
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3279, 497, 130, 158);
      if (k == 'E' && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } if (k == 'E' && declancheurDialogue1) {
        dialogue1 = true;
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
    joueur.initNiveau(3488, 4*height/5-joueur.h/2); // On replace le joueur dans le niveau.
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    joueur.aligneDroite = false;
  }
}
