package com.optimob.lebouchondor;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.app.Activity; 
import android.content.Context;
import android.media.MediaPlayer;
import android.os.Vibrator;
import android.os.VibrationEffect; 
import android.view.MotionEvent; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LeBouchonOr extends PApplet {

  MediaPlayer

// Vibrations





 //Multi touch

  // Bibliothèque pour gérer les musiques.
Activity act;

String loadingRessource = ""; // affichage de la ressource en chargement.
int loadingProgress = 918;

PGraphics cv; // IMPORTANT: TOUT LE JEU EST AFFICHE SUR CETTE SURFACE QUI A SON TOUR EST AFFICHEE EN PLEIN ECRAN, permet de redimensionner la fenêtre.
// Dimensions d'affichage dans la fenêtre
int widthActuelle; 
int heightActuelle;


// android
boolean invalideBouton = true;
boolean enDialogue = false;
PImage ui; // Image des boutons.
int[] bouton = new int[7]; // Les 7 boutons présents à l'écran.
// -1 = non appuié
// 0
// 1
// .
// .
// . = id du pinteur (doigts)

//-------------------------------------------------- AIDE AU DEBUGAGE ---------------------------------------------------------
// Si cette variable est vraie, on affiche à l'écran les aides de débugage, à désactivé lors de la sortie du jeu
boolean debug = false; 
//-----------------------------------------------------------------------------------------------------------------------------

//----------------------------------- Variables globales pour la gestion des niveaux ------------------------------------------
int niveau = 0; // permet de savoir dans quel niveau on se trouve
//0 = menu principal
//1 = crédits
//2 = niveau ville
//3 = niveau ermitage
//4 = niveau volcan
//5 = introduction
//6 = Boss final
//9 = game over

float dt = 1.0f/60; // Pas de temps pour l'intégration du mouvement du joueur.
Joueur joueur; // Objet joueur.
PImage infoDialogue;
Camera camera; // Objet Camera, permet le "scrolling" des niveaux lors du déplacement du joueur.
HUD hud; // Le HUD.

MenuPrincipal menuPrincipal; // Objet contenant le code du menu principal.
Credits credits; // Objet contenant le code des credits.
NiveauVille niveauVille; // Objet content le code du niveau de la ville.
NiveauIntro niveauIntro; // L'introduction du jeu.
NiveauErmitage niveauErmitage;
NiveauVolcan niveauVolcan;
NiveauBoss niveauBoss;
GameOver gameOver; // Ecrant de fin du jeu.

//------------------------------------------------------------------------------------------------------------------------------


//---------------------------------- Variables globales pour la gestion de l'écran de chargement -------------------------------
boolean chargementDuJeu = true; // Permet de savoir si le jeu a fini de charger toutes les ressources.
PImage logo; // Image affichée lors du chargement
//------------------------------------------------------------------------------------------------------------------------------


//*************************************************** Fonctions utiles *********************************************************//

// Fonction qui permet d'initialiser tout les niveaux en mémoire.
public void chargerNiveaux() {
  // indicateur de dialogues.
  loadingRessource = "loading dialogue_info.png";
  infoDialogue = loadImage("dialogue_info.png");
  loadingProgress--;

  loadingRessource = "loading ui.png";
  ui = loadImage("ui.png");
  loadingProgress--;


  // Création du joueur.
  joueur = new Joueur(-100, -100);

  // Création de la caméra.
  camera = new Camera();

  //Création du HUD.
  hud = new HUD();

  // Création du menu principal.
  menuPrincipal = new MenuPrincipal();

  // Création du niveau d'introduction.
  niveauIntro = new NiveauIntro();

  // Création des crédits.
  credits = new Credits();

  // Création du niveau ville.
  niveauVille = new NiveauVille();

  // Création du niveau ermitage.
  niveauErmitage = new NiveauErmitage();

  //Création du niveau volcan.
  niveauVolcan = new NiveauVolcan();

  //Création du niveau boss.
  niveauBoss = new NiveauBoss();

  //Création du game over.
  gameOver = new GameOver();

  // On indique que le chargement est fini, pour pouvoir passer de l'écran de chargement au menu principal.
  chargementDuJeu = false;

  //On lance le niveau
  if (niveau == 4)
    niveauVolcan.relancer();
  else if (niveau == 0)
    menuPrincipal.relancer();
  else if (niveau == 1)
    credits.relancer();
  else if (niveau == 2)
    niveauVille.relancer(true);
  else if (niveau == 3)
    niveauErmitage.relancer();
  else if (niveau == 5)
    niveauIntro.relancer();
  else if (niveau == 9)
    gameOver.relancer();
  else if (niveau == 6)
    niveauBoss.relancer();
}


// fonction pour détecter si la souris se trouve dans un rectangle, utile pour l'interface
public boolean sourisDansRectangle(float x1, float y1, float x2, float y2) {

  float dx = abs(width-widthActuelle)/2.0f;
  float dy = abs(height-heightActuelle)/2.0f;

  float mx = map(mouseX, dx, dx+widthActuelle, 0, cv.width);
  float my = map(mouseY, dy, dy+heightActuelle, 0, cv.height);

  return (x1 <= mx && mx <= x2 && y1 <= my && my <= y2);
}

// fonction pour si l'on appuie sur un bouton.
public boolean pointDansCercle(float px, float py, float cx, float cy, float r) {
  float dx = abs(width-widthActuelle)/2.0f;
  float dy = abs(height-heightActuelle)/2.0f;

  float mx = map(px, dx, dx+widthActuelle, 0, cv.width);
  float my = map(py, dy, dy+heightActuelle, 0, cv.height);

  return (sq(mx-cx)+sq(my-cy) < sq(r));
}

public boolean collisionRectangles(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  return !((x2-w2/2 >= x1 + w1/2) || (x2 + w2/2 <= x1-w1/2) || (y2-h2/2 >= y1 + h1/2) || (y2 + h2/2 <= y1-h1/2));
}

//Permet de réinitialiser le jeu en cas de mort du joueur ou de fin de partie.
public void reinitialiserJeu() {
  joueur.reinitialiser();
  camera.reinitialiser();
  niveauBoss.reinitialiser();
  niveauErmitage.reinitialiser();
  niveauIntro.reinitialiser();
  niveauVille.reinitialiser();
  niveauVolcan.reinitialiser();
}


// Permet d'afficher un écran de chargement du niveau, normalement ceci n'est pas nécéssaire car les niveaux sont déja préchargés lors du chargement du jeu.
// Cependant, sur certaines machine, le moteur de rendu P2D (OPENGL) peu mettre beaucoup de temps à déterminer les ressources qui sont utilisées dans un niveau, donnant l'impression
// que le jeu plante, ce qui est faux d'où cette fonction d'indication de chargement.
// Sur un core m3, le changement de niveau prend environ 30 secondes.
public void infoChargeNiveau() {
  cv.background(50);
  cv.textAlign(CENTER, CENTER);
  cv.textSize(72);
  cv.fill(255);
  cv.text("CHARGEMENT DU NIVEAU", cv.width/2, cv.height/2);
  cv.textSize(24);
  cv.text("Cette opération peu prendre quelques secondes...ou minutes en fonction de votre matériel.", cv.width/2, 3*cv.height/4);
}

public void collisionLimites() {
  if (joueur.x-joueur.w/2 <= 0) {
    joueur.vx = 0;
    joueur.x = joueur.w/2;
  } else if (joueur.x+joueur.w/2 >= cv.width*3) {
    joueur.vx = 0;
    joueur.x = 3*cv.width - joueur.w/2;
  }
  if (joueur.y + joueur.h/2 >= 4*cv.height/5) {
    joueur.vy = 0;
    joueur.y = 4*cv.height/5-joueur.h/2;
    joueur.surPlateforme = true;
    if (joueur.estPousse)
      joueur.estPousse = false;
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
public void trouverPlateformeCandidate(ArrayList<Plateforme> plateformes) {
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
public void collisionPlateformes() {
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
        if (joueur.estPousse)
          joueur.estPousse = false;
        return; // On arrête la fonction qui a fini son travail.
      }
    }
  }

  // Si les conditions précédentes ne sont pas réalisées, c'est que le joueur est encore en saut ou/et qu'il n'y a
  // pas de plateformes sous ses pieds
  joueur.surPlateforme = false;
}

// Permet de voir les plateformes d'une liste (par défaut elles sont invisibles, car ce ne sont que des "collisions").
public void affichePlateformesDebug(ArrayList<Plateforme> plateformes) {
  for (Plateforme p : plateformes) {
    if (p == plateformeCandidate) {
      cv.stroke(0, 255, 0);
      cv.line(joueur.x, joueur.y+joueur.h/2, joueur.x, p.y);
    } else {
      cv.stroke(255, 0, 0);
    }
    cv.line(p.x-p.w/2, p.y, p.x+p.w/2, p.y);
  }
}

// *********************************************** Gestions des murs *******************************************//

Mur murGaucheCandidat = null; // Mur candidat à la collision avec le joueur sur sa face gauche, null => pas de mur candidat.
Mur murDroitCandidat = null; // Mur candidat à la collision avec le joueur sur sa face droite, null => pas de mur candidat.


// Fonction qui permet de trouver le mur gauche et droit candidats a la collision avec le joueur dans une liste de murs.
public void trouverMursCandidats(ArrayList<Mur> murs) {
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
public void collisionMurs() {
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
public void afficheMursDebug(ArrayList<Mur> murs) {
  for (Mur p : murs) {
    if (p == murDroitCandidat || p == murGaucheCandidat) {
      cv.stroke(0, 255, 0);
      cv.line(joueur.x, joueur.y, p.x, joueur.y);
    } else
      cv.stroke(255, 0, 0);
    cv.line(p.x, p.y-p.h/2, p.x, p.y+p.h/2);
  }
}

//************************************************************* Gestion du jeu ****************************************************************************//

public void setup() {

  // Le jeu est écrit pour une résolution fixe de 1280x720 pixels (HD).
  // En général, P2D (opengl) est le plus stable, mais sur certains appareils, il peut mettre beaucoup de temps a s'initialiser ou a changer de niveau.
  // L'autre option est le moteur FX2D qui est aussi un moteur qui utilise l'accélération matérielle, il est basé sur JAVAFX, un système de rendu spécialisé dans la 2d,
  // Cependant, il peut y avoir des "saut de frames" ou des coupures du son. Sont chargement est instantané.
  // Il est recommander d' utiliser P2D.

  // Remarque, P2D est le seul mode a implémenter correctement le comportement de keyPressed(), en effet, dans tout les autres modes, si l'on garde la touche enfoncée,
  // la méthode est continuellement exécutée.

  
  orientation(LANDSCAPE);
  act = this.getActivity(); // Pour pouvoir faire vibrer le téléphone.

  widthActuelle = 1280;
  heightActuelle = 720;

  cv = createGraphics(1280, 720, P2D);

  logo = loadImage("chargement.png");

  // On initialise les boutons.
  for (int i=0; i<7; i++) bouton[i] = -1;


  // On charge tous les niveaux au début du jeu sur un autre thread pour pouvoir afficher une animation pendant le chargement.
  // Remarque: la fonction "thread" créé un thread et execute une méthode sur celui-ci, une fois la méthode executée, processing tue en automatique le thread.
  thread("chargerNiveaux");
}


// Boucle du jeu, cette fonction est exécutée le plus rapidement possible (limité à 60 fois par secondes).
public void draw() {
  cv.beginDraw();
  // Gestion de l'actualisation (et de l'affichage) des différents niveaux.
  if (chargementDuJeu) {
    // On affiche une animation indiquant que le jeu n'a pas planté et qu'il continue de se charger.
    cv.background(50);
    cv.fill(255);
    cv.textSize(72);
    cv.textAlign(CENTER, CENTER);
    cv.text("CHARGEMENT", cv.width/2, cv.height/4);

    cv.fill(255, 0, 0);
    cv.rectMode(CORNER);
    float x = map(loadingProgress, 917, 0, 0, cv.width);
    cv.rect(0, cv.height-32-24, x, 48);

    cv.textSize(24);
    cv.fill(255);
    cv.text(loadingRessource, cv.width/2, cv.height-32);


    //On change de repère temporairement pour facilité la rotation.
    cv.pushMatrix();
    cv.translate(cv.width/2, cv.height/2+106);
    cv.rotate(millis()/1000.0f); // la rotation dépend du temps écoulé et elle est 2PI périodique, d'où l'animation.
    cv.image(logo, -106, -106);
    cv.popMatrix(); // On se replace dans le repère original.
  } else if (niveau == 0) {
    // Actualisation du menu principal
    menuPrincipal.actualiser();
    menuPrincipal.afficher();
  } else if (niveau == 1) {
    // Actualisation des crédits
    credits.afficher();
  } else if (niveau == 2) {
    // Actualisation du niveau de la ville (niveau 1)
    niveauVille.actualiser();
    niveauVille.afficher();
  } else if (niveau == 9) {
    // Actualisation du game over
    gameOver.afficher();
  } else if (niveau == 5) {
    //Actualisation du niveau d'introduction.
    niveauIntro.actualiser();
    niveauIntro.afficher();
  } else if (niveau == 3) {
    //Actualisation du niveau ermitage.
    niveauErmitage.actualiser();
    niveauErmitage.afficher();
  } else if (niveau == 4) {
    //Actualisation du niveau volcan.
    niveauVolcan.actualiser();
    niveauVolcan.afficher();
  } else if (niveau == 6) {
    //Actualisation du niveau volcan.
    niveauBoss.actualiser();
    niveauBoss.afficher();
  }

  //************** DEBUGAGE ************//
  if (debug) {
    // Affichage des FPS
    cv.textSize(32);
    cv.textAlign(CENTER, CENTER);
    cv.fill(255, 0, 0);
    cv.text(str(PApplet.parseInt(frameRate))+" FPS", cv.width/2, 32);

    // On affiche les points de contacts
    for (int i = 0; i < touches.length; i++) {
      float d = (100 + 100 * touches[i].area) * displayDensity;
      fill(0, 255 * touches[i].pressure);
      ellipse(touches[i].x, touches[i].y, d, d);
      fill(255, 0, 0);
      textSize(32);
      text(touches[i].id, touches[i].x + d/2, touches[i].y - d/2);
    }
  }

  if (!invalideBouton)
    cv.image(ui, 0, 0);

  cv.endDraw();

  //On conserve le ratio d'affichage.
  float ratioX= PApplet.parseFloat(width)/1280.0f;
  float ratioY = PApplet.parseFloat(height)/720.0f;
  float ratio = min(ratioX, ratioY);
  widthActuelle =(int) (1280.0f*ratio);
  heightActuelle =(int) (720.0f*ratio);
  background(0);
  image(cv, width/2-widthActuelle/2, height/2-heightActuelle/2, widthActuelle, heightActuelle);
}


public void mousePressed() {
  if (!chargementDuJeu && invalideBouton) {
    Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
    vibrer.vibrate(50);
    if (niveau == 0)
      menuPrincipal.mousePressed();
    else if (niveau == 1)
      credits.mousePressed();
    else if (niveau == 9)
      gameOver.mousePressed();
  }
}

public void keyReleased() {
  if (!chargementDuJeu) {
    if (niveau == 2)
      niveauVille.keyReleased();
    else if (niveau == 5)
      niveauIntro.keyReleased();
    else if (niveau == 3)
      niveauErmitage.keyReleased();
    else if (niveau == 4)
      niveauVolcan.keyReleased();
    else if (niveau == 6)
      niveauBoss.keyReleased();
  }
}

// Simule le comportement de keyReleased.
public void touchButtonUp(int id) {
  for (int i=0; i <7; i++) {
    if (bouton[i] == id) {
      bouton[i] = -1;
      if (niveau == 5)
        niveauIntro.touchReleased(i);
      else if (niveau == 2)
        niveauVille.touchReleased(i);
      else if (niveau == 3)
        niveauErmitage.touchReleased(i);
      else if (niveau == 4)
        niveauVolcan.touchReleased(i);
      else if (niveau == 6)
        niveauBoss.touchReleased(i);
    }
  }
}

public void keyPressed() {
  if (!chargementDuJeu) {
    if (niveau == 1)
      credits.keyPressed();
    else if (niveau == 5)
      niveauIntro.keyPressed();
    else if (niveau == 2)
      niveauVille.keyPressed();
    else if (niveau == 3)
      niveauErmitage.keyPressed();
    else if (niveau == 4)
      niveauVolcan.keyPressed();
    else if (niveau == 6)
      niveauBoss.keyPressed();
    else if (niveau == 9)
      gameOver.keyPressed();
  }
}

// Simule le comportement de keyPressed.
public void touchButtonDown(int id, float px, float py) {
  if (!chargementDuJeu && !invalideBouton) {
    Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
    int idBouton = -1;
    if (bouton[0] == -1 && pointDansCercle(px, py, 85.68f, 635.75f, 83.22f)) {
      bouton[0] = id;
      idBouton = 0;
    } else if (bouton[1] == -1 && pointDansCercle(px, py, 353.57f, 635.75f, 83.22f)) {
      bouton[1] = id;
      idBouton = 1;
    } else if (bouton[2] == -1 && pointDansCercle(px, py, 1143.94f, 609.68f, 90)) {
      bouton[2] = id;
      idBouton = 2;
    } else if (bouton[3] == -1 && pointDansCercle(px, py, 920.64f, 649, 56)) {
      bouton[3] = id;
      idBouton = 3;
    } else if (bouton[4] == -1 && pointDansCercle(px, py, 973.69f, 502.52f, 54.2f)) {
      bouton[4] = id;
      idBouton = 4;
    } else if (bouton[5] == -1 && pointDansCercle(px, py, 1125.2f, 424.1f, 54.2f)) {
      bouton[5] = id;
      idBouton = 5;
    } else if (bouton[6] == -1 && pointDansCercle(px, py, 1202.36f, 288, 51)) {
      bouton[6] = id;
      idBouton = 6;
    }

    if (idBouton != -1) {
      vibrer.vibrate(50);
      if (niveau == 5)
        niveauIntro.touchPressed(idBouton);
      else if (niveau == 2)
        niveauVille.touchPressed(idBouton);
      else if (niveau == 3)
        niveauErmitage.touchPressed(idBouton);
      else if (niveau == 4)
        niveauVolcan.touchPressed(idBouton);
      else if (niveau == 6)
        niveauBoss.touchPressed(idBouton);
    }
  }
}

// Gestion du multi touch
public boolean surfaceTouchEvent(MotionEvent me) {
  int actionIndex = me.getActionIndex();
  int actionId = me.getPointerId(actionIndex);
  int actionMasked = me.getActionMasked();

  switch(actionMasked) {
    // Quand on presse l'écran
  case MotionEvent.ACTION_DOWN:
  case MotionEvent.ACTION_POINTER_DOWN:
    //gestions des dialogues
    if (invalideBouton) {
      if (niveau == 5)
        niveauIntro.actualiseDialogues();
      else if (niveau == 2)
        niveauVille.actualiseDialogues();
      else if (niveau == 3)
        niveauErmitage.actualiseDialogues();
      else if (niveau == 4)
        niveauVolcan.actualiseDialogues();
      else if (niveau == 6)
        niveauBoss.actualiseDialogues();
    }
    // gestion des boutons
    touchButtonDown(actionId, me.getX(actionIndex), me.getY(actionIndex));
    break;

    // Quan on quitte l'écran
  case MotionEvent.ACTION_UP:
  case MotionEvent.ACTION_POINTER_UP:
  case MotionEvent.ACTION_CANCEL:
    touchButtonUp(actionId);
    break;
  }
  // If you want the variables for motionX/motionY, mouseX/mouseY etc.
  // to work properly, you'll need to call super.surfaceTouchEvent().
  return super.surfaceTouchEvent(me);
}
class HUD {

  HUD() {
  }

  public void afficher() {

    if (joueur.vie > 0) {
      //Barre de vie du joueur
      cv.noStroke();
      //fond de la barre de vie.
      cv.fill(50, 50, 50);
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width/2, 24);
      // Barre de vie.
      cv.fill(255, 0, 0);
      float valeur = map(joueur.vie, 0, 100, 0, cv.width/2);
      cv.rect(0, 0, valeur, 24);
      // Affichage du nombre de pv.
      cv.textSize(20);
      cv.textAlign(LEFT, TOP);
      cv.fill(0);
      cv.text(str(joueur.vie)+" pv", 1, 1);
      cv.fill(255);
      cv.text(str(joueur.vie)+" pv", 0, 0);

      //fond de la barre d'xp.
      cv.fill(50, 50, 50);
      cv.rectMode(CORNER);
      cv.rect(0, 24, cv.width/4, 24);
      // Barre d'xp.
      cv.fill(0, 0, 255);
      if (joueur.level < 10)
        valeur = map(joueur.xp, 0, joueur.xpMax, 0, cv.width/4);
      else
        valeur = cv.width/4;
      cv.rect(0, 24, valeur, 24);


      if (joueur.invulnerableLave) {
        // Affichage de l'invulnérabilité à la lave.
        cv.textSize(20);
        cv.textAlign(LEFT, TOP);
        cv.fill(0);
        cv.text("Invulnerable a la lave", 49, 49);
        cv.fill(255);
        cv.text("Invulnerable a la lave", 48, 48);
      }
      if (joueur.superSaut) {
        // Affichage de la capacité de super saut.
        cv.textSize(20);
        cv.textAlign(LEFT, TOP);
        cv.fill(0);
        cv.text("Super saut", 49, 71);
        cv.fill(255);
        cv.text("Super saut", 48, 70);
      }

      cv.textSize(20);
      if (joueur.level < joueur.levelMax) {
        cv.fill(0);
        cv.text("niveau "+str(joueur.level), 1, 25);
        cv.fill(255);
        cv.text("niveau "+str(joueur.level), 0, 24);
      } else {
        cv.fill(0);
        cv.text("niveau max ("+str(joueur.levelMax)+")", 1, 25);
        cv.fill(255);
        cv.text("niveau max ("+str(joueur.levelMax)+")", 0, 24);
      }
    }
  }
}
class Camera {
  float x, y; // Positions de la caméra.

  float margeY; // Zone sur l'axe y où le déplacement de la caméra n'est pas déclenché.

  // Quantité des déplacements de la caméra lors de la nouvelle "frame", permet d'implémenter le parallax.
  float dx = 0;
  float dy = 0;

  // Initialisation.
  Camera() {
    // La caméra est au centre de l'écran.
    x = cv.width/2;
    y = cv.height/2;
    // On précise la marge d'inactivité.
    margeY = cv.height/6;
  }

  // Actualisation de la position de la caméra.
  public void actualiser() {
    // Pour le moment la caméra n'a pas bougée.
    dx = 0;
    dy = 0;

    // La caméra est centrée en x sur le joueur.
    dx = joueur.x-camera.x;
    x = joueur.x;

    // Si le joueur est hors de la zone Y d'inactivité, on déplace la caméra jusqu'à ce que le joueur soit dans la zone.
    if (joueur.y < y-margeY) {
      dy = y-margeY-joueur.y;
      y -= dy;
    } else if (joueur.y > y+margeY) {
      dy = joueur.y - y-margeY;
      y += dy;
    }

    // Evidemment, on s'assure que la caméra ne sorte pas des limites du niveau.
    if (x-cv.width/2 < 0) {
      x = cv.width/2;
      dx = 0;
    } else if (x+cv.width/2 > 3*cv.width) {
      dx = 0;
      x = 3*cv.width-cv.width/2;
    }
    if (y-cv.height/2 < -cv.height) {
      dy = 0;
      y = -cv.height/2;
    } else if (y+cv.height/2 > cv.height) {
      dy = 0;
      y = cv.height/2;
    }
  }

  // Permet de se placer dans le repère de la caméra lors de l'affichage d'un niveau, cela nous permet de continuer d'afficher les éléments dans le repère initial (donc avec des coordonées en absolues)
  // et de laisser processing calculer les translations pour transfomer les coordonnées en relatives.
  public void deplaceRepere() {
    cv.translate(cv.width/2 - x, cv.height/2 - y); // L'opération qui effectue toute la magie.
  }

  public void reinitialiser() {
    // La caméra est au centre de l'écran.
    x = cv.width/2;
    y = cv.height/2;
  }
}
class Credits {

  // Vitesse de défilement des crédits.
  float speed = 1.20f;

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
    loadingRessource = "loading fin.mp3";
    musique = new SoundFile(LeBouchonOr.this, "fin.mp3");
    loadingProgress--;
    loadingRessource = "loading credits.png";
    img = loadImage("credits.png");
    loadingProgress--;
  }

  public void afficher() {
    y -= speed; // On fait défiler les crédits.
    if (transparence > 0)
      transparence -= 1;

    if (y+img.height < 0)
      retourAuMenu();


    cv.background(50);
    //Crédits
    cv.image(img, 178, y);

    if (transparence <= 0) {
      cv.fill(0);
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, cv.height-16, cv.width, 32);
      cv.textAlign(CENTER, CENTER);
      cv.textSize(24);
      cv.fill(255, 0, 0);
      cv.text("Touchez l'ecran pour revenir au menu principal.", cv.width/2, cv.height-20);
    }


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
  public void keyPressed() {
    if (key == ' ') {
      retourAuMenu();
    }
  }

  public void mousePressed() {
    if (transparence <= 0) {
      retourAuMenu();
    }
  }

  public void retourAuMenu() {
    pause(); // On pause ce niveau.
    niveau = 0; // //On indique au système de gestion des niveaux que l'on se trouve maintenant au menu principal.
    infoChargeNiveau();  // On indique que le niveau charge.
    menuPrincipal.relancer(); // On relance le niveau : menu principal.
  }

  // Relance le niveau.
  public void relancer() {
    invalideBouton = true;
    musique.loop();
    y = 641;
    transparence = 255;
  }

  // Met en pause le niveau.
  public void pause() {
    musique.stop();
  }
}
class Mercenaire {

  float x, y; // Positions
  float h, w; // Dimensions de la hitbox.
  float l1, l2; // Limites du déplacement de l'ennemi sur l'axe x.
  boolean aligneDroite; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
  float vitesseDeplacement = 2; // A quelle vitesse il se déplace.
  int degats = 10; // Dégats de base.

  int vie = 100; // Quantité de vie.
  int level = 1; // level de l'ennemi, ses dégats y sont proportionnels, ainsi que sa résistance.
  float detection = 300; // Rayon de détection du joueur.

  boolean estBlesse = false; // Permet d'eviter que le joueur le tue instantanément.


  // Le projectil de l'ennemi.
  float balleX = 0;
  float balleVitesse = 5;

  // Déplacement maximal de la balle par rapport à son point d'origine.
  float balleMaxDeplacement = 500;

  // Dimension de la balle.
  float balleW = 16;
  float balleH = 8;

  boolean tire; // Permet de figer l'ennemi.
  boolean balleCollision = false; // Permet de cacher la balle et d'ignorer les collisions.

  SoundFile sonAttaque;
  SoundFile sonMeurt;


  private int type; // Le type de mercenaire, ils ont des comportements légèrements différents.
  // 1 = mercenaire immobile, il ne fait que tirer lorsque le joueur est a porté et frappe le joueur si il sont superposées.
  // 2 = mercenaire qui peut bouger, tirer et frapper le joueur.
  // 3 = mercenaire avec une machette, attaque uniquement au corps à corps.

  // Animations.
  Sprite spriteCourse;
  Sprite spriteAttaqueCorps;
  Sprite spriteAttaquePistolet;
  Sprite spriteImmobile;

  Horloge horlogeAttaqueCorps; // Après avoir frappé au coprs à coprs, l'ennemi ne se déplace plus pendant un court instant.
  Horloge horlogeSeRetourner; // Les ennemis de type 1 sont immobiles, mais ils peuvent se retrouner.

  Mercenaire(float tx, float ty, float tdw, int type) {
    // Dimension de la hitbox de l'ennemi.
    w = 35; // épaisseur
    h = 120; // largeur
    // Placement
    x = tx;
    y = ty-h/2;
    // Limites des déplacements.
    l1 = x-tdw/2;
    l2 = x+tdw/2;
    // Alignement initial.
    aligneDroite = random(0, 2) > 1 ? true : false;
    // Le type de mercenaire.
    this.type = type;

    // Chargement des animations.
    // Déplacements.
    spriteCourse = new Sprite(x, y);
    spriteCourse.vitesseAnimation = 45;
    spriteCourse.loop = true;
    spriteCourse.anime = true;

    //Attaque corps à corps.
    spriteAttaqueCorps = new Sprite(x, y);
    spriteAttaqueCorps.vitesseAnimation = 32;

    //Attaque au pistolet.
    spriteAttaquePistolet = new Sprite(x, y);
    spriteAttaquePistolet.vitesseAnimation = 45;

    //Immobilité
    spriteImmobile = new Sprite(x, y);
    spriteImmobile.vitesseAnimation = 45;
    spriteImmobile.loop = true;
    spriteImmobile.anime = true;

    // On charge les ressources nécessaires.
    if (type == 3) {
      spriteCourse.chargeAnimation("Mercenaire3/Course/", 16, 4);
      spriteAttaqueCorps.chargeAnimation("Mercenaire3/Attaque/", 16, 4);
    } else if (type == 1) {
      spriteAttaquePistolet.chargeAnimation("Mercenaire1/Tire/", 8, 4);
      spriteImmobile.chargeAnimation("Mercenaire1/Immobile/", 16, 4);
    } else if (type == 2) {
      spriteCourse.chargeAnimation("Mercenaire2/Course/", 16, 4);
      spriteAttaquePistolet.chargeAnimation("Mercenaire2/Tire/", 8, 4);
      spriteImmobile.chargeAnimation("Mercenaire2/Immobile/", 16, 4);
    }
    if (type != 3) {
      loadingRessource = "loading pistol.mp3";
      sonAttaque = new SoundFile(LeBouchonOr.this, "pistol.mp3");
      loadingProgress--;
    } else {
      loadingRessource = "loading swish_2.mp3";
      sonAttaque = new SoundFile(LeBouchonOr.this, "swish_2.mp3");
      loadingProgress--;
    }
    loadingRessource = "loading mort_mercenaire.wav";
    sonMeurt = new SoundFile(LeBouchonOr.this, "mort_mercenaire.wav");
    loadingProgress--;

    horlogeAttaqueCorps = new Horloge(1000); // Attente d'1 seconde.
    horlogeSeRetourner = new Horloge(4000); // Attente de 4 secondes
  }


  // Gestion de la logique.
  public void actualiser() {

    // Effectivement quand on est mort on ne peut rien faire...
    if (vie > 0) {

      // Si le joueur frappe et que l'ennemis est dans la hitbox de touche.
      if (joueur.spriteFrappe.anime) { 
        boolean collision;
        // La hitbox du joueur est orientée.
        if (joueur.aligneDroite)
          collision = collisionRectangles(joueur.x+joueur.w, joueur.y, joueur.w*3, joueur.h, x, y, w, h);
        else
          collision = collisionRectangles(joueur.x-joueur.w, joueur.y, joueur.w*3, joueur.h, x, y, w, h);
        // On vérifie que le joueur ne puisse pas "mitrailler l'ennemi".
        if (collision && !estBlesse) {
          vie -=(int) (PApplet.parseFloat(joueur.degats*joueur.level) * 2.0f/PApplet.parseFloat(level)); // On perd de la vie
          estBlesse = true;
          if (vie <= 0) { // Si on est mort alors le joueur gagne de l'xp.
            joueur.gagneXp(level);
            sonMeurt.stop();
            sonMeurt.play();
          }
        }
      } else {
        estBlesse = false;
      }

      //Si le joueur lui tire dessus:
      if (joueur.aTire && !joueur.ennemiTouche) {
        boolean collision = collisionRectangles(joueur.balleX, joueur.balleY, joueur.balleW, joueur.balleH, x, y, w, h);
        if (collision) {
          vie -=(int) (PApplet.parseFloat(joueur.degats*joueur.level) * 2.0f/PApplet.parseFloat(level)); // On perd de la vie
          joueur.ennemiTouche = true;
          if (vie <= 0) { // Si on est mort alors le joueur gagne de l'xp.
            joueur.gagneXp(level);
            sonMeurt.stop();
            sonMeurt.play();
          }
        }
      }


      // Seul les mercenaires de type 2 et 3 sont capables de se déplacer.
      if (type != 1) {
        // Il faut que, le joueur soir dans le zone de détection, que l'ennemis ne soit plus en train de viser ou qu'il ne soit plus en train de tirer.
        if (horlogeAttaqueCorps.tempsEcoule && !tire) {
          // On avance dans la même direction que l'alignement de du sprite.
          if (aligneDroite) {
            x += vitesseDeplacement;
          } else {
            x -= vitesseDeplacement;
          }

          // Si on arrive aux limites, on revient sur ses pas.
          if (x < l1) {
            aligneDroite = true;
            x = l1;
          } else if (x > l2) {
            aligneDroite = false;
            x = l2;
          }
        }
      } 
      // Ennemi de type 1
      else {
        // L'ennemi de type 1 se retourne toutes les 4 secondes.
        if (horlogeSeRetourner.tempsEcoule && !tire) {
          aligneDroite = !aligneDroite; // On se retourne.
          horlogeSeRetourner.lancer();
        }
      }


      // Attaque corps à corps/dégats infligés au contact uniquement pour l'ennemi 3.
      if (type == 3) {
        boolean collisionJoueur = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, x, y, w, h);
        // Si il y a eu une collision avec le joueur et que l'ennemi n'est pas "en cours" d'attaque, on blesse le joueur.
        if (collisionJoueur && horlogeAttaqueCorps.tempsEcoule) {
          float direction = (joueur.x-x)/abs(joueur.x-x);
          float repousse = 200 * direction;
          aligneDroite = (direction > 0);
          joueur.degatsRecu((int) (degats*level/1.5f), repousse);
          sonAttaque.stop();
          sonAttaque.play();
          spriteAttaqueCorps.reinitialiser(); // On relance l'animation d'attaque. N'est effectif que si l'ennemi est de type 3, si non le sprite n'est pas affiché.  
          horlogeAttaqueCorps.lancer(); // On lance l'attente avant d'effectuer d'autres actions.
        }
      } else {
        // Le joueur est détecté par le tireur.
        // Il faut que, le joueur soir dans le zone de détection, que l'ennemis ne soit plus en train de viser ou qu'il ne soit plus en train de tirer.
        boolean LigneDeMire = y < joueur.y+joueur.h/2 && y > joueur.y-joueur.h/2;
        if (LigneDeMire && !tire) {
          if (aligneDroite && joueur.x-x >= 0 && joueur.x-x < detection) {
            tire = true;
            balleX = x;
            balleCollision = false;
            sonAttaque.stop();
            sonAttaque.play();
            spriteAttaquePistolet.reinitialiser();
          } else if (!aligneDroite && x-joueur.x >= 0 && x-joueur.x < detection) {
            tire = true;
            balleX = x;
            balleCollision = false;
            sonAttaque.stop();
            sonAttaque.play();
            spriteAttaquePistolet.reinitialiser();
          }
        }

        // On actialise les positions de la balle.
        if (tire) {
          if (aligneDroite)
            balleX += balleVitesse;
          else
            balleX -= balleVitesse;

          if (abs(balleX-x) > balleMaxDeplacement) { // On peut re tirer.
            tire = false;
            balleCollision = true;
          }
        }

        // Si il y a eu une collision avec le joueur, on lui retire de la vie et on masque la balle et on désactives les collisions.
        if (!balleCollision && type != 3) {
          boolean toucheJoueur = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, balleX, y, balleW, balleH);
          if (toucheJoueur) {
            balleCollision = true;
            float direction = (joueur.x-balleX)/abs(joueur.x-balleX);
            float repousse = 200 * direction;
            joueur.degatsRecu((int) (degats*level/1.5f), repousse);
          }
        }
      }

      // On actualise les chronos.
      horlogeAttaqueCorps.actualiser();
      horlogeSeRetourner.actualiser();
    }
  }

  // Gestion de l'affichage.
  public void afficher() {

    if (vie > 0) {
      if (aligneDroite) {
        spriteCourse.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
        spriteAttaqueCorps.mirroir = false;
        spriteAttaquePistolet.mirroir = false;
        spriteImmobile.mirroir = false;
      } else {
        spriteCourse.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
        spriteAttaqueCorps.mirroir = true;
        spriteAttaquePistolet.mirroir = true;
        spriteImmobile.mirroir = true;
      }

      // Différents affichages en fonction du type.
      // Si on est en attaque.
      if (!horlogeAttaqueCorps.tempsEcoule && type == 3) {
        spriteAttaqueCorps.changeCoordonnee(x, y);
        spriteAttaqueCorps.afficher();
      } 
      // si non il se peut que l'on tire.
      else if (type != 3 && tire) {
        spriteAttaquePistolet.changeCoordonnee(x, y);
        spriteAttaquePistolet.afficher();
      }
      // Si non on est en déplacement. Uniquement pour les ennemis 2 et 3.
      else if (type != 1) {
        spriteCourse.changeCoordonnee(x, y);
        spriteCourse.afficher();
      } else if (type != 3) { // Si non, on est immobile.
        spriteImmobile.changeCoordonnee(x, y);
        spriteImmobile.afficher();
      }

      //Barre de vie.
      cv.noStroke();
      //fond de la barre de vie.
      cv.fill(50, 50, 50);
      cv.rectMode(CORNER);
      cv.rect(x-50, y-75, 100, 4);

      // Barre de vie.
      cv.fill(255, 0, 0);
      cv.rect(x-50, y-75, vie, 4);

      //Affichage du niveau
      cv.textSize(14);
      cv.textAlign(CENTER, TOP);
      cv.fill(0);
      cv.text("lvl "+str(level), x+1, y-74);
      cv.fill(255);
      cv.text("lvl "+str(level), x, y-75);

      // Affichage de la balle.
      if (tire && !balleCollision) {
        cv.rectMode(CENTER);
        cv.fill(255, 255, 0);
        cv.noStroke();
        cv.rect(balleX, y, balleW, balleH);
      }

      //***************** DEBUGAGE ************ //
      if (debug) {
        // Affichage de la hitbox.
        cv.noFill();
        cv.stroke(255, 0, 0);
        cv.rectMode(CENTER);
        cv.rect(x, y, w, h);
        // Affichage de la zone de déplacement.
        cv.stroke(0, 0, 255);
        cv.line(l1, y, l2, y);
        //Affichage du rayon de détection.
        cv.stroke(255, 0, 0);
        float dx = aligneDroite ? detection : - detection;
        cv.line(x, y-h/3, x+dx, y-h/3);
      }
    }
  }
  public void reinitialiser() {
    vie = 100; // Quantité de vie.
    estBlesse = false; // Permet d'eviter que le joueur le tue instantanément.
    balleX = 0;
    tire = false; // Permet de figer l'ennemi.
    balleCollision = false; // Permet de cacher la balle et d'ignorer les collisions.
  }
}
class GameOver {

