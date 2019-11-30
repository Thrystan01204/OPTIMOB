class NiveauVille{
  ArrayList<Plateforme> plateformes;
  ArrayList<Mur> murs;
  PImage fond;
  PImage montagnes;
  float positionMontagesX = 0;
  
  NiveauVille() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    fond = loadImage("NiveauVille/fond.png");
    montagnes = loadImage("NiveauVille/montagnes.png");
    
    // Mise en place des plateformes
    
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
    
  }
  
  void actualiser() {
    trouverPlateformeCandidate(plateformes);
    trouverMursCandidats(murs);
    joueur.actualiser();
    collisionPlateformes();
    collisionMurs();
    collisionLimites();
    camera.actualiser();
    positionMontagesX -= camera.dx*0.125;
  }
  
  void afficher() {
    background(170, 204, 255);
    pushMatrix();
    camera.deplaceRepere();
    image(montagnes, positionMontagesX, -height);
    image(fond, 0, -height);
    
    joueur.afficher();
    
    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }
    
    popMatrix();
  }
  
  void keyPressed() {
    if (key == ESC) {
      key = 0; // cela permet de faire croire à processing que l'on a pas appuié sur la touche "echap" et donc l'empêche de fermer le jeu
      niveau = 0;
      pause();
      infoChargeNiveau();
      menuPrincipal.relancer();
    }
    joueur.keyPressed();
  }

  void keyReleased() {
    joueur.keyReleased();
  }

  void pause() {
  }

  void relancer() {
    joueur.initNiveau(210, 4*height/5-joueur.h/2);
  }
}
