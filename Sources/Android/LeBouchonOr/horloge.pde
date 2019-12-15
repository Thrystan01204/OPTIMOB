class Horloge {
  private int tempsDebut;
  int temps;
  int compteur = 0;
  boolean tempsEcoule = true;

  Horloge(int temps) {
    this.temps = temps;
  }

  void actualiser() {
    if (!tempsEcoule) {
      compteur = millis() - tempsDebut;
      if (compteur > temps) {
        tempsEcoule = true;
        compteur = temps;
      }
    }
  }

  void lancer() {
    tempsEcoule = false;
    tempsDebut = millis();
    compteur = 0;
  }
}