  SoundFile musique;
  int transparence = 255;

  GameOver() {
    loadingRessource = "loading fin.mp3";
    musique = new SoundFile(LeBouchonOr.this, "fin.mp3");
    loadingProgress--;
  }

  public void afficher() {
    if (transparence > 0)
      transparence -= 1;
    cv.background(50);
    cv.textSize(50);
    cv.textAlign(CENTER, CENTER);
    cv.fill(255, 0, 0);
    cv.text("Vous avez perdu.", cv.width/2, cv.height/2);

    if (transparence <=0 ) {
      cv.textSize(24);
      cv.fill(255);
      cv.text("Touchez l'ecran pour revenir au menu principal.", cv.width/2, 3*cv.height/4);
    }

    // Si on est encore en transition (fade out) alors c'est que la transparence est > 0.
    if (transparence > 0) {
      // On affiche un rectangle noir d'opacité "transition" pour créer un effet de "fade out".
      cv.noStroke();
      cv.fill(0, 0, 0, transparence);
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    }
  }


  public void keyPressed() {
    if (key == ' ') {
      pause();
      //On revient au menu principal
      infoChargeNiveau();
      niveau = 0;
      menuPrincipal.relancer();
    }
  }

  public void mousePressed() {
    if (transparence <=0) {
      pause();
      //On revient au menu principal
      infoChargeNiveau();
      niveau = 0;
      menuPrincipal.relancer();
    }
  }

