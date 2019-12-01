//*********************************************** IMPORTANT ***************************************************
// Ce niveau existe que pour tester les différents éléments du jeu, il n'est pas présent dans le rendu final. *
// Ainsi, son code ne sera pas détaillé.                                                                      *
//*************************************************************************************************************

class NiveauTest {
  ArrayList<Plateforme> plateformes;
  ArrayList<Mur> murs;
  
  Horloge flash = new Horloge(2000);
 
  
  // la musique de fond.
  SoundFile musique;
  
  // Ennemis du niveau:
  Mercenaire mercenaire;

  NiveauTest() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    musique = new SoundFile(Game.this, "NiveauTest/musique.wav");
    musique.amp(0.5);
    
    mercenaire = new Mercenaire(400, 420, 200);
    plateformes.add(new Plateforme(400, 420, 400, false));
    murs.add(new Mur(250, 495, 149));
    
    flash.lancer();
  }

  void actualiser() {
    trouverPlateformeCandidate(plateformes);
    trouverMursCandidats(murs);
    joueur.actualiser();
    
    mercenaire.actualiser();
    
    collisionPlateformes();
    collisionMurs();
    collisionLimites();
    camera.actualiser();
    
    flash.actualiser();
  }

  void afficher() {
    background(0, 200, 255);
    pushMatrix();
    camera.deplaceRepere();
    noStroke();
    rectMode(CORNER);
    fill(0, 200, 0);
    rect(0, 4*height/5, width, height/4);
    joueur.afficher();
    mercenaire.afficher();
    
    
    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }
    popMatrix();
    if(!flash.tempsEcoule){
      rectMode(CORNER);
      float t = -(0.016/127.0)*(flash.compteur-1000)*(flash.compteur-1000)+127.0;
      fill(255, 255, 255, t);
      rect(0, 0, width, height);
    }
  }

  void keyPressed() {
    if (key == ESC) {
      key = 0;
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
    musique.stop();
  }

  void relancer() {
    joueur.initNiveau(width/2, height/4);
    musique.loop();
  }
}
