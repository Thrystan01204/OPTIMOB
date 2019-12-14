
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

  boolean finDialogue2 = false;
  boolean lanceDialogue2 = false;

  boolean changeNiveauVille = false;

  PImage fond;
  PImage publique;


  SoundFile musiqueIntro; // Musique lors de l'histoire principale.
  SoundFile applaudissements; // Musique avant le ligne d'arrivée.
  SoundFile action; // Musique de transition vers le tuto.

  Item bonus; // de la vie pour les noobs.




  NiveauIntro() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    dialogues = new PImage[5];
    loadingRessource = "loading NiveauTuto/Dialogues/intro1.png";
    dialogues[0] = loadImage("NiveauTuto/Dialogues/intro1.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/Dialogues/intro2.png";
    dialogues[1] = loadImage("NiveauTuto/Dialogues/intro2.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/Dialogues/thibault1.png";
    dialogues[2] = loadImage("NiveauTuto/Dialogues/thibault1.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/Dialogues/thibault2.png";
    dialogues[3] = loadImage("NiveauTuto/Dialogues/thibault2.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/Dialogues/thibault3.png";
    dialogues[4] = loadImage("NiveauTuto/Dialogues/thibault3.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/fond.png";
    fond = loadImage("NiveauTuto/fond.png");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/publique.png";
    publique = loadImage("NiveauTuto/publique.png");
    loadingProgress--;
    
    loadingRessource = "loading NiveauTuto/Memories.mp3";
    musiqueIntro = new SoundFile(LeBouchonOr.this, "NiveauTuto/Memories.mp3");
    loadingProgress--;
    loadingRessource = "loading NiveauTuto/applaudissements.mp3";
    applaudissements = new SoundFile(LeBouchonOr.this, "NiveauTuto/applaudissements.mp3");
    loadingProgress--;
    applaudissements.amp(0.5);
    loadingRessource = "loading NiveauTuto/battleThemeA.mp3";
    action = new SoundFile(LeBouchonOr.this, "NiveauTuto/battleThemeA.mp3");
    loadingProgress--;
    action.amp(0.5);

    // Rondin de bois
    murs.add(new Mur(765, 560.25, 50));
    murs.add(new Mur(879, 560.25, 50));
    plateformes.add(new Plateforme(822, 534.5, 116, true));

    // Obstacle 1
    murs.add(new Mur(1313, 510, 151));
    murs.add(new Mur(1604, 217.4, 434.8));
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
    ennemis.add(new Mercenaire(3394, 477, 0, 1));
    ennemis.add(new Mercenaire(2658.35, 576, 328.7, 2));

    bonus = new PainBouchon(2879.5, 539.4);

    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  void actualiser() {
    if (!enIntroduction && fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2) {
      trouverPlateformeCandidate(plateformes);
      trouverMursCandidats(murs);
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      joueur.actualiser();
      collisionPlateformes();    
      collisionMurs();
      collisionLimites();
      camera.actualiser();

      // On entame le dialogue avec tibault.
      if (joueur.x > 1757 && !finDialogue1) {
        lanceDialogue1 = true;
        applaudissements.stop();
        action.loop();
      }
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauVille) {
      pause();
      niveau = 2; // On lance le niveau ville.
      infoChargeNiveau(); // On charge le niveau;
      niveauVille.relancer(true);
    }
    bonus.actualiser();
    fade.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  void keyPressed() {
    if (key == ' ') {
      if (enIntroduction) {
        numDialogue += 1;
        if (numDialogue  == 2 ) {
          enIntroduction = false;
          musiqueIntro.stop();
          applaudissements.loop();
          fade.lancer();
        }
      } 
      // Pemier dialogue.
      else if (lanceDialogue1) {
        numDialogue += 1;
        if (numDialogue  == 4 ) {
          finDialogue1 = true;
          lanceDialogue1 = false;
        }
      } 
      // 2ème dialogue.
      else if (lanceDialogue2) {
        numDialogue += 1;
        if (numDialogue == 5) {
          numDialogue = 0; // Evite les bugs
          finDialogue2 = true;
          lanceDialogue2 = false;
        }
      }
    } else if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !enIntroduction) {
      joueur.keyPressed();
    }
    // On réaffiche les dialogues.
    if (!lanceDialogue1 && !lanceDialogue2 &&(finDialogue1 || finDialogue2) && !changeNiveauVille && !enIntroduction) {
      char k = Character.toUpperCase((char) key);
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 1961, 506.8, 200, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3549.9, 506.8, 200, 235);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3778, 570.5, 128.85, 118.9);
      if (k == 'E' && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 2;
      } else if (k == 'E' && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 4;
      } else if (k == 'E' && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      }
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
      cv.background(50);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Appuyez sur espace pour continuer", cv.width/2+1, 33);
      cv.fill(255);
      cv.text("Appuyez sur espace pour continuer", cv.width/2, 32);
      cv.image(dialogues[numDialogue], 215, 535);
    } else {
      cv.background(85, 221, 255);
      cv.pushMatrix();
      camera.deplaceRepere();
      cv.image(fond, 0, 0);
      bonus.afficher();
      for (Mercenaire m : ennemis) {
        m.afficher();
      }
      joueur.afficher();
      cv.image(publique, 0, 618);


      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 1961, 506.8, 200, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3549.9, 506.8, 200, 235);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3778, 570.5, 128.85, 118.9);

      if (declancheurDialogue1) {
        cv.image(infoDialogue, 1925, 346);
      } else if (declancheurDialogue2) {
        cv.image(infoDialogue, 3514.7, 327.3);
      } else if (versNiveauVille) {
        cv.image(infoDialogue, 3727.6, 428);
      }

      //********** DEBUGAGE *********//
      if (debug) {
        affichePlateformesDebug(plateformes);
        afficheMursDebug(murs);
      }

      cv.popMatrix();
      if (lanceDialogue1 || lanceDialogue2) {
        cv.fill(50);
        cv.noStroke();
        cv.rectMode(CENTER);
        cv.rect(cv.width/2, 35, 500, 32);
        cv.textSize(24);
        cv.textAlign(CENTER, CENTER);
        cv.fill(0);
        cv.text("Appuyez sur espace pour continuer", cv.width/2+1, 33);
        cv.fill(255);
        cv.text("Appuyez sur espace pour continuer", cv.width/2, 32);
        cv.image(dialogues[numDialogue], 215, 535);
      }

      if (finDialogue1 || finDialogue2) {
        hud.afficher();
      }
    }

    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      if (!changeNiveauVille)
        transparence = map(fade.compteur, 0, fade.temps, 255, 10);
      else
        transparence = map(fade.compteur, 0, fade.temps, 10, 255);
      cv.fill(0, 0, 0, transparence);
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    } else if (changeNiveauVille) {
      infoChargeNiveau(); // On charge le niveau;
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
    reinitialiser();
    joueur.initNiveau(150, 507);
  }

  void reinitialiser() {
    enIntroduction = true;
    numDialogue = 0; // Position dans les dialogues.
    finDialogue1 = false;
    lanceDialogue1 = false;
    finDialogue2 = false;
    lanceDialogue2 = false;
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    bonus.reinitialiser();
    for(Mercenaire m : ennemis){
      m.reinitialiser();  
    }
  }
}