  public void relancer() {
    invalideBouton = true;
    musique.loop();
    transparence = 255;
  }

  public void pause() {
    musique.stop();
  }
}
class Horloge {
  private int tempsDebut;
  int temps;
  int compteur = 0;
  boolean tempsEcoule = true;

  Horloge(int temps) {
    this.temps = temps;
  }

  public void actualiser() {
    if (!tempsEcoule) {
      compteur = millis() - tempsDebut;
      if (compteur > temps) {
        tempsEcoule = true;
        compteur = temps;
      }
    }
  }

  public void lancer() {
    tempsEcoule = false;
    tempsDebut = millis();
    compteur = 0;
  }
}

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
    applaudissements.amp(0.5f);
    loadingRessource = "loading NiveauTuto/battleThemeA.mp3";
    action = new SoundFile(LeBouchonOr.this, "NiveauTuto/battleThemeA.mp3");
    loadingProgress--;
    action.amp(0.5f);

    // Rondin de bois
    murs.add(new Mur(765, 560.25f, 50));
    murs.add(new Mur(879, 560.25f, 50));
    plateformes.add(new Plateforme(822, 534.5f, 116, true));

    // Obstacle 1
    murs.add(new Mur(1313, 510, 151));
    murs.add(new Mur(1604, 217.4f, 434.8f));
    plateformes.add(new Plateforme(1457, 434, 290, false));

    // Boite 1
    murs.add(new Mur(2821, 567.5f, 39));
    murs.add(new Mur(2952, 567.5f, 39));
    plateformes.add(new Plateforme(2887.6f, 547.2f, 132, true));

    //Boite 2
    murs.add(new Mur(3341.2f, 531.3f, 110));
    murs.add(new Mur(3475.6f, 531.3f, 110));
    plateformes.add(new Plateforme(3408.415f, 475.71f, 135, true));

    // Ennemis
    Mercenaire m = new Mercenaire(3149, 576, 390.5f, 3);
    m.level = 2;
    ennemis.add(m);
    ennemis.add(new Mercenaire(3394, 477, 0, 1));
    ennemis.add(new Mercenaire(2658.35f, 576, 328.7f, 2));

    bonus = new PainBouchon(2879.5f, 539.4f);

    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  public void actualiser() {
    if (!enIntroduction && fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !changeNiveauVille) {
      invalideBouton = false;
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
    } else {
      invalideBouton = true;
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

  public void actualiseDialogues() {
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
  }

  public void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !enIntroduction) {
      joueur.keyPressed();
    }
    // On réaffiche les dialogues.
    if (!lanceDialogue1 && !lanceDialogue2 && (finDialogue1 || finDialogue2) && !changeNiveauVille && !enIntroduction) {
      char k = Character.toUpperCase((char) key);
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 1961, 506.8f, 200, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3549.9f, 506.8f, 200, 235);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3778, 570.5f, 128.85f, 118.9f);
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

  public void touchPressed(int idBouton) {
    if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !enIntroduction) {
      joueur.touchPressed(idBouton);
    }
    // On réaffiche les dialogues.
    if (!lanceDialogue1 && !lanceDialogue2 &&(finDialogue1 || finDialogue2) && !changeNiveauVille && !enIntroduction) {
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 1961, 506.8f, 200, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3549.9f, 506.8f, 200, 235);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3778, 570.5f, 128.85f, 118.9f);
      if (idBouton == 6 && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 2;
      } else if (idBouton == 6 && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 4;
      } else if (idBouton == 6 && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      }
    }
  }

  public void keyReleased() {
    if (!enIntroduction && fade.tempsEcoule) {
      joueur.keyReleased();
    }
  }

  public void touchReleased(int idBouton) {
    if (!enIntroduction && fade.tempsEcoule) {
      joueur.touchReleased(idBouton);
    }
  }

  public void afficher() {
    //Affichage des dialogues d'intro.
    if (enIntroduction) {
      cv.background(50);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 33);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 32);
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


      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 1961, 506.8f, 200, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3549.9f, 506.8f, 200, 235);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3778, 570.5f, 128.85f, 118.9f);

      if (declancheurDialogue1) {
        cv.image(infoDialogue, 1925, 346);
      } else if (declancheurDialogue2) {
        cv.image(infoDialogue, 3514.7f, 327.3f);
      } else if (versNiveauVille) {
        cv.image(infoDialogue, 3727.6f, 428);
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
        cv.rect(cv.width/2, 45, 500, 32);
        cv.textSize(24);
        cv.textAlign(CENTER, CENTER);
        cv.fill(0);
        cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
        cv.fill(255);
        cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
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

  public void pause() {
    applaudissements.stop();
    musiqueIntro.stop();
    action.stop();
  }

  public void relancer() {
    fade.lancer();
    musiqueIntro.loop();
    reinitialiser();
    joueur.initNiveau(150, 507);
  }

  public void reinitialiser() {
    enIntroduction = true;
    numDialogue = 0; // Position dans les dialogues.
    finDialogue1 = false;
    lanceDialogue1 = false;
    finDialogue2 = false;
    lanceDialogue2 = false;
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    bonus.reinitialiser();
    for (Mercenaire m : ennemis) {
      m.reinitialiser();
    }
  }
}
// jamais utilisée directement.
class Item {
  boolean ramasse = false;
  Sprite sprite;
  float x;
  float y;
  float dy = 10;
  float oldy = 1;
  float vy = 0.5f;
  SoundFile bruit;

