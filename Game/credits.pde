class Credits{
  
  // vitesse de défilement des crédits
  float speed = 1;
  
  // Position du pavé de texte
  float y = height-32;
  
  //Crédits
  String texte = "OPTIMOB\n\nRéalisé par:\n Pierre Jaffuer,\nRonico Billy,\nOlivier Vee,\nIbnou Issouffa,\nMatthieu Mehon Shit Li,\nTristan Le Lidec";
  
  // la musique de fond
  SoundFile musique;
  
  Credits(){
    musique = new SoundFile(Game.this, "MenuPrincipal/adventure.wav");
  }
  
  void update(){
    y -= speed;
  }
  
  void afficher(){
    background(50);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text(texte, width/2, y);
  }
  
  void retourMenuPrincipal(){
    pause();
    menuPrincipal.reinitialiser();
    niveau = 0;
  }
  
  void reinitialiser(){
    musique.loop();
    y = height-32;
  }
  
  void pause(){
    musique.stop();  
  }
  
}
