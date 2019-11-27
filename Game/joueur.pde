class Joueur{
  
  float x, y;
  float vx = 0; 
  float vy = 0;
  float friction = 0.9;
  Sprite sprite;
  float vitesseDeplacement = 200;  // En pixel par secondes
  float grav = 1000; // En pixels par secondes carrés
  int xp = 0; // Le niveau du personnage
  
  
  boolean surPlateforme = false;
  boolean enDeplacement = false;
  boolean enSaut = false;
  boolean enAttaqueProche = false;
  boolean enAttaqueLongue = false;
  
  Joueur(){
    sprite = new Sprite(x, y, true);
  }
 
 void update(){
   // Intégration du mouvement avec la méthode d'euler
   if(!surPlateforme)
     vy += grav*dt; // on applique la gravité si on est pas sur une plateforme
   y += vy*dt;
   x += vx*dt;
   
   if(!enDeplacement && !enSaut){
     vx *= friction;
   }
 }
 
 void afficher(){
   noStroke();
   fill(0, 0, 255);
   ellipse(x, y, 32, 32);
 }
 
 // Permet de bouger le joueur lorsque l'on appuie sur une touche
 void keyPressed(){
     char k = Character.toUpperCase((char) key);
     if(k == 'Z' && surPlateforme){
       vy = -600;
       y += 1;
       surPlateforme = false;
       enSaut = true;
     } else if(k == 'D'){
       enDeplacement = true;
       vx = vitesseDeplacement;
     } else if(k == 'Q'){
       enDeplacement = true;
       vx = -vitesseDeplacement;
     }
 }
 
 void keyReleased(){
   char k = Character.toUpperCase((char) key);
   if(k == 'D' || k == 'Q'){
     enDeplacement = false;
   }
 }
 
 
 // Permet de placer le personnage dans les niveau
 void initNiveau(float tx, float ty){
   vx = 0;
   vy = 0;
   x = tx;
   y = ty;
 }
 
 
}