  Item(float tx, float ty) {
    x = tx;
    y = ty;
    oldy = y;
    sprite = new Sprite(x, y);
    loadingRessource = "loading item.mp3";
    bruit = new SoundFile(LeBouchonOr.this, "item.mp3");
    loadingProgress--;
  }

  public void actualiser() {
    if (!ramasse) {
      // Animation
      y += vy;
      if (y < oldy-dy) {
        y = oldy-dy;
        vy *= -1;
      } else if (y > oldy) {
        y = oldy;
        vy *= -1;
      }
      //Collision avec le joueur
      boolean collision = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, x, y, sprite.width(), sprite.height());
      if (collision) {
        collisionJoueur();
      }
    }
  }

  public void afficher() {
    if (!ramasse) {
      sprite.changeCoordonnee(x, y);
      sprite.afficher();
    }
  }

  public void collisionJoueur() {
  }

  public void reinitialiser() {
    ramasse = false;
  }
}

class PainBouchon extends Item {
  PainBouchon(float tx, float ty) {
    super(tx, ty);
    sprite.chargeImage("pain_bouchon.png");
  }

  // A ecraser
  public void collisionJoueur() {
    if (joueur.vie < 100) {
      ramasse = true;
      bruit.stop();
      bruit.play();
      joueur.vie = 100;
    }
  }
}

class SavateMagique extends Item {
  SavateMagique(float tx, float ty) {
    super(tx, ty);
    sprite.chargeImage("savate.png");
  }

  // A ecraser
  public void collisionJoueur() {
    ramasse = true;
    bruit.play();
    joueur.superSaut = true;
    niveauErmitage.dialogueSavate = true;
  }
}

class Combinaison extends Item {
  Combinaison(float tx, float ty) {
    super(tx, ty);
    sprite.chargeImage("combinaison.png");
  }

  // A ecraser
  public void collisionJoueur() {
    ramasse = true;
    bruit.play();
    joueur.invulnerableLave = true;
    niveauVille.dialogueCombinaison = true;
  }
}
class Joueur {
  boolean invulnerableLave = false; // Pour pouvoir avancer dans le jeu.
  boolean superSaut = false; // Pour pouvoir avancer dans le jeu.
  int compteurTemps = 0; // Permet de créer des évennements dans le temps.
  float x, y; // Positions du joueur
  float vx = 0; // Vitesse du joueur sur l'axe x (en pixels par secondes)
  float vy = 0; // Vitesse du joueur sur l'axe y (en pixels par secondes)
  float friction = 0.80f; // Coefficient.
  float forceSaut = 1500; // En pixel par secondes
  float vitesseDeplacement = 400;  // En pixel par secondes
  float gravite = 4000; // En pixels par secondes carrés
  int xp = 0; // Quantité d'xp récupérée.
  int xpMax = 7; // Nombre d'xp pour monter de niveau.
  int level = 1; // Le niveau du personnage, ses dégats y sont proportionnels. Tout comme sa résistance.
  int levelMax = 10; // Niveau maximum du joueur.
  int vie = 100; // Le nombre de points de vie.
  int degats = 10; // Dégats de base au corps à corps.

  Sprite spriteCourse; // Animation de déplacement
  Sprite spriteImmobile; // Animation par défaut
  Sprite spriteTombe; // Animation lorsque le joueur retombe (une seule image pour le moment)
  Sprite spriteSaut; // Animation lorsque le joueur saute (une seule image pour le moment)
  Sprite spriteFrappe; // Animation lorsque le joueur frappe.
  Sprite spriteTire; // Animation lorsque le joueur tire;

  // Positions de la balle.
  float balleXInitiale;
  float balleX;
  float balleY;
  float balleMaxDistance = 300;
  float balleMaxDistanceWait = balleMaxDistance*2.7f;
  float balleVitesse = 10;
  int balleDirection = 1; // Direction de la balle lorsqu'elle a été tirée.

  // Dimension de la balle.
  float balleW = 16;
  float balleH = 8;

  boolean aTire = false; // Permet de savoir quand pouvoir re tirer.
  boolean ennemiTouche = false; // Permet de désactiver le collision avec la balle et son affiche si elle a touchée un ennemi.

  SoundFile sonSaut;  // Son lorsque le joueur saute.
  SoundFile sonFrappe; // Son lorsque le joueur frappe.
  SoundFile sonBlesse; // Son lorsque le joueur est blessé.
  SoundFile sonTir; // Son lorsque le joueur tire.

  boolean aligneDroite = true; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.

  // Dimension de la hitbox du joueur
  int w = 35; // épaisseur
  int h = 120; // largeur

  boolean surPlateforme = false; // Permet de savoir si le joueur ne doit plus tomber car il est sur une plateforme.

  // Les différents états du joueur
  boolean enDeplacement = false;
  boolean enAttaqueProche = false;
  boolean enAttaqueLongue = false;

  // Permet d'indiquer au système de collision que l'on veut descendre de la plateforme en passant au travers.
  boolean descendPlateforme = false;

  // Permet de corriger un bug de dépalcement lorsque le joueur a été poussé.
  boolean estPousse = false; 

  Horloge horlogeBlesse; // Lorsque le joueur est blessé il est invulnérable pendant un court instant.

  // Initialisation
  Joueur(float x, float y) {

    // On charge toutes les animations et on les configures :
    spriteCourse = new Sprite(x, y);
    spriteCourse.vitesseAnimation = 32; // 32 ms entre chaques images
    // On charge les images de l'animation, ici il y en a 16 et le nom est codé avec 4 entiers: 0001, ..., 0016.
    // Voir la classe sprite.
    spriteCourse.chargeAnimation("Martin/Course/", 16, 4);
    spriteCourse.loop = true; // L' animation recommence perpétuellement.
    spriteCourse.anime = true; // On lance l'animation.

    spriteImmobile = new Sprite(x, y);
    spriteImmobile.vitesseAnimation = 40;
    spriteImmobile.chargeAnimation("Martin/Immobile/", 16, 4);
    spriteImmobile.loop = true;
    spriteImmobile.anime = true;

    spriteFrappe = new Sprite(x, y);
    spriteFrappe.chargeAnimation("Martin/Frappe/", 8, 4);
    spriteFrappe.vitesseAnimation = 45;

    spriteTombe = new Sprite(x, y);
    spriteTombe.chargeImage("Martin/tombe.png");

    spriteSaut = new Sprite(x, y);
    spriteSaut.chargeImage("Martin/saut.png");

    spriteTire = new Sprite(x, y);
    spriteTire.chargeAnimation("Martin/Tire/", 8, 4);
    spriteTire.vitesseAnimation = 45;

    loadingRessource = "loading Martin/saut.mp3";
    sonSaut = new SoundFile(LeBouchonOr.this, "Martin/saut.mp3");
    loadingProgress--;
    loadingRessource = "loading Martin/frappe.mp3";
    sonFrappe = new SoundFile(LeBouchonOr.this, "Martin/frappe.mp3");
    loadingProgress--;
    loadingRessource = "loading Martin/hit.mp3";
    sonBlesse = new SoundFile(LeBouchonOr.this, "Martin/hit.mp3");
    loadingProgress--;
    loadingRessource = "loading Martin/tir.mp3";
    sonTir = new SoundFile(LeBouchonOr.this, "Martin/tir.mp3");
    loadingProgress--;

    horlogeBlesse = new Horloge(1500); // On défini le chrono à 1 secondes.
  }

