class HUD {

  HUD() {
  }

  void afficher() {

    if (joueur.vie > 0) {
      //Barre de vie du joueur
      noStroke();
      //fond de la barre de vie.
      fill(50, 50, 50);
      rectMode(CORNER);
      rect(0, 0, width/2, 24);
      // Barre de vie.
      fill(255, 0, 0);
      float valeur = map(joueur.vie, 0, joueur.vieMax, 0, width/2);
      rect(0, 0, valeur, 24);
      // Affichage du nombre de pv.
      textSize(20);
      textAlign(LEFT, TOP);
      fill(0);
      text(str(joueur.vie)+" pv", 1, 1);
      fill(255);
      text(str(joueur.vie)+" pv", 0, 0);

      //fond de la barre d'xp.
      fill(50, 50, 50);
      rectMode(CORNER);
      rect(0, 24, width/4, 24);
      // Barre d'xp.
      fill(0, 0, 255);
      valeur = map(joueur.xp, 0, joueur.xpMax, 0, width/4);
      rect(0, 24, valeur, 24);
      
      
      if (joueur.invulnerableLave) {
        // Affichage de l'invulnérabilité à la lave.
        textSize(20);
        textAlign(LEFT, TOP);
        fill(0);
        text("Invulnérable à la lave", 49, 49);
        fill(255);
        text("Invulnérable à la lave", 48, 48);
      }

      textSize(20);
      if (joueur.level < joueur.levelMax) {
        fill(0);
        text("niveau "+str(joueur.level), 1, 25);
        fill(255);
        text("niveau "+str(joueur.level), 0, 24);
      } else {
        fill(0);
        text("niveau max ("+str(joueur.levelMax)+")", 1, 25);
        fill(255);
        text("niveau max ("+str(joueur.levelMax)+")", 0, 24);
      }
    }
  }
}
