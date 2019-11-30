class NiveauVille{
  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  
  PImage fond; // Image de fond (bâtiments et plateformes).
  PImage montagnes; // Image pour le parallax.
  float positionMontagesX = 0; // Position des montages pour l'effet parallax.
  
  SoundFile musique;
  
  // Initialisation du niveau.
  NiveauVille() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    
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
    plateformes.add(new Plateforme(289.7365, -174, 562.556,false)); // p1
    plateformes.add(new Plateforme(1208, -466, 216, false)); // p2
    plateformes.add(new Plateforme(367.574, 63.249, 562.556, false)); // p3
    plateformes.add(new Plateforme(963.5, -80.368, 215.748,false)); // p4
    plateformes.add(new Plateforme(922.5, 249, 217, false)); // p5
    plateformes.add(new Plateforme(1773.375, 47.557, 682, false)); // p7
    plateformes.add(new Plateforme(1999, -311, 584, false)); // p8
    plateformes.add(new Plateforme(2651, 30, 682, false)); // p9
    plateformes.add(new Plateforme(3202, 252, 215.75, false)); // p10
    
    musique = new SoundFile(Game.this, "NiveauVille/musique.wav");
    musique.amp(0.125);
  }
  
  // Gestion de la logique du niveau.
  void actualiser() {
    // Estimation des collisions.
    trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
    trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
    
    // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
    joueur.actualiser();
    
    // On résout les collisions.
    collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
    collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
    collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.
    
    camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    positionMontagesX += camera.dx*0.125; // Pour donner un effet de parallax, on déplace un peu plus les montages que le fond.
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
    joueur.afficher(); // On affiche le joueur.
    
    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }
    
    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    popMatrix(); 
  }
  
  // Gestion des touches appuyées
  void keyPressed() {
    if (key == ESC) {
      key = 0; // cela permet de faire croire à processing que l'on a pas appuié sur la touche "echap" et donc l'empêche de fermer le jeu.
      // On revient au menu principal.
      pause(); // On met le niveau en pause.
      niveau = 0; // //On indique au système de gestion des niveaux que l'on se trouve maintenant au menu principal.
      infoChargeNiveau();  // On indique que le niveau charge.
      menuPrincipal.relancer(); // On relance le niveau : menu principal.
    }
    // Gestion des touches appuyées pour le joueur.
    joueur.keyPressed();
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
    joueur.initNiveau(210, 4*height/5-joueur.h/2); // On replace le joueur dans le niveau.
  }
}
