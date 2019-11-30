//************************************************** Déclaration des ressources du jeu **********************************************//

import processing.sound.*;  // Bibliothèque pour gérer les musiques.

//-------------------------------------------------- AIDE AU DEBUGAGE ---------------------------------------------------------
// Si cette variable est vraie, on affiche à l'écran les aides de débugage, à désactivé lors de la sortie du jeu
boolean debug = true; 
//-----------------------------------------------------------------------------------------------------------------------------


//----------------------------------- Variables globales pour la gestion des niveaux ------------------------------------------
int niveau = 0; // permet de savoir dans quel niveau on se trouve
//0 = menu principal
//1 = crédits
//2 = niveau ville
//3 = niveau plage
//4 = niveau volcan
//5 = cinématique de début
//6 = Boss final
//7 = cinématique de fin
//8 = niveau de test (seulement pour le debugage)

float dt = 1.0/60; // Pas de temps pour l'intégration du mouvement du joueur.
Joueur joueur; // Objet joueur.

Camera camera; // Objet Camera, permet le "scrolling" des niveaux lors du déplacement du joueur.

MenuPrincipal menuPrincipal; // Objet contenant le code du menu principal.
Credits credits; // Objet contenant le code des credits.
NiveauVille niveauVille; // Objet content le code du niveau de la ville.
NiveauTest niveauTest; // Objet contenant un niveau de test, uniquement pour le debugage.

//------------------------------------------------------------------------------------------------------------------------------


//---------------------------------- Variables globales pour la gestion de l'écran de chargement -------------------------------
boolean chargementDuJeu = true; // Permet de savoir si le jeu a fini de charger toutes les ressources.
PImage logo; // Image affichée lors du chargement
//------------------------------------------------------------------------------------------------------------------------------


//*************************************************** Fonctions utiles *********************************************************//

// Fonction qui permet d'initialiser tout les niveaux en mémoire.
void chargerNiveaux() {


  // Création du joueur.
  joueur = new Joueur(-100, -100);

  // Création de la caméra.
  camera = new Camera();

  // Création du menu principal.
  menuPrincipal = new MenuPrincipal();

  // Création des crédits.
  credits = new Credits();

  // Création d'un niveau de test
  niveauTest = new NiveauTest();
  
  // Création du niveau ville
  niveauVille = new NiveauVille();

  // On indique que le chargement est fini, pour pouvoir passer de l'écran de chargement au menu principal.
  chargementDuJeu = false;

  // Puis on lance le menu principal.
  menuPrincipal.relancer();
}


// fonction pour détecter si la souris se trouve dans un rectangle, utile pour l'interface
boolean sourisDansRectangle(float x1, float y1, float x2, float y2) {
  return (x1 <= mouseX && mouseX <= x2 && y1 <= mouseY && mouseY <= y2);
}

// Permet d'afficher un écran de chargement du niveau, normalement ceci n'est pas nécéssaire car les niveaux sont déja préchargés lors du chargement du jeu.
// Cependant, sur certaines machine, le moteur de rendu P2D (OPENGL) peu mettre beaucoup de temps à déterminer les ressources qui sont utilisées dans un niveau, donnant l'impression
// que le jeu plante, ce qui est faux d'où cette fonction d'indication de chargement.
// Sur un core m3, le changement de niveau prend environ 30 secondes.
void infoChargeNiveau(){
  background(50);
  textAlign(CENTER, CENTER);
  textSize(72);
  fill(255);
  text("CHARGEMENT DU NIVEAU", width/2, height/2);
  textSize(24);
  text("Cette opération peu prendre quelques secondes...ou minutes en fonction de votre matériel.", width/2, 3*height/4);
}

void collisionLimites(){
  if(joueur.x-joueur.w/2 <= 0){
    joueur.vx = 0;
    joueur.x = joueur.w/2;
  } else if(joueur.x+joueur.w/2 >= width*3){
    joueur.vx = 0;
    joueur.x = 3*width - joueur.w/2;
  }
  if(joueur.y + joueur.h/2 >= 4*height/5){
      joueur.vy = 0;
      joueur.y = 4*height/5-joueur.h/2;
      joueur.surPlateforme = true;
  }
}

