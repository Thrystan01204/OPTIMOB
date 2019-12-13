class Credits {

  // Vitesse de défilement des crédits.
  float speed = 1.20;

  // Position du pavé de texte.
  float y = 641;

  //Crédits
  PImage img;
  

  // Entier qui représente l'opacité du cache de l'écran, c'est la transition "fade out" vers les crédits.
  int transparence = 255;

  // Musique de fond.
  SoundFile musique;

  // Initialisation
  Credits() {
    musique = new SoundFile(Game.this, "fin.wav");
    img = loadImage("credits.png");
  }

  void afficher() {
      y -= speed; // On fait défiler les crédits.
      if (transparence > 0)
        transparence -= 1;
        
      if(y+img.height < 0)
        retourAuMenu();
        
  
      cv.background(50);
      //Crédits
      cv.image(img, 178, y);
      
      cv.fill(0);
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, cv.height-16, cv.width, 32);
      cv.textAlign(CENTER, CENTER);
      cv.textSize(24);
      cv.fill(255,0,0);
      cv.text("Appuyez sur espace pour revenir au menu principal.", cv.width/2, cv.height-20);
      
  
      // Si on est encore en transition (fade out) alors c'est que la transparence est > 0.
      if (transparence > 0) {
        // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade out".
        cv.noStroke();
        cv.fill(0, 0, 0, transparence);
        cv.rectMode(CORNER);
        cv.rect(0, 0, cv.width, cv.height);
      }
  }

  // Permet de revenir au menu principal.
  void keyPressed() {
    if (key == ' ') {
      retourAuMenu();
    }
  }
  
  void retourAuMenu(){
      pause(); // On pause ce niveau.
      niveau = 0; // //On indique au système de gestion des niveaux que l'on se trouve maintenant au menu principal.
      infoChargeNiveau();  // On indique que le niveau charge.
      menuPrincipal.relancer(); // On relance le niveau : menu principal.
  }

  // Relance le niveau.
  void relancer() {
    musique.loop();
    y = 641;
    transparence = 255;
  }

  // Met en pause le niveau.
  void pause() {
    musique.stop();
  }
}
