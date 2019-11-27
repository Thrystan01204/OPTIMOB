//************************************************** Déclaration des ressources du jeu **********************************************//

import processing.sound.*;  // Bibliothèque pour gérer les musiques.

//-------------------------------------------------- AIDE AU DEBUGAGE ---------------------------------------------------------
// Si cette variable est vraie, on affiche à l'écran les aides de débugage, à désactivé lors de la sortie du jeu
boolean debug = false; 
//-----------------------------------------------------------------------------------------------------------------------------


//----------------------------------- Variables globales pour la gestion des niveaux ------------------------------------------
int niveau = 0; // permet de savoir dans quel niveau on se trouve
//0 = menu principal
//1 = crédits
//2 = cinématique de début
//3 = niveau plage
//4 = niveau volcan
//5 = niveau village
//6 = Boss final
//7 = cinématique de fin
//8 = niveau de test (seulement pour le debugage)

float dt = 1.0/60; // Pas de temps pour l'intégration du mouvement pour le système de physique 

Joueur joueur;
MenuPrincipal menuPrincipal; // Objet contenant le code du menu principal.
Credits credits; // Objet contenant le code des credits.

NiveauTest niveauTest;

//------------------------------------------------------------------------------------------------------------------------------


//---------------------------------- Variables globales pour la gestion de l'écran de chargement -------------------------------
boolean chargementDuJeu = true; // Permet de savoir si le jeu a fini de charger toutes les ressources.
PImage logo; // Image affichée lors du chargement
//------------------------------------------------------------------------------------------------------------------------------


//*************************************************** Fonctions utiles *********************************************************//

// Fonction qui permet d'initialiser tout les niveaux en mémoire.
void chargerNiveaux(){
  
  // Création du menu principal.
  menuPrincipal = new MenuPrincipal();
  
  // Création des crédits.
  credits = new Credits();
  
  // Création d'un niveau de test
  niveauTest = new NiveauTest();
  
  // Création du joueur
  joueur = new Joueur();
  
  // On indique que le chargement est fini, pour pouvoir passer de l'écran de chargement au menu principal.
  chargementDuJeu = false;
  
  // Puis on lance le menu principal.
  menuPrincipal.reinitialiser();
}


// fonction pour détecter si la souris se trouve dans un rectangle, utile pour l'interface
boolean sourisDansRectangle(float x1, float y1, float x2, float y2){
    return (x1 <= mouseX && mouseX <= x2 && y1 <= mouseY && mouseY <= y2);
}



//************************************************************* Gestion du jeu ****************************************************************************//

void setup(){
  // Le jeu est écrit pour une résolution fixe de 1280x720 pixels (HD).
  size(1280, 720);
  logo = loadImage("chargement.png");
  // On charge tous les niveaux au début du jeu sur un autre thread pour pouvoir afficher une animation pendant le chargement.
  // Remarque: la fonction "thread" créé un thread et execute une méthode sur celui-ci, une fois la méthode executée, processing tue en automatique le thread.
  thread("chargerNiveaux");
  
}


// Boucle du jeu, cette fonction est exécutée le plus rapidement possible
void draw(){
  // Gestion de l'actualisation (et de l'affichage) des différents niveaux.
  if(chargementDuJeu){
    
    // On affiche une animation indiquant que le jeu n'a pas planté et qu'il continue de se charger.
    background(50);
    fill(255);
    textSize(72);
    textAlign(CENTER, CENTER);
    String texte = "CHARGEMENT";
    text(texte, width/2, height/4);
    
    //On change de repère temporairement pour facilité la rotation
    pushMatrix();
      translate(width/2, height/2+106);
      rotate(millis()/1000.0); // la rotation dépend du temps écoulé et elle est 2PI périodique, d'où l'animation.
      image(logo, -106, -106);
    popMatrix(); // On se replace dans le repère original
    
  } else if(niveau == 0){
    // Actualisation du menu principal
    menuPrincipal.update();
    menuPrincipal.afficher();
  } else if (niveau == 1){
    // Actualisation des crédits
    credits.update();
    credits.afficher();
  } else if(niveau == 8){
    niveauTest.update();
    niveauTest.afficher();
  }
  
  //************** DEBUGAGE ************//
  if(debug){
    // Affichage des FPS
    textSize(32);
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    text(str(int(frameRate))+" FPS", width/2, 32);
  }
    
}

void mousePressed(){
  if(!chargementDuJeu){
    if(niveau == 0)
      menuPrincipal.mousePressed();
  }
}

void keyReleased(){
  if(!chargementDuJeu){
    if(niveau == 8)
      niveauTest.keyReleased();
  }
}

void keyPressed(){
  // Cas spécial Si on appuie sur la touche "echap"
  if(key == ESC){
    key = 0; // cela permet de faire croire à processing que l'on a pas appuié sur la touche "echap" et donc l'empêche de fermer le jeu
  }
  
  if(!chargementDuJeu){
    if(niveau == 1)
      credits.retourMenuPrincipal();
    else if (niveau == 8)
      niveauTest.keyPressed();
  }
}
