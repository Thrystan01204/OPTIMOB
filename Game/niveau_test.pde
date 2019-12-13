//*********************************************** IMPORTANT ***************************************************
// Ce niveau existe que pour tester les différents éléments du jeu, il n'est pas présent dans le rendu final. *
// Ainsi, son code ne sera pas détaillé.                                                                      *
//*************************************************************************************************************

class NiveauTest {
  ArrayList<Plateforme> plateformes;
  ArrayList<Mur> murs;
  
  Horloge flash = new Horloge(2000); // Test de la classe horloge
 
  
  // la musique de fond.
  SoundFile musique;
  
  // Ennemis du niveau:
  Mercenaire mercenaire;
  Mercenaire mercenaireImmobile;
  Mercenaire mercenairePistolet;

  NiveauTest() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    musique = new SoundFile(Game.this, "NiveauTest/musique.wav");
    musique.amp(0.5);
    
    mercenaire = new Mercenaire(400, 420, 200, 3);
    plateformes.add(new Plateforme(400, 420, 400, false));
    
    mercenaireImmobile = new Mercenaire(1280, 420, 200, 1);
    
    mercenairePistolet = new Mercenaire(900, 420, 200, 2);
    plateformes.add(new Plateforme(1280, 420, 400, false));
    
    plateformes.add(new Plateforme(900, 420, 400, false));
    
    
    
    murs.add(new Mur(250, 495, 149));
    
    flash.lancer();
  }

  void actualiser() {
    trouverPlateformeCandidate(plateformes);
    trouverMursCandidats(murs);
    
    mercenaire.actualiser();
    mercenaireImmobile.actualiser();
    mercenairePistolet.actualiser();
    
    joueur.actualiser();
    
    collisionPlateformes();    
    collisionMurs();
    collisionLimites();
    
    camera.actualiser();
    
    flash.actualiser();
    
    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  void afficher() {
    cv.background(0, 200, 255);
    cv.pushMatrix();
    camera.deplaceRepere();
    cv.noStroke();
    cv.rectMode(CORNER);
    cv.fill(0, 200, 0);
    cv.rect(0, 4*cv.height/5, cv.width, cv.height/4);
    mercenaire.afficher();
    mercenaireImmobile.afficher();
    mercenairePistolet.afficher();
    joueur.afficher();
    
    
    
    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }
    cv.popMatrix();
    hud.afficher();
    if(!flash.tempsEcoule){
      cv.rectMode(CORNER);
      float t = -(0.016/127.0)*(flash.compteur-1000)*(flash.compteur-1000)+127.0;
      cv.fill(255, 255, 255, t);
      cv.rect(0, 0, cv.width, cv.height);
    }
  }

  void keyPressed() {
    joueur.keyPressed();
  }

  void keyReleased() {
    joueur.keyReleased();
  }

  void pause() {
    musique.stop();
  }

  void relancer() {
    joueur.initNiveau(cv.width/2, cv.height/4);
    musique.loop();
  }
}
