class Joueur {
  float x, y; // Positions du joueur
  float vx = 0; // Vitesse du joueur sur l'axe x (en pixels par secondes)
  float vy = 0; // Vitesse du joueur sur l'axe y (en pixels par secondes)
  float friction = 0.80; // Coefficient
  float forceSaut = 1500; // En pixel par secondes
  float vitesseDeplacement = 400;  // En pixel par secondes
  float gravite = 4000; // En pixels par secondes carrés
  int xp = 0; // Le niveau du personnage
  int vieMax = 10; // Le nombre maximum de points de vie au début du jeu.
  int vie = vieMax; // Le nombre de points de vie.

  Sprite spriteCourse; // Animation de déplacement
  Sprite spriteImmobile; // Animation par défaut
  Sprite spriteTombe; // Animation lorsque le joueur retombe (une seule image pour le moment)
  Sprite spriteSaut; // animation lorsque le joueur saute (une seule image pour le moment)
  
  SoundFile sonSaut;  // Son lorsque le joueur saute.

  boolean aligneDroite = true; // Permet de savoir quand il faut retourner les sprites et dans quelle direction il faut tirer les projectiles.

  // Dimension de la hitbox du joueur
  int w = 35; // épaisseur
  int h = 120; // largeur

  boolean surPlateforme = false; // Permet de savoir si le joueur ne doit plus tomber car il est sur une plateforme.

  // Les différents états du joueur
  boolean enDeplacement = false;
  boolean enAttaqueProche = false;
  boolean enAttaqueLongue = false;
  
  // Permet d'indiquer au système de collision que l'on veut descendre de la plateforme en passant au travers.
  boolean descendPlateforme = false;

  // Initialisation
  Joueur(float x, float y) {

    // On charge toutes les animations et on les configures :
    spriteCourse = new Sprite(x, y);
    spriteCourse.vitesseAnimation = 32; // 40 ms entre chaques images
    // On charge les images de l'animation, ici il y en a 16 et le nom est codé avec 4 entiers: 0001, ..., 0016.
    // Voir la classe sprite.
    spriteCourse.chargeAnimation("Martin/Course/", 16, 4); 
    spriteCourse.loop = true; // L' animation recommence perpétuellement.
    spriteCourse.anime = true; // On lance l'animation.

    spriteImmobile = new Sprite(x, y);
    spriteImmobile.vitesseAnimation = 40;
    spriteImmobile.chargeAnimation("Martin/Immobile/", 16, 4);
    spriteImmobile.loop = true;
    spriteImmobile.anime = true;

    spriteTombe = new Sprite(x, y);
    spriteTombe.chargeImage("Martin/tombe.png");

    spriteSaut = new Sprite(x, y);
    spriteSaut.chargeImage("Martin/saut.png");
    
    sonSaut = new SoundFile(Game.this, "Martin/saut.wav");
  }

  // Gestion de la logique du joueur.
  void actualiser() {
    // Intégration numérique du mouvement avec la méthode d'euler.
    if (!surPlateforme){
      // Intégration numérique de la vitesse.
      vy += gravite*dt; // On applique la gravité si le joueur n'est pas sur une plateforme.
    }
    
    // Intégration numérique des coordonnées.
    y += vy*dt;
    x += vx*dt;

    // Si on est sur une plateforme et que le jouer ne doit plus se déplacer, 
    // on ralenti son mouvement horizontal pour le rendre immobile.
    // Cela permet de donner une inertie au joueur.
    if (surPlateforme && !enDeplacement) {
      vx *= friction;
    }
  }

