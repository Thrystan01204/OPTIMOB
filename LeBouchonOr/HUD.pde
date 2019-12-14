class HUD {

  HUD() {}

  void afficher() {

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
      if(joueur.level < 10)
        valeur = map(joueur.xp, 0, joueur.xpMax, 0, cv.width/4);
      else
        valeur = cv.width/4;
      cv.rect(0, 24, valeur, 24);
      
      
      if (joueur.invulnerableLave) {
        // Affichage de l'invulnérabilité à la lave.
        cv.textSize(20);
        cv.textAlign(LEFT, TOP);
        cv.fill(0);
        cv.text("Invulnérable à la lave", 49, 49);
        cv.fill(255);
        cv.text("Invulnérable à la lave", 48, 48);
      }
      if(joueur.superSaut){
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
