class NiveauBoss {
  //Map
  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  PImage fond;

  // Cinématique
  boolean intro = true;
  boolean dialogue1 = true;
  boolean dialogue2 = true;
  boolean dialogue3 = true;
  boolean dialogue4 = false;
  boolean gagne = false;
  PImage imgIntro;
  PImage imgDialogue1;
  PImage imgDialogue2;
  PImage imgDialogue3;
  PImage imgDialogue4;
  PImage thibault;
  boolean estBlesse = false;
  Horloge fade;

  // Boss
  boolean phase2 = false;
  float vx = 4;
  SoundFile musiquePhase1;
  SoundFile musiquePhase2;
  SoundFile musiqueIntro;
  SoundFile meurt;
  SoundFile item;
  Sprite boss;
  float vie = 100;
  float w = 151;
  float h = 453;

  NiveauBoss() {
    plateformes = new ArrayList<Plateforme>();
    loadingRessource = "loading NiveauBoss/musique_cinematique.mp3";
    musiqueIntro = new SoundFile(LeBouchonOr.this, "NiveauBoss/musique_cinematique.mp3");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/phase1.mp3";
    musiquePhase1 = new SoundFile(LeBouchonOr.this, "NiveauBoss/phase1.mp3");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/phase2.mp3";
    musiquePhase2 = new SoundFile(LeBouchonOr.this, "NiveauBoss/phase2.mp3");
    loadingProgress--;
    loadingRessource = "loading mort_mercenaire.wav";
    meurt = new SoundFile(LeBouchonOr.this, "mort_mercenaire.wav");
    loadingProgress--;
    loadingRessource = "loading item.mp3";
    item = new SoundFile(LeBouchonOr.this, "item.mp3");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/intro.png";
    imgIntro = loadImage("NiveauBoss/intro.png");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/thibault1.png";
    imgDialogue1 = loadImage("NiveauBoss/thibault1.png");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/thibault2.png";
    imgDialogue2 = loadImage("NiveauBoss/thibault2.png");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/thibault3.png";
    imgDialogue3 = loadImage("NiveauBoss/thibault3.png");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/fin.png";
    imgDialogue4 = loadImage("NiveauBoss/fin.png");
    loadingProgress--;
    loadingRessource = "loading thibault.png";
    thibault = loadImage("thibault.png");
    loadingProgress--;
    loadingRessource = "loading NiveauBoss/fond.png";
    fond = loadImage("NiveauBoss/fond.png");
    loadingProgress--;
    plateformes.add(new Plateforme(355, 410, 398, false));
    plateformes.add(new Plateforme(325.5, 193, 246, false));
    plateformes.add(new Plateforme(966, 410, 398, false));
    plateformes.add(new Plateforme(1006, 193, 246, false));
    boss = new Sprite(1038, 382.5);
    boss.chargeImage("NiveauBoss/boss.png");
    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  void actualiser() {
    
    if (!intro && !dialogue1 && !dialogue2 && !dialogue3 && !gagne && fade.tempsEcoule && !dialogue4) {
      if(vie <= 50 && !phase2){
        phase2 = true;
        musiquePhase1.stop();
        musiquePhase2.loop();
        vx = 6.5;
      }
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.

      if (boss.x+w/2 > cv.width) {
        boss.x = cv.width-boss.width()/2;
        boss.mirroir = false;
      } else if (boss.x-w/2 < 0) {
        boss.x = boss.width()/2;
        boss.mirroir = true;
      }
      if (boss.mirroir) {
        boss.x += vx;
      } else if (!boss.mirroir) {
        boss.x -= vx;
      }
      
      if (joueur.spriteFrappe.anime) { 
        boolean collision;
        // La hitbox du joueur est orientée.
        if (joueur.aligneDroite)
          collision = collisionRectangles(joueur.x+joueur.w, joueur.y, joueur.w*3, joueur.h, boss.x, boss.y, w, h);
        else
          collision = collisionRectangles(joueur.x-joueur.w, joueur.y, joueur.w*3, joueur.h, boss.x, boss.y, w, h);
        // On vérifie que le joueur ne puisse pas "mitrailler l'ennemi".
        if (collision && !estBlesse) {
          vie -= 5 ; // On perd de la vie
          estBlesse = true;
        }
      } else {
        estBlesse = false;  
      }
      
      //Si le joueur lui tire dessus:
      if(joueur.aTire && !joueur.ennemiTouche){
        boolean collision = collisionRectangles(joueur.balleX, joueur.balleY, joueur.balleW, joueur.balleH, boss.x, boss.y, w, h);
        if(collision && !joueur.ennemiTouche){
            vie -= 5; // On perd de la vie
            joueur.ennemiTouche = true;
            if (vie <= 0){ // Si on est mort alors le joueur gagne de l'xp.
              fade.lancer();
              gagne = true;
          }
        }
      }
      
      boolean collisionJoueur = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, boss.x, boss.y, w, h);
        // Si il y a eu une collision avec le joueur et que l'ennemi n'est pas "en cours" d'attaque, on blesse le joueur.
      if (collisionJoueur) {
          float direction = (joueur.x-boss.x)/abs(joueur.x-boss.y);
          float repousse = 200 * direction;
          joueur.degatsRecu((int) (100), repousse);
      }

      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).

      //Le joueur ne peut pas sortir de l'écran
      if (joueur.x-joueur.w/2 <= 0) {
        joueur.vx = 0;
        joueur.x = joueur.w/2;
      } else if (joueur.x+joueur.w/2 >= cv.width) {
        joueur.vx = 0;
        joueur.x = cv.width - joueur.w/2;
      }
      if (joueur.y + joueur.h/2 >= 4*cv.height/5) {
        joueur.vy = 0;
        joueur.y = 4*cv.height/5-joueur.h/2;
        joueur.surPlateforme = true;
        if (joueur.estPousse)
          joueur.estPousse = false;
      }
      
      if(vie <=0){
          gagne = true;
          musiquePhase2.stop();
          meurt.play();
          fade.lancer();
      }
      
    }
    