//***************************************** Gestion des plateformes *********************************************//

Plateforme plateformeCandidate = null; // Plateforme candidate à la collision avec le joueur, null => pas de plateforme candidate.

// La résolution de la collision s'effectue en 3 étapes:
// 1 - Pour toutes les plateformes, on compare la hauteur des pieds du joueur avec la position y de la plateforme pour
//     déterminer la plateforme la plus proche.
// 2 - Pour toutes les plateformes (de la plus haute trouvée précédement vers la plus basse), on teste jusqu'a ce qu' une 
//     plateforme vérifie la condition suivante: 
//     si les pieds du joueur sont au dessus de la plateforme et que une partie de l'épaisseur du joueur recouvre
//     une partie de l'épaisseur de la plateforme, on considère cette plateforme comme candidate à la collision.
// 3 - Une fois que la plateforme est définie comme candidate à la collision, on actualise les positions du joueur,
//     si la position des pieds est alors plus basse que la hauteur de la plateforme, c'est qu'il y a eu collision.
//     On repositionne alors les pieds du joueur au niveau de la plateforme, et on met le joueur en état de 
//     "je suis sur une plateforme".

// Fonction qui permet de trouver le plateforme candidate a la collision avec le joueur dans une liste de plateforme.
void trouverPlateformeCandidate(ArrayList<Plateforme> plateformes) {
  plateformeCandidate = null; // Il faut s'assurer que l'on teste toute les plateformes, donc on dit qu'aucune d'elle n'est candidate
  for (Plateforme p : plateformes) {
    // Si la plateforme se trouve sous les pieds du joueur, alors on teste plus précisément la collision.
    if (p.y >= joueur.y+joueur.h/2) {
      boolean collisionPotentielle = p.collisionPotentielle();
      // Si la largeur du joueur et la largeur de la plateformes sont superposées:
      if (collisionPotentielle) {
        // Si il n'y a pas de plateforme candidate, on prend la première testée pour pouvoir la comparéer avec les autres.
        if (plateformeCandidate == null) {
          plateformeCandidate = p;
        }
        // Si on a déja une plateforme candidate, on regarde si la nouvelle est plus proche des pieds du joueur,
        // si oui, on la définie comme étant la nouvelle plateforme candidate a la collision.
        else if (p.y-(joueur.y+joueur.h/2) <= plateformeCandidate.y-(joueur.y+joueur.h/2)) {
          plateformeCandidate = p;
        }
      }
    }
  }
}

// Fonction qui permet de résoudre la collision entre le joueur et la plateforme candidate si elle a eu lieu.
void collisionPlateformes() {
  // Il faut au moins une plateforme candidate à la collision.
  if (plateformeCandidate != null) {
    // Si la plateforme a une collision permanente on résout toujours la collision.
    // Dans le cas contraire, on résout la collision que si le joueur ne veut pas descendre de la plateforme.
    if (plateformeCandidate.collisionPermanente || !joueur.descendPlateforme) {
      // Si les pieds du joueurs sont plus bas que la plateforme candidate, c'est qu'il y a eu collision.
      if (joueur.y+joueur.h/2 >= plateformeCandidate.y) {
        joueur.vy = 0;
        joueur.y = plateformeCandidate.y - joueur.h/2;
        joueur.surPlateforme = true;
        return; // On arrête la fonction qui a fini son travail.
      }
    }
  }

  // Si les conditions précédentes ne sont pas réalisées, c'est que le joueur est encore en saut ou/et qu'il n'y a
  // pas de plateformes sous ses pieds
  joueur.surPlateforme = false;
}

// Permet de voir les plateformes d'une liste (par défaut elles sont invisibles, car ce ne sont que des "collisions").
void affichePlateformesDebug(ArrayList<Plateforme> plateformes) {
  for (Plateforme p : plateformes) {
    if (p == plateformeCandidate) {
      stroke(0, 255, 0);
      line(joueur.x, joueur.y+joueur.h/2, joueur.x, p.y);
    } else {
      stroke(255, 0, 0);
    }
    line(p.x-p.w/2, p.y, p.x+p.w/2, p.y);
  }
}

