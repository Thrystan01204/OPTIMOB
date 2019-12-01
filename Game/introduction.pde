
// Début de l'histoire. ET surtout le tuto.
class NiveauIntro {

  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  Horloge fade; // Transition vers le tuto
  // Histoire principale.
  boolean enIntroduction = true;
  int numDialogue = 0; // Position dans les dialogues.
  PImage[] dialogues;
  
  boolean finDialogue1 = false;
  boolean lanceDialogue1 = false;

  PImage fond;
  PImage publique;

  SoundFile musiqueIntro; // Musique lors de l'histoire principale.
  SoundFile applaudissements; // Musique avant le ligne d'arrivée.
  SoundFile action; // Musique de transition vers le tuto.




  NiveauIntro() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    dialogues = new PImage[4];
    dialogues[0] = loadImage("NiveauTuto/Dialogues/intro1.png");
    dialogues[1] = loadImage("NiveauTuto/Dialogues/intro2.png");
    dialogues[2] = loadImage("NiveauTuto/Dialogues/thibault1.png");
    dialogues[3] = loadImage("niveauTuto/Dialogues/thibault2.png");

    fond = loadImage("NiveauTuto/fond.png");
    publique = loadImage("NiveauTuto/publique.png");

    musiqueIntro = new SoundFile(Game.this, "NiveauTuto/Memories.wav");
    applaudissements = new SoundFile(Game.this, "NiveauTuto/applaudissements.wav");
    action = new SoundFile(Game.this, "NiveauTuto/battleThemeA.wav");

    // Rondin de bois
    murs.add(new Mur(765, 560.25, 50));
    murs.add(new Mur(879, 560.25, 50));
    plateformes.add(new Plateforme(822, 534.5, 116, true));
    
    // Obstacle 1
    murs.add(new Mur(1313, 510, 151));
    murs.add(new Mur(1604, 299, 267));
    plateformes.add(new Plateforme(1457, 434, 290, false));
    
    // Boite 1
    murs.add(new Mur(2821, 567.5, 39));
    murs.add(new Mur(2952, 567.5, 39));
    plateformes.add(new Plateforme(2887.6, 547.2, 132, true));
    
    //Boite 2
    murs.add(new Mur(3341.2, 531.3, 110));
    murs.add(new Mur(3475.6, 531.3, 110));
    plateformes.add(new Plateforme(3408.415, 475.71, 135, true));
    
    // Ennemis
    Mercenaire m = new Mercenaire(3149, 576, 390.5, 3);
    m.level = 2;
    ennemis.add(m);
    ennemis.add(new Mercenaire(2613.5, 576, 0, 1));
    ennemis.add(new Mercenaire(3657.4, 576, 364.8, 2));
    
    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  void actualiser() {
    if (!enIntroduction && fade.tempsEcoule && !lanceDialogue1) {
      trouverPlateformeCandidate(plateformes);
      trouverMursCandidats(murs);
      for(Mercenaire m : ennemis){
        m.actualiser();  
      }
      joueur.actualiser();
      collisionPlateformes();    
      collisionMurs();
      collisionLimites();
      camera.actualiser();
      
      // On entame le dialogue avec tibault.
      if(joueur.x > 1898 && !finDialogue1){
        lanceDialogue1 = true;
        applaudissements.stop();
        action.loop();
      }
    }
    fade.actualiser();
  }

  void keyPressed() {
    if (enIntroduction) {
      numDialogue += 1;
      if (numDialogue  == 2 ) {
        enIntroduction = false;
        musiqueIntro.stop();
        applaudissements.loop();
        fade.lancer();
      }
    } else if(lanceDialogue1){
      numDialogue += 1;
      if (numDialogue  == 4 ) {
        finDialogue1 = true;
        lanceDialogue1 = false;
      }
    }else if (fade.tempsEcoule) {
      joueur.keyPressed();
    }
  }

  void keyReleased() {
    if (!enIntroduction && fade.tempsEcoule) {
      joueur.keyReleased();
    }
  }

  void afficher() {
    //Affichage des dialogues d'intro.
    if (enIntroduction) {
      background(50);
      int x = 215;
      int y = 535;

      image(dialogues[numDialogue], 215, 535);
    } else {
      background(85, 221, 255);
      pushMatrix();
      camera.deplaceRepere();
      image(fond, 0, 0);
      joueur.afficher();
      image(publique, 0, 618);
      for(Mercenaire m : ennemis){
        m.afficher();  
      }
      //********** DEBUGAGE *********//
      if (debug) {
        affichePlateformesDebug(plateformes);
        afficheMursDebug(murs);
      }
      popMatrix();
      if(lanceDialogue1){
        int x = 215;
        int y = 535;
        image(dialogues[numDialogue], 215, 535);
      }
      if(finDialogue1){
        hud.afficher();  
      }
    }

    // Transition.
    if (!fade.tempsEcoule) {
      noStroke();
      float transparence = map(fade.compteur, 0, fade.temps, 255, 10);
      fill(0, 0, 0, transparence);
      rectMode(CORNER);
      rect(0, 0, width, height);
    }
  }

  void pause() {
    applaudissements.stop();
    musiqueIntro.stop();
    action.stop();
  }

  void relancer() {
    fade.lancer();
    musiqueIntro.loop();
    numDialogue = 0;
    enIntroduction = true;
    finDialogue1 = false;
    lanceDialogue1 = false;
    joueur.initNiveau(150, 507);
  }
}
