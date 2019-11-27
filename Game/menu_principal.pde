// Classe spéciale pour le menu principal, cela permet de garder le code organisé
class MenuPrincipal{
  boolean actif = false;
  
  // Fond du menu
  PImage fond; 
  
  // 2 nuages qui se déplacent à l'écran
  Sprite petitNuage;
  Sprite grosNuage;
  
  // les 3 boutons
  PImage boutonQuitter;
  PImage boutonNouvellePartie;
  PImage boutonCredits;
  
  // la musique de fond
  SoundFile musique;
  
  // Entier qui représente l'opacité du du cache de l'écran, c'est la transition "fade in" vers le menu
  int transparence = 255;
  
  // Initialisation de toutes les ressources utilisées pour le fonctionnement du menu
  MenuPrincipal(){
    
    fond = loadImage("MenuPrincipal/fond.png");
    boutonQuitter = loadImage("MenuPrincipal/bouton_quitter.png");
    boutonNouvellePartie = loadImage("MenuPrincipal/bouton_nouvelle_partie.png");
    boutonCredits = loadImage("MenuPrincipal/bouton_credits.png");
    musique = new SoundFile(Game.this, "MenuPrincipal/adventure.wav");
    
    //On initialise les nuages
    petitNuage = new Sprite(96, 0, false);
    grosNuage = new Sprite(695, height-678, false);
    
    //On charge l'image associée aux nuages
    petitNuage.chargeImage("MenuPrincipal/petit_nuage.png");
    grosNuage.chargeImage("MenuPrincipal/gros_nuage.png");
  }
  
  
  //C'est ici que toute la logique du menu est gérée
  void update(){
    // On déplace les nuages
    petitNuage.x -= 1;
    grosNuage.x -= 1;
    
    // Si les nuages ne sont plus visibles, on les replacent de l'autre coté de l'écran
    if(petitNuage.x+petitNuage.width() < 0)
      petitNuage.x = width;
    if(grosNuage.x+grosNuage.width() < 0)
      grosNuage.x = width;
      
    //On veut que la transition s'accelère pour donner plus rapidement accès a l'interface
      if(transparence < 100)
        transparence -= 4;
      else
        transparence -=2;
  }
  
  //C'est ici que tout affichage du menu est gérée 
  void afficher(){
    // on affiche les différents éléments
    background(fond);
    grosNuage.afficher();
    petitNuage.afficher();
    
    afficheBouton(boutonCredits, 541, 563);
    afficheBouton(boutonNouvellePartie, 541, 492);
    afficheBouton(boutonQuitter, 541, 633);
    
    // Si on est encore en transition (fade in) alors c'est que la transparence est > 0
    if(transparence > 0){
      // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade in"
      noStroke();
      fill(0, 0, 0, transparence);
      rectMode(CORNER);
      rect(0, 0, width, height);
    }
  }
  
  //Méthode pour afficher un bouton, avec changement de couleur si la souris le survole
  void afficheBouton(PImage bouton, int x, int y){
    int h = bouton.height;
    int w = bouton.width;
    
    // on teste si la souris survole le bouton et que la transition est "fade in" est finie
    if(sourisDansRectangle(x,y,x+w,y+h) && transparence <= 0)
      tint(255, 0, 0); // si oui on bascule les couleurs vers le rouge
    
    image(bouton, x, y); // On affiche le bouton
    noTint(); // On s'assure que l'on ne modifie plus la coloration
    
    // On affiche la hitbox en cas de debugage
    if(debug){
      noFill();
      stroke(255, 0, 0);
      rectMode(CORNER);
      rect(x, y, w, h);
    }
  }
  
  //Méthode pour gérer de façon évènementiel lorsque l'on clique avec la souris
  void mousePressed(){
    // Il faut que la transition "fade in" soit fine
    if(transparence <= 0){
      // Les boutons ont tous la même hauteur et la même épaisseur
      int h = boutonCredits.height;
      int w = boutonCredits.width;
      
      //On teste si la souris survole un des boutons lors du clique
      if(sourisDansRectangle(541,563,541+w,563+h)){ // Bouton crédits
        pause();
        credits.reinitialiser();
        niveau = 1; //On vas aux crédits
      } else if(sourisDansRectangle(541,492,541+w,492+h)){ // Bouton nouvelle partie
        pause();
        niveau = 8;
        niveauTest.relancer();
      } else if(sourisDansRectangle(541,633,541+w,633+h)){ // Bouton quitter
        pause();
        exit();
      }
    }
  }
  
  void pause(){
    musique.stop();
  }
  
  // Lorsque l'on revient au menu principal, on s'assure que tous soit réinitialisé (cela permet d'éviter de réinstancier le menu)
  void reinitialiser(){
    transparence = 255; // On réinitialise la transition "fade in"
    musique.loop(); // On relance la musique
  }
  
}
