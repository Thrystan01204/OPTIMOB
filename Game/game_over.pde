class GameOver{
  Horloge temps;
  
  GameOver(){
    temps = new Horloge(5000); // 5 secondes avant le retour au menu automatique.
    temps.lancer();
  }
  
  void actualiser(){
    if(temps.tempsEcoule){
      exit();
    }
    temps.actualiser();
  }
  
  void afficher(){
    background(50);
    textSize(50);
    textAlign(CENTER, CENTER);
    fill(255, 0, 0);
    text("Vous avez perdu.", width/2, height/2);
    textSize(24);
    fill(255);
    text("Le jeu se fermera automatiquement, relancer le si vous l'osez !", width/2, 3*height/4);
  }
  
}