  // Gestion de l'affichage du joueur.
  void afficher() {
    
    if (aligneDroite) {
      spriteCourse.mirroir = false; // L'animation de course n'est pas inversée puisque par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = false; // Même remarque ici
      spriteSaut.mirroir = false;
      spriteTombe.mirroir = false;
    } else {
      spriteCourse.mirroir = true; // On inverse l'animation de course car par défaut elle est orientée vers la droite.
      spriteImmobile.mirroir = true; // Même remarque ici;
      spriteSaut.mirroir = true;
      spriteTombe.mirroir = true;
    }

    // Chute libre.
    if (vy > 0) {
      // On actualise les coordonnées du sprite sur celle du joueur.
      // Cela permet de séparer l'actualisation de la physique et l'actualisation de l'affichage.
      // La class Sprite n'est ni plus ni moins un sytème d'animation/affichage d'images,
      // ce qui n'a rien avoir avec la physique du jeu.
      spriteTombe.changeCoordonnee(x, y);
      // On affiche l'animation de fin de saut.
      spriteTombe.afficher();
    }
    // En montée.
    else if (vy < 0) {
      spriteSaut.changeCoordonnee(x, y);
      // On affiche l'animation de saut.
      spriteSaut.afficher();
    } 
    // Lorsque le joueur court.
    else if (enDeplacement) {
      spriteCourse.changeCoordonnee(x, y);
      // On affiche l'animation de course
      spriteCourse.afficher();
    } 
    // Lorsque le joueur n'effectue aucune action.
    else {
      spriteImmobile.changeCoordonnee(x, y);
      // On affiche l'animation par défaut
      spriteImmobile.afficher();
    }


    //************** DEBUGAGE ************//
    if (debug) {
      // Affichage de la hitbox du joueur
      noFill();
      stroke(255, 0, 0);
      rectMode(CENTER);
      rect(x, y, w, h);
    }
  }

  // Permet de gérer les actions du joueur en fonction de la touche appuyée.
  void keyPressed() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Gestion du saut si le joueur se trouve sur une plateforme.
    if (k == 'Z' && surPlateforme) { 
      vy = -forceSaut; // On applique une force verticale pour propulser le joueur en l'air.
      surPlateforme = false; // On quite la plateforme.
      sonSaut.play(); // On lance le son du saut.
    } 
    // Gestion du déplacement vers la droite.
    else if (k == 'D') {
      enDeplacement = true; // On est en train de se déplacer.
      vx = vitesseDeplacement; // On se déplace à une vitesse constante vers la droite.
      aligneDroite = true; // Le joueur est tourné vers la droite.
    } 
    // Gestion du déplacment vers la gauche
    else if (k == 'Q') {
      enDeplacement = true; // On est en train de se déplacer. 
      vx = -vitesseDeplacement; // On se déplace à une vitesse constante vers la gauche.
      aligneDroite = false; // Le joueur est tourné vers la gauche.
    } 
    // Le joueur veut descendre de la plateforme.
    else if(k == 'S'){
      descendPlateforme = true;  
    } 
    // ************************************ DEBUGAGE **************************//
    else if(k == 'E'){
      joueur.vy = -forceSaut/2;
      joueur.vx = aligneDroite ? -vitesseDeplacement : vitesseDeplacement; 
      surPlateforme = false;
    } 
  }

  // Permet de gérer les actions du joueur en fonction de la touche relachée.
  void keyReleased() {
    // On passe en majuscule la touche pour rendre les tests insensibles à la case.
    char k = Character.toUpperCase((char) key);

    // Si on arrête le déplacement si on lache les touches pour se déplacer.
    if (k == 'D' || k == 'Q') {
      enDeplacement = false;
    } 
    // Le joueur ne veut plus descendre des plateformes.
    else if(k == 'S'){
      descendPlateforme = false;  
    }
  }


  // Permet d'initialiser le joueur dans les niveaux tout en conservant se progression.
  void initNiveau(float tx, float ty) {
    // On place le joueur.
    x = tx;
    y = ty;

    // Le joueur n'a pas de vitesse initiale.
    vx = 0;
    vy = 0;

    // Le joueur n'a pas encore effectué d'actions.
    surPlateforme = false;
    enDeplacement = false;
    enAttaqueProche = false;
    enAttaqueLongue = false;
    sonSaut.stop();
  }
}
