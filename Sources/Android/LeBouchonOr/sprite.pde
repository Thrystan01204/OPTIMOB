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
  void changeCoordonnee(float tx, float ty) {
    x = (int) tx;
    y = (int) ty;
  }

  // Permet de relancer une animation finie.
  void reinitialiser() {
    frameActuelle = 0;
    anime = true;
  }

  // Pemet de chager une séquence d'images.
  // chemin = chemin du dossier
  // n = nombre d'image - 1 (le format généré par blender est de 1 à n)
  // format = le nombre de chiffres du format du nom des images (ex: format = 4 => 0001, 0002, ... 0016)
  void chargeAnimation(String chemin, int n, int format) {
    frames.clear(); // On efface toutes les images précédentes.
    nbFrames = n;
    for (int i=1; i <= nbFrames; i++) {
      // nf(i, format) formate le nombre "i" pour un affichage à "format" chiffres.
      chargeImage(chemin+nf(i, format)+".png");
    }
  }

  // Permet de charger une image et l'ajoute a la fin de la liste des images.
  void chargeImage(String chemin) {
    loadingRessource = "loading "+chemin;
    frames.add(loadImage(chemin));
    loadingProgress--;
  }


  // renvoie la largeur de l'image actuellement affichée.
  int width() {
    return frames.get(frameActuelle).width;
  }

  // renvoie la heuteur de l'image actuellement affichée.
  int height() {
    return frames.get(frameActuelle).height;
  }

  // Permet d'afficher le sprite
  void afficher() {
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