// *********************************************** Gestions des murs *******************************************//

Mur murGaucheCandidat = null; // Mur candidat à la collision avec le joueur sur sa face gauche, null => pas de mur candidat.
Mur murDroitCandidat = null; // Mur candidat à la collision avec le joueur sur sa face droite, null => pas de mur candidat.


// Fonction qui permet de trouver le mur gauche et droit candidats a la collision avec le joueur dans une liste de murs.
void trouverMursCandidats(ArrayList<Mur> murs) {
  // Il faut s'assurer que l'on teste tout les murs, donc on dit qu'aucun deux n'est candidat.
  murGaucheCandidat = null;
  murDroitCandidat = null;
  for (Mur p : murs) {
    // Si le mur se trouve à droite de la hitbox du joueur, alors on teste plus précisément la collision.
    if (p.x >= joueur.x+joueur.w/2) {
      boolean collisionPotentielle = p.collisionPotentielle();
      // Si la hauteur du joueur et la hauteur du mur sont superposées:
      if (collisionPotentielle) {
        // Si il n'y a pas de mur candidat à droite, on prend le premier testée pour pouvoir le comparéer avec les autres.
        if (murDroitCandidat == null) {
          murDroitCandidat = p;
        }
        // Si on a déja un mur droit candidat, on regarde si le nouveau est plus proche de la face droite du joueur,
        // si oui, on le définit comme étant le nouveau mur à droite candidat a la collision.
        else if (p.x-(joueur.x+joueur.w/2) <= murDroitCandidat.x-(joueur.x+joueur.w/2)) {
          murDroitCandidat = p;
        }
      }
    }
    // Si le mur se trouve à gauche de la hitbox du joueur, alors on teste plus précisément la collision.
    else if (p.x <= joueur.x-joueur.w/2) {
      boolean collisionPotentielle = p.collisionPotentielle();
      // Si la hauteur du joueur et la hauteur du mur sont superposées:
      if (collisionPotentielle) {
        // Si il n'y a pas de mur candidat à gauche, on prend le premier testée pour pouvoir le comparéer avec les autres.
        if (murGaucheCandidat == null) {
          murGaucheCandidat = p;
        }
        // Si on a déja un mur gauche candidat, on regarde si le nouveau est plus proche de la face gauche du joueur,
        // si oui, on le définit comme étant le nouveau mur à gauche candidat a la collision.
        else if ((joueur.x-joueur.w/2) - p.x <= (joueur.x-joueur.w/2) - murGaucheCandidat.x) {
          murGaucheCandidat = p;
        }
      }
    }
  }
}

// Fonction qui permet de résoudre la collision entre le joueur et la les murs candidats si elle a eu lieu.
void collisionMurs() {
  // Il faut au moins un mur a droite candidat à la collision.
  if (murDroitCandidat != null) {
    // Si la face droite du joueur est plus à droite que le mur droit candidat, c'est qu'il y a eu collision.
    if (joueur.x+joueur.w/2 >= murDroitCandidat.x) {
      if (joueur.vx > joueur.vitesseDeplacement)
        joueur.vx = joueur.vitesseDeplacement;
      joueur.x = murDroitCandidat.x - joueur.w/2;
    }
  }
  // Il faut au moins un mur a gauche candidat à la collision.
  if (murGaucheCandidat != null) {
    // Si la face gauche du joueur est plus à gauche que le mur gauche candidat, c'est qu'il y a eu collision.
    if (joueur.x-joueur.w/2 <= murGaucheCandidat.x) {
      if (joueur.vx < -joueur.vitesseDeplacement)
        joueur.vx = -joueur.vitesseDeplacement;
      joueur.x = murGaucheCandidat.x + joueur.w/2;
    }
  }
}

