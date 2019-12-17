
// Un sound pool permet de garder en mémoire plusieurs petits fichier audio et lu en même temps, pratique pour les effets sonores
class MySoundPool {
  private SoundPool soundPool;

  MySoundPool() {
    // 2 façon d'initialiser un sound pool
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) { // Pour android > 5.0
      AudioAttributes audioAttributes = new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_GAME).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build();
      // 8 bruitages max en même temps est overkill mais fonctionne très bien.
      soundPool = new SoundPool.Builder().setMaxStreams(8).setAudioAttributes(audioAttributes).build();
    } else { // Pour android < 5
      // 8 bruitages max en même temps est overkill mais fonctionne très bien.
      soundPool = new SoundPool(8, AudioManager.STREAM_MUSIC, 0);
    }
  }

  int load(String path) {
    int id = 0;
    AssetFileDescriptor file;
    try {
      // Processing place tout ce qui est dans le dossier data dans le dosser assets
      // On doit donc y accèder via l'API android
      file = getContext().getAssets().openFd(path); 
      id = soundPool.load(file, 1); // on charge le son
    } 
    catch (IOException e) {
      e.printStackTrace();
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
    return id; // on renvoit l'id du son, pour pouvoir le jouer plus tard
  }

  void play(int id) {
    if (soundPool != null)
      soundPool.play(id, 1, 1, 1, 0, 1); // on lance le son, une fois lancé, le son est actualisé sur son propre thread
                                         // il peut donc être lancé plusieurs fois en même temps.
  }

  void release() {
    if (soundPool != null) {
      soundPool.autoPause(); // On met en pause tout les sons
      soundPool.release(); // On détruit en mémoire le soundPool
      soundPool = null;
    }
  }
}


// Permet de lire de long et gros fichier audio
class SoundFile {
  private MediaPlayer player;

  SoundFile(String path) {
    player = new MediaPlayer();
    AssetFileDescriptor file;
    try {
      file = getContext().getAssets().openFd(path); // On récupère le fichier audio
      player.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength()); // On charge le fichier audio en mémoire
    } 
    catch(IOException e) {
      e.printStackTrace();
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
    try {
      player.prepare(); // On se prépare a utiliser l'audio.
    } 
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  void loop() {
    if (player != null) {
      player.setLooping(true); // On autorise la répetition de la musique
      play(); // On lit la musique
    }
  }

  void play() {
    if (player != null) {
      try {
        player.stop(); // on arrete la musique
        player.prepare(); // on se prépare a lire la musique
        player.seekTo(0); // on revient au début du fichier audio
        player.start(); // on lit la musique
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
    }
  }

  void stop() {
    if (player != null)
      player.stop(); // on arrete la musique
  }

  void release() {
    if (player != null) {
      try {
        player.stop(); // on arrête la musqiue
        player.reset(); // on réinitialise le media player pour éviter les bugs
        player.release(); // on détruit le media player en mémoire
        player = null;
      } 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }
}