  // Gestion de la logique du joueur.
  public void actualiser() {
    // Intégration numérique du mouvement avec la méthode d'euler.
    if (!surPlateforme) {
      // Intégration numérique de la vitesse.
      vy += gravite*dt; // On applique la gravité si le joueur n'est pas sur une plateforme.
    }

    // Intégration numérique des coordonnées.
    y += vy*dt;
    x += vx*dt;

    // Si on est sur une plateforme et que le jouer ne doit plus se déplacer, 
    // on ralenti son mouvement horizontal pour le rendre immobile.
    // Cela permet de donner une inertie au joueur.
    if (surPlateforme && !enDeplacement) {
      vx *= friction;
    }


    if (aTire) {
      balleX += balleVitesse * balleDirection;
      if (abs(balleXInitiale-balleX) > balleMaxDistance) {
        ennemiTouche = true;
      }
      if (abs(balleXInitiale-balleX) > balleMaxDistanceWait) {
        ennemiTouche = true;
        aTire = false;
      }
    }

    // On actualise les compteurs.
    horlogeBlesse.actualiser();
  }

  // Gestion de l'affichage du joueur.
  public void afficher() {

    if (aligneDroite) {
      spriteCourse.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = false; // Même remarque ici
      spriteSaut.mirroir = false;
      spriteTombe.mirroir = false;
      spriteFrappe.mirroir = false;
      spriteTire.mirroir = false;
    } else {
      spriteCourse.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = true; // Même remarque ici;
      spriteSaut.mirroir = true;
      spriteTombe.mirroir = true;
      spriteFrappe.mirroir = true;
      spriteTire.mirroir = true;
    }

    // On clignote en rouge quand on est blessé.
    if (!horlogeBlesse.tempsEcoule) {
      float valeur = horlogeBlesse.compteur % 255;
      cv.tint(255, 255-valeur, 255-valeur);
    }

    // Chute libre.
    //Le joueur frappe.
    if (spriteFrappe.anime) {
      spriteFrappe.changeCoordonnee(x, y);
      spriteFrappe.afficher();
    } 
    // Le joueur Tire.
    else if (spriteTire.anime) {
      spriteTire.changeCoordonnee(x, y);
      spriteTire.afficher();
    } else if (vy > 0) {
      // On actualise les coordonnées du sprite sur celle du joueur.
      // Cela permet de séparer l'actualisation de la physique et l'actualisation de l'affichage.
      // La class Sprite n'est ni plus ni moins un sytème d'animation/affichage d'images,
      // ce qui n'a rien avoir avec la physique du jeu.
      spriteTombe.changeCoordonnee(x, y);
      // On affiche l'animation de fin de saut.
      spriteTombe.afficher();
    }
    // En montée.
    else if (vy < 0) {
      spriteSaut.changeCoordonnee(x, y);
      // On affiche l'animation de saut.
      spriteSaut.afficher();
    } 
    // Lorsque le joueur court.
    else if (enDeplacement) {
      spriteCourse.changeCoordonnee(x, y);
      // On affiche l'animation de course
      spriteCourse.afficher();
    }
    // Lorsque le joueur n'effectue aucune action.
    else {
      spriteImmobile.changeCoordonnee(x, y);
      // On affiche l'animation par défaut
      spriteImmobile.afficher();
    }
    cv.tint(255, 255, 255);

    // Affichage de la balle.
    if (aTire && !ennemiTouche) {
      cv.rectMode(CENTER);
      cv.fill(100, 255, 0);
      cv.noStroke();
      cv.rect(balleX, balleY, balleW, balleH);
    }

    //************** DEBUGAGE ************//
    if (debug) {
      // Affichage de la hitbox du joueur
      cv.noFill();
      cv.stroke(255, 0, 0);
      cv.rectMode(CENTER);
      cv.rect(x, y, w, h);
      if (spriteFrappe.anime) {
        //Hitbox de la frappe.
        cv.fill(255, 0, 0, 100);
        cv.stroke(255, 0, 0);
        cv.rectMode(CENTER);
        if (aligneDroite)
          cv.rect(x+w, y, 3*w, h);
        else
          cv.rect(x-w, y, 3*w, h);
      }
    }
  }