    if(fade.tempsEcoule && gagne){
      dialogue4 = true;  
    }
    fade.actualiser();
    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  void afficher() {
    if (!intro) {
      cv.background(0);
      cv.image(fond, 0, 0);
      if (!dialogue1 && !dialogue2 && !dialogue3 && !gagne && !dialogue4)
        boss.afficher();
      joueur.afficher();
      //********** DEBUGAGE *********//
      if (debug) {
        affichePlateformesDebug(plateformes);
        cv.rectMode(CENTER);
        cv.noFill();
        cv.stroke(255, 0, 0);
        cv.rect(boss.x, boss.y, w, h);
      }
    } 
    else
      infoChargeNiveau(); // On charge le niveau;
   if(dialogue4 || intro)
      cv.background(50);

    if (intro || dialogue1 || dialogue2 || dialogue3 || dialogue4) {
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
      if (intro)
        cv.image(imgIntro, 215, 535);
      else if (dialogue1)
        cv.image(imgDialogue1, 215, 535);
      else if (dialogue2)
        cv.image(imgDialogue2, 215, 535);
      else if (dialogue3)
        cv.image(imgDialogue3, 215, 535);
      else if (dialogue4)
        cv.image(imgDialogue4, 215, 535);
    }

    if ((dialogue1 || dialogue2 || dialogue3) && !intro) {
      cv.image(thibault, 1056, 435);
    }

    if (!intro && !dialogue1 && !dialogue2 && !dialogue3 && !dialogue4 && !gagne){
      hud.afficher();
      //Vie du de thibault.
      cv.rectMode(CORNER);
      cv.noStroke();
      cv.fill(50);
      cv.rect(0,675, cv.width, 38);
      cv.fill(255,0, 0);
      float valeur = map(vie, 0, 100, 0, cv.width);
      cv.rect(0, 675, valeur, 32);
      cv.fill(255);
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 625, 200, 64);
      cv.fill(0);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.text("Thibault Omega", cv.width/2, 625);
    }
    
    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      cv.fill(0, 0, 0, 255);
      if (gagne) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        cv.fill(0, 0, 0, transparence);
      }
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    }
    
  }

  void keyPressed() {
    if (key == ' ') {
      // Pemier dialogue.
      if (intro) {
        intro = false;
      } else if (dialogue1) {
        dialogue1 = false;
      } else if (dialogue2) {
        dialogue2 = false;
      } else if (dialogue3) {
        dialogue3 = false;
        musiqueIntro.stop();
        item.play();
        musiquePhase1.loop();
      } else if(dialogue4){
        dialogue4 = false;
        musiqueIntro.stop();
        niveau = 1;
        infoChargeNiveau();
        credits.relancer();
      }
    } else if (!dialogue1 && !intro && !dialogue2 && !dialogue3 && !gagne && fade.tempsEcoule) {
      joueur.keyPressed();
    }
  }

  // Gestion des touches relâchées.
  void keyReleased() {

    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }
  
  void pause(){
    musiqueIntro.stop();
    musiquePhase1.stop();
    musiquePhase2.stop();
  }

  void relancer() {
    reinitialiser();
    musiqueIntro.loop();
    joueur.initNiveau(197, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    joueur.aligneDroite = true;
    joueur.balleMaxDistance = 720;
    joueur.vie = 100;
  }
  
  void reinitialiser(){
      intro = true;
      dialogue1 = true;
      dialogue2 = true;
      dialogue3 = true;
      gagne = false;
      estBlesse = false;
      phase2 = false;
      fade.tempsEcoule = true;
      pause();
      vie = 100;
      vx = 4;
      boss.x = 1038;
  }
}
