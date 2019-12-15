// Vibrations
import android.app.Activity;
import android.content.Context;
import android.os.Vibrator;
import android.os.VibrationEffect;

import android.view.MotionEvent; //Multi touch

import processing.sound.*;  // Bibliothèque pour gérer les musiques.
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

float dt = 1.0/60; // Pas de temps pour l'intégration du mouvement du joueur.
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
void chargerNiveaux() {
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
boolean sourisDansRectangle(float x1, float y1, float x2, float y2) {

  float dx = abs(width-widthActuelle)/2.0;
  float dy = abs(height-heightActuelle)/2.0;

  float mx = map(mouseX, dx, dx+widthActuelle, 0, cv.width);
  float my = map(mouseY, dy, dy+heightActuelle, 0, cv.height);

  return (x1 <= mx && mx <= x2 && y1 <= my && my <= y2);
}

// fonction pour si l'on appuie sur un bouton.
boolean pointDansCercle(float px, float py, float cx, float cy, float r) {
  float dx = abs(width-widthActuelle)/2.0;
  float dy = abs(height-heightActuelle)/2.0;

  float mx = map(px, dx, dx+widthActuelle, 0, cv.width);
  float my = map(py, dy, dy+heightActuelle, 0, cv.height);

  return (sq(mx-cx)+sq(my-cy) < sq(r));
}

boolean collisionRectangles(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  return !((x2-w2/2 >= x1 + w1/2) || (x2 + w2/2 <= x1-w1/2) || (y2-h2/2 >= y1 + h1/2) || (y2 + h2/2 <= y1-h1/2));
}

//Permet de réinitialiser le jeu en cas de mort du joueur ou de fin de partie.
void reinitialiserJeu() {
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
void infoChargeNiveau() {
  cv.background(50);
  cv.textAlign(CENTER, CENTER);
  cv.textSize(72);
  cv.fill(255);
  cv.text("CHARGEMENT DU NIVEAU", cv.width/2, cv.height/2);
  cv.textSize(24);
  cv.text("Cette opération peu prendre quelques secondes...ou minutes en fonction de votre matériel.", cv.width/2, 3*cv.height/4);
}

void collisionLimites() {
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
void affichePlateformesDebug(ArrayList<Plateforme> plateformes) {
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
      cv.stroke(0, 255, 0);
      cv.line(joueur.x, joueur.y, p.x, joueur.y);
    } else
      cv.stroke(255, 0, 0);
    cv.line(p.x, p.y-p.h/2, p.x, p.y+p.h/2);
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

  fullScreen(P2D);
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
void draw() {
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
    cv.rotate(millis()/1000.0); // la rotation dépend du temps écoulé et elle est 2PI périodique, d'où l'animation.
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
    cv.text(str(int(frameRate))+" FPS", cv.width/2, 32);

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
  float ratioX= float(width)/1280.0;
  float ratioY = float(height)/720.0;
  float ratio = min(ratioX, ratioY);
  widthActuelle =(int) (1280.0*ratio);
  heightActuelle =(int) (720.0*ratio);
  background(0);
  image(cv, width/2-widthActuelle/2, height/2-heightActuelle/2, widthActuelle, heightActuelle);
}


void mousePressed() {
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

void keyReleased() {
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
void touchButtonUp(int id) {
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

void keyPressed() {
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
void touchButtonDown(int id, float px, float py) {
  if (!chargementDuJeu && !invalideBouton) {
    Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
    int idBouton = -1;
    if (bouton[0] == -1 && pointDansCercle(px, py, 85.68, 635.75, 83.22)) {
      bouton[0] = id;
      idBouton = 0;
    } else if (bouton[1] == -1 && pointDansCercle(px, py, 353.57, 635.75, 83.22)) {
      bouton[1] = id;
      idBouton = 1;
    } else if (bouton[2] == -1 && pointDansCercle(px, py, 1143.94, 609.68, 90)) {
      bouton[2] = id;
      idBouton = 2;
    } else if (bouton[3] == -1 && pointDansCercle(px, py, 920.64, 649, 56)) {
      bouton[3] = id;
      idBouton = 3;
    } else if (bouton[4] == -1 && pointDansCercle(px, py, 973.69, 502.52, 54.2)) {
      bouton[4] = id;
      idBouton = 4;
    } else if (bouton[5] == -1 && pointDansCercle(px, py, 1125.2, 424.1, 54.2)) {
      bouton[5] = id;
      idBouton = 5;
    } else if (bouton[6] == -1 && pointDansCercle(px, py, 1202.36, 288, 51)) {
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
