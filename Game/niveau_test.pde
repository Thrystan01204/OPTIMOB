class NiveauTest {
  
 NiveauTest(){
   
 }
 
 void update(){
   joueur.update();
   if(joueur.y > 3*height/4){
     joueur.y = 3*height/4;
     joueur.vy -= joueur.y-3*height/4;
     joueur.surPlateforme = true;
     joueur.enSaut = false;
   }
 }
 
 void afficher(){
   background(0, 200, 255);
   noStroke();
   rectMode(CORNER);
   fill(0, 200, 0);
   rect(0, 3*height/4, width, height/4);
   joueur.afficher();
 }
 
 void keyPressed(){
   if(key == ESC){
      key = 0; // cela permet de faire croire à processing que l'on a pas appuié sur la touche "echap" et donc l'empêche de fermer le jeu
      niveau = 0;
      menuPrincipal.reinitialiser();
    }
   joueur.keyPressed();
 }
 
 void keyReleased(){
   joueur.keyReleased();
 }
 
 void pause(){
   
 }
 
 void relancer(){
   joueur.initNiveau(width/2, height/4);
 }
 
}
