class Sprite {
  ArrayList<PImage> frames; // Liste d'images
  boolean anime = false; // permet de savoir si on joue l'animation
  int vitesse = 0; // vitesse d'animation (en ms), c'est le temps d'attente entre chaque image
  int frameActuelle = 0;
  int nbFrames = 1; // Nombre d'image pour l'animation
  int compteur = 0; // permet de compter le nombre de millis secondes écoulées (pour pouvoir déterminer quand on change d'image)
  int x, y;
  
  Sprite(int tx, int ty, boolean tanime){
    x = tx;
    y = ty;
    anime = tanime;
    frames = new ArrayList<PImage>();
  }
  
  void chargeImage(String path){
    frames.add(loadImage(path));
  }
  
  void chargeAnimation(String path){
    
  }
  
  int width(){
    return frames.get(frameActuelle).width;  
  }
  
  int height(){
    return frames.get(frameActuelle).height;  
  }
  
  void afficher(){
    image(frames.get(frameActuelle), x, y);
    if(debug){
      int w = frames.get(frameActuelle).width;
      int h = frames.get(frameActuelle).height;
      noFill();
      stroke(255, 0, 0);
      rectMode(CORNER);
      rect(x, y, w, h);
    }
  }
  
}