// Permet de voir les murs d'une liste (par défaut ils sont invisibles, car ce ne sont que des "collisions").
void afficheMursDebug(ArrayList<Mur> murs) {
  for (Mur p : murs) {
    if (p == murDroitCandidat || p == murGaucheCandidat) {
      stroke(0, 255, 0);
      line(joueur.x, joueur.y, p.x, joueur.y);
    } else
      stroke(255, 0, 0);
    line(p.x, p.y-p.h/2, p.x, p.y+p.h/2);
  }
}

//************************************************************* Gestion du jeu ****************************************************************************//

void setup() {
  
  // Le jeu est écrit pour une résolution fixe de 1280x720 pixels (HD).
  // En général, P2D (opengl) est le plus stable, mais sur certains appareils, il peut mettre beaucoup de temps a s'initialiser ou a changer de niveau.
  // L'autre option est le moteur FX2D qui est aussi un moteur qui utilise l'accélération matérielle, il est basé sur JAVAFX, un système de rendu spécialisé dans la 2d,
  // Cependant, il peut y avoir des "saut de frames" ou des coupures du son. Sont chargement est instantané.
  // Il est recommander d' utiliser P2D.
  
  // Remarque, P2D est le seul mode a implémenter correctement le comportement de keyPressed(), en effet, dans tout les autres modes, si l'on garde la touche enfoncée,
  // la méthode est continuellement exécutée.
  size(1280, 720, P2D);
  logo = loadImage("chargement.png");
  // On charge tous les niveaux au début du jeu sur un autre thread pour pouvoir afficher une animation pendant le chargement.
  // Remarque: la fonction "thread" créé un thread et execute une méthode sur celui-ci, une fois la méthode executée, processing tue en automatique le thread.
  thread("chargerNiveaux");
}


// Boucle du jeu, cette fonction est exécutée le plus rapidement possible
void draw() {
  // Gestion de l'actualisation (et de l'affichage) des différents niveaux.
  if (chargementDuJeu) {

    // On affiche une animation indiquant que le jeu n'a pas planté et qu'il continue de se charger.
    background(50);
    fill(255);
    textSize(72);
    textAlign(CENTER, CENTER);
    text("CHARGEMENT", width/2, height/4);

    //On change de repère temporairement pour facilité la rotation
    pushMatrix();
    translate(width/2, height/2+106);
    rotate(millis()/1000.0); // la rotation dépend du temps écoulé et elle est 2PI périodique, d'où l'animation.
    image(logo, -106, -106);
    popMatrix(); // On se replace dans le repère original
  } else if (niveau == 0) {
    // Actualisation du menu principal
    menuPrincipal.actualiser();
    menuPrincipal.afficher();
  } else if (niveau == 1) {
    // Actualisation des crédits
    credits.actualiser();
    credits.afficher();
  } else if (niveau == 2) {
    // Actualisation du niveau de la ville (niveau 1)
    niveauVille.actualiser();
    niveauVille.afficher();
  } else if (niveau == 8) {
    // Actualisation du niveau de test
    niveauTest.actualiser();
    niveauTest.afficher();
  }

  //************** DEBUGAGE ************//
  if (debug) {
    // Affichage des FPS
    textSize(32);
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    text(str(int(frameRate))+" FPS", width/2, 32);
  }
}


void mousePressed() {
  if (!chargementDuJeu) {
    if (niveau == 0)
      menuPrincipal.mousePressed();
  }
}

void keyReleased() {
  if (!chargementDuJeu) {
    if (niveau == 2)
      niveauVille.keyReleased();
    else if (niveau == 8)
      niveauTest.keyReleased();
  }
}

void keyPressed() {
  if (!chargementDuJeu) {
    if (niveau == 1)
      credits.retourMenuPrincipal();
    else if (niveau == 2)
      niveauVille.keyPressed();
    else if (niveau == 8)
      niveauTest.keyPressed();
  }
  // Cas spécial Si on appuie sur la touche "echap"
  if (key == ESC) {
    key = 0; // cela permet de faire croire à processing que l'on a pas appuié sur la touche "echap" et donc l'empêche de fermer le jeu
  }
}