  // Permet de gérer les actions du joueur en fonction de la touche appuyée.
  public void keyPressed() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Gestion du saut si le joueur se trouve sur une plateforme.
    if (k == 'Z' && surPlateforme) {
      // On applique une force verticale pour propulser le joueur en l'air.
      if (superSaut)
        vy = -forceSaut*1.25f; 
      else
        vy = -forceSaut;

      surPlateforme = false; // On quite la plateforme.
      sonSaut.stop();
      sonSaut.play(); // On lance le son du saut.
    } 
    // Gestion du déplacement vers la droite. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (k == 'D' && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer.
      vx = vitesseDeplacement; // On se déplace à une vitesse constante vers la droite.
      aligneDroite = true; // Le joueur est tourné vers la droite.
    } 
    // Gestion du déplacment vers la gauche. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (k == 'Q' && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer. 
      vx = -vitesseDeplacement; // On se déplace à une vitesse constante vers la gauche.
      aligneDroite = false; // Le joueur est tourné vers la gauche.
    } 
    // Le joueur veut descendre de la plateforme.
    else if (k == 'S') {
      descendPlateforme = true;
    } else if (k == 'K' && !spriteFrappe.anime && !estPousse) {
      //Le joueur frappe.
      sonFrappe.stop();
      sonFrappe.play();
      spriteFrappe.reinitialiser();
    } else if (k == 'L' && !spriteTire.anime && !aTire) {
      balleXInitiale = x;
      balleDirection = aligneDroite ? 1 : -1;
      balleX = x;
      balleY = y;
      aTire = true;
      ennemiTouche = false;
      sonTir.stop();
      sonTir.play();
      spriteTire.reinitialiser();
    }
    // ************************************ DEBUGAGE **************************//
    else if (k == 'A' && debug) {
      joueur.vy = -forceSaut/2;
      joueur.vx = aligneDroite ? -vitesseDeplacement : vitesseDeplacement; 
      surPlateforme = false;
    }
  }

  public void touchPressed(int idBouton) {
    // Gestion du saut si le joueur se trouve sur une plateforme.
    if (idBouton == 2 && surPlateforme) {
      // On applique une force verticale pour propulser le joueur en l'air.
      if (superSaut)
        vy = -forceSaut*1.25f; 
      else
        vy = -forceSaut;

      surPlateforme = false; // On quite la plateforme.
      sonSaut.stop();
      sonSaut.play(); // On lance le son du saut.
    } 
    // Gestion du déplacement vers la droite. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (idBouton == 1 && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer.
      vx = vitesseDeplacement; // On se déplace à une vitesse constante vers la droite.
      aligneDroite = true; // Le joueur est tourné vers la droite.
    } 
    // Gestion du déplacment vers la gauche. Si le joueur a été poussé, on ne peut pas modifier sa trajectoire.
    else if (idBouton == 0 && !estPousse) {
      enDeplacement = true; // On est en train de se déplacer. 
      vx = -vitesseDeplacement; // On se déplace à une vitesse constante vers la gauche.
      aligneDroite = false; // Le joueur est tourné vers la gauche.
    } 
    // Le joueur veut descendre de la plateforme.
    else if (idBouton == 3) {
      descendPlateforme = true;
    } else if (idBouton == 4 && !spriteFrappe.anime && !estPousse) {
      //Le joueur frappe.
      sonFrappe.stop();
      sonFrappe.play();
      spriteFrappe.reinitialiser();
    } else if (idBouton == 5 && !spriteTire.anime && !aTire) {
      balleXInitiale = x;
      balleDirection = aligneDroite ? 1 : -1;
      balleX = x;
      balleY = y;
      aTire = true;
      ennemiTouche = false;
      sonTir.stop();
      sonTir.play();
      spriteTire.reinitialiser();
    }
  }

  // Permet de gérer les actions du joueur en fonction de la touche relachée.
  public void keyReleased() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Si on arrête le déplacement si on lache les touches pour se déplacer.
    if (k == 'D' || k == 'Q') {
      enDeplacement = false;
    } 
    // Le joueur ne veut plus descendre des plateformes.
    else if (k == 'S') {
      descendPlateforme = false;
    }
  }

  public void touchReleased(int idBouton) {
    // Si on arrête le déplacement si on lache les touches pour se déplacer.
    if (idBouton == 0 || idBouton == 1) {
      enDeplacement = false;
    } 
    // Le joueur ne veut plus descendre des plateformes.
    else if (idBouton == 3) {
      descendPlateforme = false;
    }
  }

  // Le joueur reçoit des dégats.
  public void degatsRecu(int degats, float force) {
    // On reçoit des dégats que si le temps de latence est écoulé.
    if (horlogeBlesse.tempsEcoule) {
      vie -=(int) (PApplet.parseFloat(degats)*1.0f/PApplet.parseFloat(level));
      joueur.vy = -forceSaut/2;
      joueur.vx = force;
      surPlateforme = false;
      horlogeBlesse.lancer(); // On relance le chrono.
      estPousse = true;
      enDeplacement = false;
      sonBlesse.stop();
      sonBlesse.play();
      Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
      vibrer.vibrate(200);
    }
  }

  public void gagneXp(int quantite) {
    xp += quantite;
    if (xp > xpMax) {
      level += xp / xpMax;
      xp = xp  % xpMax;
    }
    if (level > levelMax) {
      level = levelMax;
      xp = xpMax;
    }
  }


  // Permet d'initialiser le joueur dans les niveaux tout en conservant se progression.
  public void initNiveau(float tx, float ty) {
    // On place le joueur.
    x = tx;
    y = ty;

    // Le joueur n'a pas de vitesse initiale.
    vx = 0;
    vy = 0;

    // Le joueur n'a pas encore effectué d'actions.
    surPlateforme = false;
    enDeplacement = false;
    enAttaqueProche = false;
    enAttaqueLongue = false;
    estPousse = false;
    horlogeBlesse.tempsEcoule = true;
    sonSaut.stop();
    sonTir.stop();
    sonFrappe.stop();
  }

  public void reinitialiser() {
    invulnerableLave = false; // Pour pouvoir avancer dans le jeu.
    superSaut = false; // Pour pouvoir avancer dans le jeu.
    compteurTemps = 0; // Permet de créer des évennements dans le temps.
    xp = 0; // Quantité d'xp récupérée.
    level = 1; // Le niveau du personnage, ses dégats y sont proportionnels. Tout comme sa résistance.
    vie = 100; // Le nombre de points de vie.
    balleMaxDistance = 300;
    aTire = false; // Permet de savoir quand pouvoir re tirer.
    ennemiTouche = false; // Permet de désactiver le collision avec la balle et son affiche si elle a touchée un ennemi.
    aligneDroite = true; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.
    surPlateforme = false; // Permet de savoir si le joueur ne doit plus tomber car il est sur une plateforme.
    // Les différents états du joueur
    enDeplacement = false;
    enAttaqueProche = false;
    enAttaqueLongue = false;
    // Permet d'indiquer au système de collision que l'on veut descendre de la plateforme en passant au travers.
    descendPlateforme = false;
    // Permet de corriger un bug de dépalcement lorsque le joueur a été poussé.
    estPousse = false;
  }
}
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
  public void actualiser() {
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
  public void afficher() {
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
  public void afficheBouton(PImage bouton, int x, int y) {
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
  public void mousePressed() {
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
  public void pause() {
    musique.stop(); // On arrête la muique de fond.
  }

  // Lorsque l'on revient au menu principal, on s'assure que tout soit réinitialisé (cela permet d'éviter de réinstancier le menu).
  public void relancer() {
    invalideBouton = true;
    transparence = 255; // On réinitialise la transition "fade out".
    musique.loop(); // On relance la musique.
  }
}
class Mur {
  float x, y; // Positions du mur.
  float h; // Dimention du mur.


  // Remarque: pas besoin d'avoir une épaisseur en x pour le mur, pour des raisons d'optimisation et de bon sens,
  // on a besoin que de la position x du mur pour tester si le joueur se trouve a gauche ou a droite,
  // ce qui revient à considérer qu'une seule dimention en plus : la hauteur du mur.

  // Initialisation
  Mur(float tx, float ty, float th) {
    x = tx;
    y = ty;
    h = th;
  }

  // Permet de savoir si la hitbox du joueur et le mur sont superposées.
  public boolean collisionPotentielle() {
    boolean faceHaut = joueur.y-joueur.h/2 <= y+h/2 && joueur.y-joueur.h/2 >= y-h/2;
    boolean faceBas= joueur.y+joueur.h/2 <= y+h/2 && joueur.y+joueur.h/2 >= y-h/2;
    return faceHaut || faceBas;
  }
}
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
    plateformes.add(new Plateforme(325.5f, 193, 246, false));
    plateformes.add(new Plateforme(966, 410, 398, false));
    plateformes.add(new Plateforme(1006, 193, 246, false));
    boss = new Sprite(1038, 382.5f);
    boss.chargeImage("NiveauBoss/boss.png");
    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  public void actualiser() {

    if (!intro && !dialogue1 && !dialogue2 && !dialogue3 && !gagne && fade.tempsEcoule && !dialogue4) {
      invalideBouton = false;
      if (vie <= 50 && !phase2) {
        phase2 = true;
        musiquePhase1.stop();
        musiquePhase2.loop();
        vx = 6.5f;
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
      if (joueur.aTire && !joueur.ennemiTouche) {
        boolean collision = collisionRectangles(joueur.balleX, joueur.balleY, joueur.balleW, joueur.balleH, boss.x, boss.y, w, h);
        if (collision && !joueur.ennemiTouche) {
          vie -= 5; // On perd de la vie
          joueur.ennemiTouche = true;
          if (vie <= 0) { // Si on est mort alors le joueur gagne de l'xp.
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

      if (vie <=0) {
        gagne = true;
        musiquePhase2.stop();
        meurt.stop();
        meurt.play();
        fade.lancer();
      }
    } else {
      invalideBouton = true;
    }

    if (fade.tempsEcoule && gagne) {
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

  public void afficher() {
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
    } else
      infoChargeNiveau(); // On charge le niveau;
    if (dialogue4 || intro)
      cv.background(50);

    if (intro || dialogue1 || dialogue2 || dialogue3 || dialogue4) {
      cv.fill(50);
      cv.noStroke();
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 45, 500, 32);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
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

    if (!intro && !dialogue1 && !dialogue2 && !dialogue3 && !dialogue4 && !gagne) {
      hud.afficher();
      //Vie du de thibault.
      cv.rectMode(CORNER);
      cv.noStroke();
      cv.fill(50);
      cv.rect(0, 675, cv.width, 38);
      cv.fill(255, 0, 0);
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

  public void actualiseDialogues() {
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
    } else if (dialogue4) {
      dialogue4 = false;
      musiqueIntro.stop();
      niveau = 1;
      infoChargeNiveau();
      credits.relancer();
    }
  }

  public void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (!dialogue1 && !intro && !dialogue2 && !dialogue3 && !gagne && fade.tempsEcoule) {
      joueur.keyPressed();
    }
  }

  public void touchPressed(int idBouton) {
    if (!dialogue1 && !intro && !dialogue2 && !dialogue3 && !gagne && fade.tempsEcoule) {
      joueur.touchPressed(idBouton);
    }
  }

  // Gestion des touches relâchées.
  public void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  public void touchReleased(int idBouton) {
    // Gestion des touches relâchées pour le joueur.
    joueur.touchReleased(idBouton);
  }

  public void pause() {
    musiqueIntro.stop();
    musiquePhase1.stop();
    musiquePhase2.stop();
  }

  public void relancer() {
    reinitialiser();
    musiqueIntro.loop();
    joueur.initNiveau(197, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    joueur.aligneDroite = true;
    joueur.balleMaxDistance = 720;
    joueur.vie = 100;
  }

  public void reinitialiser() {
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
class NiveauErmitage {

  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  Item bonus1;
  Item bonus2;
  Item savate;


  PImage fond; // Image de fond.
  PImage infoSavate; // Description des savates magiques.
  PImage imgDialogue1;

  SoundFile musique; // Musique de fond.

  Horloge fade; // Transition vers les niveaux.

  boolean dialogueSavate = false;
  boolean dialogue1 = false;

  boolean changeNiveauVille= false;



  // Initialisation du niveau.
  NiveauErmitage() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();
    loadingRessource = "loading NiveauErmitage/fond.png";
    fond = loadImage("NiveauErmitage/fond.png");
    loadingProgress--;
    loadingRessource = "loading NiveauErmitage/dialogue.png";
    infoSavate = loadImage("NiveauErmitage/dialogue.png");
    loadingProgress--;
    loadingRessource = "loading NiveauErmitage/dialogue2.png";
    imgDialogue1 = loadImage("NiveauErmitage/dialogue2.png");
    loadingProgress--;

    //*************Mise en place des plateformes et murs *****************//
    loadingRessource = "loading NiveauErmitage/musique.mp3";
    musique = new SoundFile(LeBouchonOr.this, "NiveauErmitage/musique.mp3");
    loadingProgress--;
    musique.amp(0.5f);
    plateformes.add(new Plateforme(3060, 382, 210, false)); //P1
    plateformes.add(new Plateforme(2724, 292, 288, false)); //P2
    Mercenaire m2 = new Mercenaire(2724, 292, 288, 3);
    m2.level = 1;
    ennemis.add(m2);
    plateformes.add(new Plateforme(2304.5f, 163, 561.5f, false)); //P3
    plateformes.add(new Plateforme(1785, -29, 552, false)); //P4
    Mercenaire m4 = new Mercenaire(1785, -29, 552, 2);
    m4.level = 4;
    ennemis.add(m4);
    plateformes.add(new Plateforme(1259, -271.5f, 480, false)); //P5
    Mercenaire m5 = new Mercenaire(1259, -271.5f, 480, 2);
    m5.level = 5;
    ennemis.add(m5);
    plateformes.add(new Plateforme(1803.5f, -435, 486, false)); //P6
    Mercenaire m6 = new Mercenaire(1803.5f, -435, 486, 3);
    m6.level = 6;
    ennemis.add(m6);
    plateformes.add(new Plateforme(2538.5f, -270.5f, 481, false)); //P7
    plateformes.add(new Plateforme(607.5f, -153, 485, false)); //P8
    Mercenaire m8 = new Mercenaire(607.5f, -153, 485, 1);
    m8.level = 4;
    ennemis.add(m8);
    plateformes.add(new Plateforme(822.5f, 381.5f, 206, false)); //P9

    Mercenaire m9 = new Mercenaire(2158, 4*cv.height/5, 10, 1);
    m9.level = 1;
    ennemis.add(m9);

    Mercenaire m10 = new Mercenaire(1211, 4*cv.height/5, 549, 2);
    m10.level = 2;
    ennemis.add(m10);

    Mercenaire m11 = new Mercenaire(170, 4*cv.height/5, 10, 1);
    m9.level = 3;
    ennemis.add(m11);

    bonus1 = new PainBouchon(820.25f, 360.5f);
    bonus2 = new PainBouchon(1999.5f, -461.5f);
    savate = new SavateMagique(2541.5f, -327.8f);


    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  public void actualiser() {
    if (!changeNiveauVille && !dialogueSavate && !dialogue1) {
      invalideBouton = false;
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
      trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
      // On actualise les ennemis.
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();

      // On résout les collisions.
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
      collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
      collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    } else {
      invalideBouton = true;
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauVille) {
      pause();
      niveau = 2; // On lance le niveau ville.
      infoChargeNiveau(); // On charge le niveau;
      niveauVille.relancer(true);
    }

    fade.actualiser();

    bonus1.actualiser();
    bonus2.actualiser();
    savate.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  // Gestion de l'affichage du niveau.
  public void afficher() {

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    cv.pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    cv.image(fond, 0, -cv.height); // Affichage des bâtiments et des plateformes.

    // Affichage des ennemis.
    for (Mercenaire m : ennemis) {
      m.afficher();
    }

    bonus1.afficher();
    bonus2.afficher();
    savate.afficher();

    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3764, 537, 130, 158);
    boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3279, 497, 130, 158);

    if (versNiveauVille)
      cv.image(infoDialogue, 3722, 373);
    if (declancheurDialogue1)
      cv.image(infoDialogue, 3237, 334);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    cv.popMatrix();

    hud.afficher();

    if (dialogueSavate || dialogue1) {
      cv.fill(50);
      cv.noStroke();
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 45, 500, 32);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
      if (dialogueSavate)
        cv.image(infoSavate, 215, 535);
      else if (dialogue1)
        cv.image(imgDialogue1, 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      cv.fill(0, 0, 0, 255);
      if (changeNiveauVille) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        cv.fill(0, 0, 0, transparence);
      }
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    } else if (changeNiveauVille) {
      infoChargeNiveau(); // On charge le niveau;
    }
  }

  public void actualiseDialogues() {
    // Pemier dialogue.
    if (dialogueSavate) {
      dialogueSavate = false;
    } else if (dialogue1) {
      dialogue1 = false;
    }
  }

  // Gestion des touches appuyées.
  public void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (fade.tempsEcoule && !dialogueSavate && !changeNiveauVille && !dialogue1) {
      joueur.keyPressed();
    }
    if (!dialogueSavate && !changeNiveauVille && !dialogue1) {
      char k = Character.toUpperCase((char) key);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3764, 537, 130, 158);
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3279, 497, 130, 158);
      if (k == 'E' && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } 
      if (k == 'E' && declancheurDialogue1) {
        dialogue1 = true;
      }
    }
  }

  public void touchPressed(int idBouton) {
    if (fade.tempsEcoule && !dialogueSavate && !changeNiveauVille && !dialogue1) {
      joueur.touchPressed(idBouton);
    }
    if (!dialogueSavate && !changeNiveauVille && !dialogue1) {
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3764, 537, 130, 158);
      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3279, 497, 130, 158);
      if (idBouton == 6 && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } 
      if (idBouton == 6 && declancheurDialogue1) {
        dialogue1 = true;
      }
    }
  }

  // Gestion des touches relâchées.
  public void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  public void touchReleased(int idBouton) {
    // Gestion des touches relâchées pour le joueur.
    joueur.touchReleased(idBouton);
  }

  // Permet de suspendre les actions du menu.
  public void pause() {
    musique.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  public void relancer() {
    musique.loop(); // On relance la musique de fond.
    joueur.initNiveau(3488, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    joueur.aligneDroite = false;
  }

  public void reinitialiser() {
    dialogueSavate = false;
    dialogue1 = false;
    fade.tempsEcoule = true;
    changeNiveauVille= false;
    bonus1.reinitialiser();
    bonus2.reinitialiser();
    savate.reinitialiser();
    for (Mercenaire m : ennemis) {
      m.reinitialiser();
    }
  }
}
class NiveauVille {
  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  PImage fond; // Image de fond (bâtiments et plateformes).
  PImage montagnes; // Image pour le parallax.
  float positionMontagesX = 0; // Position des montages pour l'effet parallax.

  SoundFile musique; // Musique de fond.


  Horloge fade; // Transition vers les niveaux.

  int numDialogue = 0; // Position dans les dialogues.
  PImage[] dialogues;

  boolean finDialogue1 = true;
  boolean lanceDialogue1 = false;

  boolean finDialogue2 = true;
  boolean lanceDialogue2 = false;

  boolean changeNiveauErmitage = false;
  boolean changeNiveauVolcan = false;

  boolean dialogueCombinaison = false;
  PImage infoCombinaison;

  Item combinaison;

  Item bonus1;
  Item bonus2;
  Item bonus3;



  // Initialisation du niveau.
  NiveauVille() {
    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();

    dialogues = new PImage[2];
    loadingRessource = "loading NiveauVille/thibault1.png";
    dialogues[0] = loadImage("NiveauVille/thibault1.png");
    loadingProgress--;
    loadingRessource = "loading NiveauVille/thibault2.png";
    dialogues[1] = loadImage("NiveauVille/thibault2.png");
    loadingProgress--;

    bonus1 = new PainBouchon(922, 219.5f);
    bonus2 = new PainBouchon(2087, -337.5f);
    bonus3 = new PainBouchon(3216, 227.9f);

    loadingRessource = "loading NiveauVille/dialogue_combinaison.png";
    infoCombinaison = loadImage("NiveauVille/dialogue_combinaison.png");
    loadingProgress--;
    combinaison = new Combinaison(1209.5f, -562.5f);

    loadingRessource = "loading NiveauVille/fond.png";
    fond = loadImage("NiveauVille/fond.png");
    loadingProgress--;
    loadingRessource = "loading NiveauVille/montagnes.png";
    montagnes = loadImage("NiveauVille/montagnes.png");
    loadingProgress--;

    //*************Mise en place des plateformes et murs *****************//

    // Collisions des bus
    plateformes.add(new Plateforme(1404, 429, 561, true)); // p6
    murs.add(new Mur(1124, 520, 180));
    murs.add(new Mur(1683, 520, 180));
    plateformes.add(new Plateforme(3435.5f, 429, 561, true)); // p11
    murs.add(new Mur(3155.5f, 520, 180));
    murs.add(new Mur(3716, 520, 180));

    // Collision des plateformes
    plateformes.add(new Plateforme(289.7365f, -174, 562.556f, false)); // p1
    plateformes.add(new Plateforme(1208, -466, 216, false)); // p2
    plateformes.add(new Plateforme(367.574f, 63.249f, 562.556f, false)); // p3
    plateformes.add(new Plateforme(963.5f, -80.368f, 215.748f, false)); // p4
    plateformes.add(new Plateforme(922.5f, 249, 217, false)); // p5
    plateformes.add(new Plateforme(1773.375f, 47.557f, 682, false)); // p7
    plateformes.add(new Plateforme(1999, -311, 584, false)); // p8
    plateformes.add(new Plateforme(2651, 30, 682, false)); // p9
    plateformes.add(new Plateforme(3202, 252, 215.75f, false)); // p10

    loadingRessource = "loading NiveauVille/musique.mp3";
    musique = new SoundFile(LeBouchonOr.this, "NiveauVille/musique.mp3");
    loadingProgress--;
    musique.amp(0.35f); // La musique étant trop forte, on baisse le volume.

    //Ennemis.
    Mercenaire m1 = new Mercenaire(2478, 574, 784, 3);
    m1.level = 1;
    ennemis.add(m1);
    Mercenaire m2 = new Mercenaire(289.7365f, -174, 562.556f, 1);
    m1.level = 1;
    ennemis.add(m2);
    Mercenaire m3 = new Mercenaire(367.574f, 63.249f, 562.556f, 2);
    m3.level = 2;
    ennemis.add(m3);
    Mercenaire m4 = new Mercenaire(1404, 429, 561, 3);
    m4.level = 2;
    ennemis.add(m4);
    Mercenaire m5 = new Mercenaire(1999, -311, 584, 3);
    m5.level = 7;
    ennemis.add(m5);

    Mercenaire m6 = new Mercenaire(2651, 30, 682, 2);
    m6.level = 2;
    ennemis.add(m6);

    Mercenaire m7 = new Mercenaire(3435.5f, 429, 561, 1);
    m7.level = 3;
    ennemis.add(m7);


    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  public void actualiser() {
    if (!changeNiveauErmitage && ! changeNiveauVolcan && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      invalideBouton = false;
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
      trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();

      // On résout les collisions.
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
      collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
      collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
      positionMontagesX += camera.dx*0.125f; // Pour donner un effet de parallax, on déplace un peu plus les montages que le fond.
    } else {
      invalideBouton = true;
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauErmitage) {
      pause();
      niveau = 3; // On lance le niveau Ermitage.
      infoChargeNiveau(); // On charge le niveau.
      niveauErmitage.relancer(); // On relance le niveau ermitage.
    } else if (fade.tempsEcoule && changeNiveauVolcan) {
      pause();
      niveau = 4; // On lance le niveau volcan.
      infoChargeNiveau(); // On charge le niveau.
      niveauVolcan.relancer();
    }
    combinaison.actualiser();
    bonus1.actualiser();
    bonus2.actualiser();
    bonus3.actualiser();
    fade.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  // Gestion de l'affichage du niveau.
  public void afficher() {
    cv.background(170, 204, 255); // affichage du ciel.

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    cv.pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    cv.image(montagnes, positionMontagesX, -cv.height); // Affichage des montagnes.
    cv.image(fond, 0, -cv.height); // Affichage des bâtiments et des plateformes.
    bonus1.afficher();
    bonus2.afficher();
    bonus3.afficher();
    for (Mercenaire m : ennemis) {
      m.afficher();
    }
    combinaison.afficher();
    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5f, 118, 235);
    boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5f, 100, 189);

    boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
    boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

    if (declancheurDialogue1)
      cv.image(infoDialogue, 929, 342);
    else if (declancheurDialogue2)
      cv.image(infoDialogue, 1975, -189);
    else if (versNiveauErmitage)
      cv.image(infoDialogue, 38, 385);
    else if (versNiveauVolcan)
      cv.image(infoDialogue, 3736, 402);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    cv.popMatrix();

    hud.afficher();

    if (lanceDialogue1 || lanceDialogue2 || dialogueCombinaison) {
      cv.fill(50);
      cv.noStroke();
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 45, 500, 32);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
      if (dialogueCombinaison)
        cv.image(infoCombinaison, 215, 535);
      else
        cv.image(dialogues[numDialogue], 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      cv.fill(0, 0, 0, 255);
      if (changeNiveauErmitage || changeNiveauVolcan) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        cv.fill(0, 0, 0, transparence);
      } else if (changeNiveauErmitage || changeNiveauVolcan) {
        cv.background(0);
      }
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    } else if (changeNiveauVolcan || changeNiveauErmitage) {
      infoChargeNiveau(); // On charge le niveau;
    }
  }

  public void actualiseDialogues() {
    // Pemier dialogue.
    if (lanceDialogue1) {
      numDialogue += 1;
      if (numDialogue  == 1 ) {
        finDialogue1 = true;
        lanceDialogue1 = false;
      }
    } 
    // 2ème dialogue.
    else if (lanceDialogue2) {
      numDialogue += 1;
      if (numDialogue == 2) {
        numDialogue = 1; // Evite les bugs.
        finDialogue2 = true;
        lanceDialogue2 = false;
      }
    } 
    // Info combinaison
    else if (dialogueCombinaison) {
      dialogueCombinaison = false;
    }
  }

  // Gestion des touches appuyées
  public void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      joueur.keyPressed();
    }

    // On réaffiche les dialogues.
    if (finDialogue1 && finDialogue2 && !lanceDialogue1 && !lanceDialogue2 && !changeNiveauVolcan && !changeNiveauErmitage && !dialogueCombinaison) {
      char k = Character.toUpperCase((char) key);

      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5f, 118, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5f, 100, 189);

      boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
      boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

      if (k == 'E' && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 0;
      } else if (k == 'E' && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 1;
      } else if (k == 'E' && versNiveauErmitage && !changeNiveauErmitage) {
        fade.lancer();
        changeNiveauErmitage = true;
      } else if (k == 'E' && versNiveauVolcan && !changeNiveauVolcan) {
        invalideBouton = true;
        fade.lancer();
        changeNiveauVolcan = true;
      }
    }
  }

  public void touchPressed(int idBouton) {
    if (fade.tempsEcoule && !lanceDialogue1 && !lanceDialogue2 && !dialogueCombinaison) {
      joueur.touchPressed(idBouton);
    }

    // On réaffiche les dialogues.
    if (finDialogue1 && finDialogue2 && !lanceDialogue1 && !lanceDialogue2 && !changeNiveauVolcan && !changeNiveauErmitage && !dialogueCombinaison) {

      boolean declancheurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 965, 503.5f, 118, 235);
      boolean declancheurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2011, -28.5f, 100, 189);

      boolean versNiveauErmitage = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 70, 533, 128, 153);
      boolean versNiveauVolcan = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3767, 538, 128, 153);

      if (idBouton == 6 && declancheurDialogue1) {
        lanceDialogue1 = true;
        finDialogue1 = false;
        numDialogue = 0;
      } else if (idBouton == 6 && declancheurDialogue2) {
        lanceDialogue2 = true;
        finDialogue2 = false;
        numDialogue = 1;
      } else if (idBouton == 6 && versNiveauErmitage && !changeNiveauErmitage) {
        fade.lancer();
        changeNiveauErmitage = true;
      } else if (idBouton == 6 && versNiveauVolcan && !changeNiveauVolcan) {
        fade.lancer();
        changeNiveauVolcan = true;
      }
    }
  }

  // Gestion des touches relâchées.
  public void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  public void touchReleased(int idBouton) {
    // Gestion des touches relâchées pour le joueur.
    joueur.touchReleased(idBouton);
  }

  // Permet de suspendre les actions du menu.
  public void pause() {
    musique.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  public void relancer(boolean gauche) {
    musique.loop(); // On relance la musique de fond.
    changeNiveauErmitage = false;
    fade.tempsEcoule = false;
    changeNiveauVolcan = false;
    if (gauche) // Si on arrive de la gauche.
      joueur.initNiveau(210, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    else
      joueur.initNiveau(3770, 4*cv.height/5-joueur.h/2);
  }

  public void reinitialiser() {
    positionMontagesX = 0; // Position des montages pour l'effet parallax.
    numDialogue = 0; // Position dans les dialogues.
    finDialogue1 = true;
    lanceDialogue1 = false;
    finDialogue2 = true;
    lanceDialogue2 = false;
    changeNiveauErmitage = false;
    changeNiveauVolcan = false;
    fade.tempsEcoule = true;
    dialogueCombinaison = false;
    bonus1.reinitialiser();
    bonus2.reinitialiser();
    bonus3.reinitialiser();
    combinaison.reinitialiser();
    for (Mercenaire m : ennemis) {
      m.reinitialiser();
    }
  }
}
class NiveauVolcan {

  ArrayList<Plateforme> plateformes; // Liste qui contient toutes les plateformes du niveau.
  ArrayList<Mur> murs; // Liste qui contient tous les murs du niveau.
  ArrayList<Mercenaire> ennemis; // Liste des ennemis.

  Item bonus1;
  Item bonus2;
  Item bonus3;
  Item bonus4;

  PImage fond; // Image de fond.

  SoundFile musique; // Musique de fond.

  Horloge fade; // Transition vers les niveaux.

  boolean dialogue1 = false;
  boolean dialogue2 = false;
  boolean dialogue3 = false;

  PImage imgDialogue1;
  PImage imgDialogue2;
  PImage imgDialogue3;

  boolean changeNiveauVille = false;
  boolean changeNiveauBoss = false;

  // Initialisation du niveau.
  NiveauVolcan() {

    plateformes = new ArrayList<Plateforme>();
    murs = new ArrayList<Mur>();
    ennemis = new ArrayList<Mercenaire>();
    loadingRessource = "loading NiveauVolcan/fond.png";
    fond = loadImage("NiveauVolcan/fond.png");
    loadingProgress--;
    loadingRessource = "loading NiveauVolcan/thibault1.png";
    imgDialogue1 = loadImage("NiveauVolcan/thibault1.png");
    loadingProgress--;
    loadingRessource = "loading NiveauVolcan/thibault2.png";
    imgDialogue2 = loadImage("NiveauVolcan/thibault2.png");
    loadingProgress--;
    loadingRessource = "loading NiveauVolcan/martin.png";
    imgDialogue3 = loadImage("NiveauVolcan/martin.png");
    loadingProgress--;

    //*************Mise en place des plateformes et murs *****************//
    loadingRessource = "loading NiveauVolcan/musique.mp3";
    musique = new SoundFile(LeBouchonOr.this, "NiveauVolcan/musique.mp3");
    loadingProgress--;
    musique.amp(0.75f);

    bonus1 = new PainBouchon(2418, 553);
    bonus2 = new PainBouchon(3485, 506);
    bonus3 = new PainBouchon(3196, 506);
    bonus4 = new PainBouchon(416, 117);

    plateformes.add(new Plateforme(1028, 363, 288, false)); // P1
    plateformes.add(new Plateforme(735.5f, 149, 847, false)); // P2
    plateformes.add(new Plateforme(750, -4, 278, false)); // P3
    plateformes.add(new Plateforme(1060, -200, 476, false)); // P4
    plateformes.add(new Plateforme(1487, -330, 382, false)); // P5

    Mercenaire m1 = new Mercenaire(1028, 363, 10, 1);
    m1.level = 6;
    ennemis.add(m1);
    Mercenaire m2 = new Mercenaire(735.5f, 149, 847, 3);
    m2.level = 7;
    ennemis.add(m2);
    Mercenaire m3 = new Mercenaire(1060, -200, 476, 2);
    m3.level = 8;
    ennemis.add(m3);
    Mercenaire m4 = new Mercenaire(1487, -330, 382, 3);
    m4.level = 9;
    ennemis.add(m4);
    Mercenaire m5 = new Mercenaire(1708, 576, 656, 2);
    m5.level = 10;
    ennemis.add(m5);



    fade = new Horloge(2000);
    fade.tempsEcoule = true;
  }

  // Gestion de la logique du niveau.
  public void actualiser() {
    if (!changeNiveauVille && !dialogue1 && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      invalideBouton = false;
      // Estimation des collisions.
      trouverPlateformeCandidate(plateformes); // On cherche un plateforme qui pourrait potentiellement enter en collision avec le joueur.
      trouverMursCandidats(murs); // De même pour les murs a gauches et à droites du joueur.
      // On actualise les ennemis.
      for (Mercenaire m : ennemis) {
        m.actualiser();
      }
      // On actualise le joueur: mouvements, état, etc. voir la classe "Joueur".
      joueur.actualiser();

      // On résout les collisions.
      collisionPlateformes(); // On empêche le joueur de tomber de la plateforme (si il y en a une qui doit supporter le joueur).
      collisionMurs(); // On empêche le joueur de traverser le mur (si il y en a un qui doit le stopper).
      collisionLimites(); // On s'assure que le joueur ne sorte pas des limites du niveau.


      //Si le joueur n'est pas invincible à la lave il ne peut pas continuer le niveau.
      if (!joueur.invulnerableLave && joueur.x > 2670) {
        joueur.vx = 0;
        joueur.x = 2670 - joueur.w/2;
      }

      camera.actualiser(); // On déplace la position de la caméra si nécessaire.
    } else {
      invalideBouton = true;
    }
    // Après la transition on change de niveau.
    if (fade.tempsEcoule && changeNiveauVille) {
      pause();
      niveau = 2; // On lance le niveau ville.
      infoChargeNiveau(); // On charge le niveau;
      niveauVille.relancer(false);
    } else if (fade.tempsEcoule && changeNiveauBoss) {
      pause();
      niveau = 6; // On lance le niveau du boss;
      infoChargeNiveau(); // On charge le niveau;
      niveauBoss.relancer();
    }

    fade.actualiser();

    bonus1.actualiser();
    bonus2.actualiser(); 
    bonus3.actualiser();
    bonus4.actualiser();

    // Si le joueur est mort.
    if (joueur.vie <= 0) {
      niveau = 9;
      gameOver.relancer();
      pause();
      infoChargeNiveau();
    }
  }

  // Gestion de l'affichage du niveau.
  public void afficher() {

    // On vas effectuer l'affichage des éléments du niveau dans le repère de la caméra.
    cv.pushMatrix(); // On conserve en mémoire l'ancien repère.

    camera.deplaceRepere(); // On déplace le repère courant pour se placer dans le repère de la caméra, ce qui permet de "bouger" les éléments à afficher. Voir la classe "Camera".

    // Remarque: On affiche quand même les éléments dans le repère initial, car processing vas gérer la translation relativement à la caméra grace à l'instruction
    // précédente.
    // Remarque 2: le repère initial est (0, 0) or les coordonnées de la boîte englobante du niveau dans ce repère sont: (0, -height) et (3*width, height);

    cv.image(fond, 0, -cv.height); // Affichage des bâtiments et des plateformes.
    bonus1.afficher();
    bonus2.afficher();
    bonus3.afficher();
    bonus4.afficher();
    // Affichage des ennemis.
    for (Mercenaire m : ennemis) {
      m.afficher();
    }



    joueur.afficher(); // On affiche le joueur.

    //********** DEBUGAGE *********//
    if (debug) {
      affichePlateformesDebug(plateformes);
      afficheMursDebug(murs);
    }

    boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 98, 540.5f, 130, 158);
    boolean versNiveauBoss = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3642, 540.5f, 130, 158);
    boolean declangeurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 500.5f, 496, 141, 147);
    boolean declangeurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2629, 496, 141, 147);

    if (versNiveauVille)
      cv.image(infoDialogue, 71, 393);
    else if (versNiveauBoss)
      cv.image(infoDialogue, 3600, 362);
    else if (declangeurDialogue1)
      cv.image(infoDialogue, 466, 342);
    else if (declangeurDialogue2)
      cv.image(infoDialogue, 2592, 348);

    // Une fois l'affichage qui dépend de la position de la caméra est fini, on se replace dans l'ancien repère de coordonnées.
    cv.popMatrix();

    hud.afficher();

    if (dialogue1 || dialogue2 || dialogue3) {
      cv.fill(50);
      cv.noStroke();
      cv.rectMode(CENTER);
      cv.rect(cv.width/2, 45, 500, 32);
      cv.textSize(24);
      cv.textAlign(CENTER, CENTER);
      cv.fill(0);
      cv.text("Touchez l'ecran pour continuer", cv.width/2+1, 43);
      cv.fill(255);
      cv.text("Touchez l'ecran pour continuer", cv.width/2, 42);
      if (dialogue1)
        cv.image(imgDialogue1, 215, 535);
      else if (dialogue2)
        cv.image(imgDialogue2, 215, 535);
      else if (dialogue3)
        cv.image(imgDialogue3, 215, 535);
    }

    // Transition.
    if (!fade.tempsEcoule) {
      cv.noStroke();
      float transparence = 255;
      cv.fill(0, 0, 0, 255);
      if (changeNiveauVille || changeNiveauBoss) {
        transparence = map(fade.compteur, 0, fade.temps, 0, 255);
        cv.fill(0, 0, 0, transparence);
      }
      cv.rectMode(CORNER);
      cv.rect(0, 0, cv.width, cv.height);
    } else if (changeNiveauVille || changeNiveauBoss) {
      infoChargeNiveau(); // On charge le niveau;
    }
  }

  public void actualiseDialogues() {
    // Pemier dialogue.
    if (dialogue1) {
      dialogue1 = false;
    } else if (dialogue2) {
      dialogue2 = false;
    } else if (dialogue3) {
      dialogue3 = false;
    }
  }

  // Gestion des touches appuyées.
  public void keyPressed() {
    if (key == ' ') {
      actualiseDialogues();
    } else if (fade.tempsEcoule && !dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      joueur.keyPressed();
    }

    if (!dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      char k = Character.toUpperCase((char) key);
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 98, 540.5f, 130, 158);
      boolean versNiveauBoss = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3642, 540.5f, 130, 158);
      boolean declangeurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 500.5f, 496, 141, 147);
      boolean declangeurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2629, 496, 141, 147);
      if (k == 'E' && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } else if (k == 'E' && versNiveauBoss && joueur.level < 10) {
        dialogue3 = true;
      } else if (k == 'E' && versNiveauBoss && joueur.level == 10) {
        fade.lancer();
        changeNiveauBoss = true;
      } else if (k == 'E' && declangeurDialogue1) {
        dialogue1 = true;
      } else if (k == 'E' && declangeurDialogue2) {
        dialogue2 = true;
      }
    }
  }

  public void touchPressed(int idBouton) {
    if (fade.tempsEcoule && !dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      joueur.touchPressed(idBouton);
    }

    if (!dialogue1 && !changeNiveauVille && !dialogue2 && !changeNiveauBoss && !dialogue3) {
      boolean versNiveauVille = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 98, 540.5f, 130, 158);
      boolean versNiveauBoss = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 3642, 540.5f, 130, 158);
      boolean declangeurDialogue1 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 500.5f, 496, 141, 147);
      boolean declangeurDialogue2 = collisionRectangles(joueur.x, joueur.y, joueur.w, joueur.h, 2629, 496, 141, 147);
      if (idBouton == 6 && versNiveauVille) {
        fade.lancer();
        changeNiveauVille = true;
      } else if (idBouton == 6 && versNiveauBoss && joueur.level < 10) {
        dialogue3 = true;
      } else if (idBouton == 6 && versNiveauBoss && joueur.level == 10) {
        fade.lancer();
        changeNiveauBoss = true;
      } else if (idBouton == 6 && declangeurDialogue1) {
        dialogue1 = true;
      } else if (idBouton == 6 && declangeurDialogue2) {
        dialogue2 = true;
      }
    }
  }

  // Gestion des touches relâchées.
  public void keyReleased() {
    // Gestion des touches relâchées pour le joueur.
    joueur.keyReleased();
  }

  public void touchReleased(int idBouton) {
    // Gestion des touches relâchées pour le joueur.
    joueur.touchReleased(idBouton);
  }


  // Permet de suspendre les actions du menu.
  public void pause() {
    musique.stop(); // On stope la musique de fond.
  }

  // Lorsque l'on revient dans ce niveau, on s'assure de reprendre ses actions misent en pause.
  public void relancer() {
    musique.loop(); // On relance la musique de fond.
    joueur.initNiveau(281, 4*cv.height/5-joueur.h/2); // On replace le joueur dans le niveau.
    changeNiveauVille = false;
    fade.tempsEcoule = true;
    joueur.aligneDroite = true;
    dialogue1 = false;
    dialogue2 = false;
  }

  public void reinitialiser() {
    fade.tempsEcoule = true;
    dialogue1 = false;
    dialogue2 = false;
    dialogue3 = false;
    changeNiveauVille = false;
    changeNiveauBoss = false;
    bonus1.reinitialiser();
    bonus2.reinitialiser();
    bonus3.reinitialiser();
    bonus4.reinitialiser();
    for (Mercenaire m : ennemis) {
      m.reinitialiser();
    }
  }
}
class Plateforme {
  float x, y; // Positions de la plateforme.
  float w; // Dimention de la plateforme.
  boolean collisionPermanente = false; // Permet d'empêcher le joueur de descendre de cette plateforme en passant au travers.

