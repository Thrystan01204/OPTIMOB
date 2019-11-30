class Credits {

  // Vitesse de défilement des crédits.
  float speed = 1;

  // Position du pavé de texte.
  float y = height-32;

  //Crédits
  String texte = "OPTIMOB\n\nRéalisé par:\n Pierre Jaffuer,\nRonico Billy,\nOlivier Vee,\nIbnou Issouffa,\nMatthieu Mehon Shit Li,\nTristan Le Lidec";
  
  // Entier qui représente l'opacité du cache de l'écran, c'est la transition "fade out" vers les crédits.
  int transparence = 255;

  // Musique de fond.
  SoundFile musique;

  // Initialisation
  Credits() {
    musique = new SoundFile(Game.this, "Credits/musique.wav");
  }

  // Gestion de la logique du niveau.
  void actualiser() {
    y -= speed; // On fait défiler les crédits.
    if(transparence > 0)
      transparence -= 1;
  }

  void afficher() {
    background(50);
    //Crédits
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text(texte, width/2, y);
    
    // Si on est encore en transition (fade out) alors c'est que la transparence est > 0.
    if (transparence > 0) {
      // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade out".
      noStroke();
      fill(0, 0, 0, transparence);
      rectMode(CORNER);
      rect(0, 0, width, height);
    }
  }

  // Permet de revenir au menu principal.
  void retourMenuPrincipal() {
    pause(); // On pause ce niveau.
    niveau = 0; // //On indique au système de gestion des niveaux que l'on se trouve maintenant au menu principal.
    infoChargeNiveau();  // On indique que le niveau charge.
    menuPrincipal.relancer(); // On relance le niveau : menu principal.
  }

  // Relance le niveau.
  void relancer() {
    musique.loop();
    y = height-32;
    transparence = 255;
  }

  // Met en pause le niveau.
  void pause() {
    musique.stop();
  }
}
