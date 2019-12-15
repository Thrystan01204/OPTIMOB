class MenuPrincipal {
  // Fond du menu.
  PImage fond; 

  // 2 nuages qui se déplacent à l'écran.
  Sprite petitNuage;
  Sprite grosNuage;

  // les 3 boutons.
  PImage boutonQuitter;
  PImage boutonNouvellePartie;
  PImage boutonCredits;

  // la musique de fond.
  SoundFile musique;

  // Entier qui représente l'opacité du cache de l'écran, c'est la transition "fade out" vers le menu.
  int transparence = 255;

  // Initialisation de toutes les ressources utilisées pour le fonctionnement du menu.
  MenuPrincipal() {

    // Chargement des ressources du niveau.
    loadingRessource = "loading MenuPrincipal/fond.png";
    fond = loadImage("MenuPrincipal/fond.png");
    loadingProgress--;
    loadingRessource = "loading MenuPrincipal/bouton_quitter.png";
    boutonQuitter = loadImage("MenuPrincipal/bouton_quitter.png");
    loadingProgress--;
    loadingRessource = "loading MenuPrincipal/bouton_nouvelle_partie.png";
    boutonNouvellePartie = loadImage("MenuPrincipal/bouton_nouvelle_partie.png");
    loadingProgress--;
    boutonCredits = loadImage("MenuPrincipal/bouton_credits.png");
    loadingProgress--;
    loadingRessource = "loading MenuPrincipal/musique.mp3";
    musique = new SoundFile(LeBouchonOr.this, "MenuPrincipal/musique.mp3");
    loadingProgress--;

    //On initialise les nuages.
    petitNuage = new Sprite(288, 167);
    grosNuage = new Sprite(963, 283);

    //On charge l'image associée aux nuages.
    petitNuage.chargeImage("MenuPrincipal/petit_nuage.png");
    grosNuage.chargeImage("MenuPrincipal/gros_nuage.png");
  }


  //C'est ici que toute la logique du menu est gérée.
  void actualiser() {
    // On déplace les nuages.
    petitNuage.x -= 1;
    grosNuage.x -= 1;

    // Si les nuages ne sont plus visibles, on les met de l'autre coté de l'écran.
    if (petitNuage.x+petitNuage.width()/2 < 0)
      petitNuage.x = cv.width+petitNuage.width()/2;
    if (grosNuage.x+grosNuage.width()/2 < 0)
      grosNuage.x = cv.width+grosNuage.width()/2;

    //On veut que la transition s'accelère pour donner plus rapidement accès a l'interface.
    if (transparence > 0) {
      if (transparence < 100)
        transparence -= 4;
      else
        transparence -=2;
    }
  }

  //C'est ici que l' affichage du menu est gérée.
  void afficher() {
    // on affiche les différents éléments.
    cv.background(fond);
    grosNuage.afficher();
    petitNuage.afficher();

    afficheBouton(boutonCredits, 541, 563);
    afficheBouton(boutonNouvellePartie, 541, 492);
    afficheBouton(boutonQuitter, 541, 633);

    // Si on est encore en transition (fade out) alors c'est que la transparence est > 0.
    if (transparence > 0) {
      // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade out".
      cv.noStroke();
      cv.fill(0, 0, 0, transparence);
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    }
  }

  //Méthode pour afficher un bouton, avec changement de couleur si la souris le survole.
  void afficheBouton(PImage bouton, int x, int y) {
    int h = bouton.height;
    int w = bouton.width;

    cv.image(bouton, x, y); // On affiche le bouton.

    //************************ DEBUGAGE ***************************//
    if (debug) {
      // On affiche la hitbox en cas de debugage.
      cv.noFill();
      cv.stroke(255, 0, 0);
      cv.rectMode(CORNER);
      cv.rect(x, y, w, h);
    }
  }

  //Méthode pour gérer de façon évènementiel lorsque l'on clique avec la souris
  void mousePressed() {
    // Il faut que la transition "fade in" soit fine
    if (transparence <= 0) {
      // Les boutons ont tous la même hauteur et la même épaisseur
      int h = boutonCredits.height;
      int w = boutonCredits.width;

      //On teste si la souris survole un des boutons lors du clique
      if (sourisDansRectangle(541, 563, 541+w, 563+h)) { // Bouton crédits
        pause(); // On met en pause le menu.
        niveau = 1; //On indique au système de gestion des niveaux que l'on va aux crédits.
        infoChargeNiveau(); // On indique que le niveau charge.
        credits.relancer(); // On relance le niveau crédit.
      } else if (sourisDansRectangle(541, 492, 541+w, 492+h)) { // Bouton nouvelle partie
        reinitialiserJeu(); // On réinitialise le jeu.
        pause(); // On met en pause le menu.
        niveau = 5; //On indique au système de gestion des niveaux que l'on va au niveau d'introduction.
        infoChargeNiveau();  // On indique que le niveau charge.
        niveauIntro.relancer(); // On relance le tuto
      } else if (sourisDansRectangle(541, 633, 541+w, 633+h)) { // Bouton quitter
        pause(); // On met en pause le menu.
        exit(); // On quitte le jeu.
      }
    }
  }

  // Permet de suspendre les actions du menu.
  void pause() {
    musique.stop(); // On arrête la muique de fond.
  }

  // Lorsque l'on revient au menu principal, on s'assure que tout soit réinitialisé (cela permet d'éviter de réinstancier le menu).
  void relancer() {
    invalideBouton = true;
    transparence = 255; // On réinitialise la transition "fade out".
    musique.loop(); // On relance la musique.
  }
}
