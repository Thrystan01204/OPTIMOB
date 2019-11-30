class NiveauTest {

  ArrayList<Plateforme> plateformes;
  ArrayList<Mur> murs;

  NiveauTest() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    
    for (int i=0; i<10; i++) {
      float x = random(0, width);
      float y = random(100, 3*height/4);
      float w = random(32, 400);
      float h = random(32, 400);
      Plateforme p = new Plateforme(x, y, w, false);
      plateformes.add(p);
      Mur m = new Mur(x, y, h);
      murs.add(m);
    }
  }

  void actualiser() {
    trouverPlateformeCandidate(plateformes);
    trouverMursCandidats(murs);
    joueur.actualiser();
    collisionPlateformes();
    collisionMurs();
    collisionLimites();
    camera.actualiser();
  }

  void afficher() {
    background(0, 200, 255);
    pushMatrix();
    camera.deplaceRepere();
    noStroke();
    rectMode(CORNER);
    fill(0, 200, 0);
    rect(0, 3*height/4, width, height/4);
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
    joueur.initNiveau(width/2, height/4);
  }
}