  // Remarque: pas besoin d'avoir une épaisseur en y pour la plateforme, pour des raisons d'optimisation et de bon sens,
  // on a besoin que de la position y de la plateforme pour tester si le joueur se trouve au dessus ou en dessous,
  // ce qui revient à considérer qu'une seule dimention en plus : la largeur de la plateforme.


  // Initialisation
  Plateforme(float tx, float ty, float tw, boolean toujoursActive) {
    x = tx;
    y = ty;
    w = tw;
    collisionPermanente = toujoursActive;
  }

  // Permet de savoir si la hitbox du joueur et la plateforme sont superposées.
  public boolean collisionPotentielle() {
    boolean faceGauche = joueur.x-joueur.w/2 >= x-w/2 && joueur.x-joueur.w/2 <= x+w/2;
    boolean faceDroite = joueur.x+joueur.w/2 >= x-w/2 && joueur.x+joueur.w/2 <= x+w/2;
    return faceDroite || faceGauche;
  }
}
class Sprite {
  ArrayList<PImage> frames; // Liste d'images
  boolean anime = false; // permet de savoir si on joue l'animation
  boolean loop = false; // Permet de rejouer l'animation en automatique
  int vitesseAnimation = 0; // vitesse d'animation (en ms), c'est le temps d'attente entre chaque image
  int frameActuelle = 0;
  int nbFrames = 1; // Nombre d'image -1 pour l'animation
  int compteur = 0; // permet de compter le nombre de millis secondes écoulées (pour pouvoir déterminer quand on change d'image)

