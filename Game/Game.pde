import processing.sound.*;

//*************************************************** Selecteur de niveau ************************************ //


int niveau = 0; //  variable globale pour la gestion des differents niveaux
//0 = menu principal
//1 = crédits
//2 = intro
//3 = niveau plage
//4 = niveau volcan
//5 = niveau village
//6 = Boss final

MenuPrincipal menuPrincipal; // Niveau : menu principal
Credits credits; // Niveau : Credits




void setup(){
  size(1280, 720);
  
  // On charge tous les niveaux au début du jeu
  menuPrincipal = new MenuPrincipal();
  credits = new Credits();
}

void draw(){
  if(niveau == 0)
    menuPrincipal.update();
  else if (niveau == 1)
    credits.update();
    
}

void mousePressed(){
  if(niveau == 0)
    menuPrincipal.mousePressed();
}

void keyPressed(){
  if(niveau == 1)
    credits.retourMenuPrincipal();
}

// fonction pour détecter si la souris se trouve dans un rectangle, utile pour l'interface
boolean sourisDansRectangle(float x1, float y1, float x2, float y2){
    return (x1 <= mouseX && mouseX <= x2 && y1 <= mouseY && mouseY <= y2);
}
