class GameOver {

  SoundFile musique;
  int transparence = 255;

  GameOver() {
    musique = new SoundFile(Game.this, "fin.wav");
  }

  void afficher() {
    if(transparence > 0)
      transparence -= 1;
    cv.background(50);
    cv.textSize(50);
    cv.textAlign(CENTER, CENTER);
    cv.fill(255, 0, 0);
    cv.text("Vous avez perdu.", cv.width/2, cv.height/2);
    cv.textSize(24);
    cv.fill(255);
    cv.text("Appuyez sur espace pour revenir au menu principal.", cv.width/2, 3*cv.height/4);
    
    // Si on est encore en transition (fade out) alors c'est que la transparence est > 0.
    if (transparence > 0) {
      // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade out".
      cv.noStroke();
      cv.fill(0, 0, 0, transparence);
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    }
    
  }

  void keyPressed() {
    if (key == ' ') {
      pause();
      //On revient au menu principal
      infoChargeNiveau();
      niveau = 0;
      menuPrincipal.relancer();
    }
  }

  void relancer() {
    musique.loop();
    transparence = 255;
  }

  void pause() {
    musique.stop();
  }
}