  boolean mirroir = false; // Permet de "inverser" sur l'axe y l'image

  int x, y; // Position d'affichage DU SPRITE, l'image est centrée sur ces coordonnées.
  // Remarque:  Processing a plus de facilités à afficher une image sur des coordonnées de pixels

  // initialisation
  Sprite(float tx, float ty) {
    y = (int) ty;
    x = (int) tx;
    frames = new ArrayList<PImage>();
  }

  // Permet d'actualiser les coordonnées par rapport à celles liées à un objet.
  public void changeCoordonnee(float tx, float ty) {
    x = (int) tx;
    y = (int) ty;
  }

  // Permet de relancer une animation finie.
  public void reinitialiser() {
    frameActuelle = 0;
    anime = true;
  }

  // Pemet de chager une séquence d'images.
  // chemin = chemin du dossier
  // n = nombre d'image - 1 (le format généré par blender est de 1 à n)
  // format = le nombre de chiffres du format du nom des images (ex: format = 4 => 0001, 0002, ... 0016)
  public void chargeAnimation(String chemin, int n, int format) {
    frames.clear(); // On efface toutes les images précédentes.
    nbFrames = n;
    for (int i=1; i <= nbFrames; i++) {
      // nf(i, format) formate le nombre "i" pour un affichage à "format" chiffres.
      chargeImage(chemin+nf(i, format)+".png");
    }
  }

  // Permet de charger une image et l'ajoute a la fin de la liste des images.
  public void chargeImage(String chemin) {
    loadingRessource = "loading "+chemin;
    frames.add(loadImage(chemin));
    loadingProgress--;
  }


  // renvoie la largeur de l'image actuellement affichée.
  public int width() {
    return frames.get(frameActuelle).width;
  }

  // renvoie la heuteur de l'image actuellement affichée.
  public int height() {
    return frames.get(frameActuelle).height;
  }

  // Permet d'afficher le sprite
  public void afficher() {
    if (anime) {
      // Si il y a une animation,
      // On regarde si le temps d'attente entre 2 images est respecté.
      if (millis()-compteur > vitesseAnimation) {
        compteur = millis(); // On réinitialise le compteur

        // Gestion de la boucle / arrêt de l'animation.
        if (frameActuelle < nbFrames-1) {
          frameActuelle++;
        } else if (loop) { // Si on boucle l'animation.
          frameActuelle = 0;
        } else { // Si non, l'animation se termine.
          anime = false;
        }
      }
    }

    //************ Affichage de l'image actuelle ***************** //
    int demiW = width()/2;
    int demiH = height()/2;

    // Si il faut inverser l'image sur son axe y:
    if (mirroir) {
      cv.pushMatrix(); // On conserve l'ancien repère de coordonnées.
      cv.scale(-1, 1); // On inverse le repère selon l'axe y
      // Comme les coordonnées x sont elles aussi inversée, alors "x" devient "-x".
      cv.image(frames.get(frameActuelle), -x - demiW, y - demiH);
      cv.popMatrix(); // On restore l'ancien repère.
    } else {
      // Si non pas besoin de retourner l'image
      cv.image(frames.get(frameActuelle), x - demiW, y - demiH);
    }

    //************** DEBUGAGE ************//
    if (debug) {
      cv.noFill();
      cv.stroke(0, 0, 255);
      cv.rectMode(CENTER);
      cv.rect(x, y, demiW*2, demiH*2);
    }
  }
}
  public void settings() {  fullScreen(P2D); }
}
