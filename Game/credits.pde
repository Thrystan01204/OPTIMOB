class Credits {

  // Vitesse de défilement des crédits.
  float speed = 1;

  // Position du pavé de texte.
  float y = height-32;

  //Crédits
  String texte = "OPTIMOB\n\nRéalisé par:\n Pierre Jaffuer,\nRonico Billy,\nOlivier Vee,\nIbnou Issouffa,\nMatthieu Mehon Shit Li,\nTristan Le Lidec";

  // Musique de fond.
  SoundFile musique;

  // Initialisation
  Credits() {
    musique = new SoundFile(Game.this, "MenuPrincipal/adventure.wav");
  }

  // Gestion de la logique du niveau.
  void actualiser() {
    y -= speed; // On fait défiler les crédits.
  }

  void afficher() {
    background(50);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text(texte, width/2, y);
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
  }

  // Met en pause le niveau.
  void pause() {
    musique.stop();
  }
}
