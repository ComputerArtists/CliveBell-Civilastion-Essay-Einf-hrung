PImage bgImage = null;
PFont font;
String[] slogans;
float marchX = 0;       // Position der marschierenden Soldaten
float time = 0;

void setup() {
  size(900, 600);
  surface.setTitle("Marschierende Slogans – Civilization Propaganda Animation");
  
  // Hintergrund-Bild laden
  selectInput("Wähle Hintergrund (z.B. WWI-Poster, Pelican Cover oder Buchseite):", "imageSelected");
  
  // Slogans aus Datei
  slogans = loadStrings("slogans.txt");
  if (slogans == null || slogans.length == 0) {
    slogans = new String[]{
      "JOIN UP FOR CIVILIZATION'S SAKE",
      "FIGHT FOR LIBERTY AND JUSTICE",
      "SAVE CIVILIZATION FROM BARBARISM",
      "...and pay millions a day"
    };
  }
  
  font = createFont("Arial Black", 32);
  textFont(font);
  textAlign(CENTER);
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = loadImage(selection.getAbsolutePath());
    if (bgImage != null) bgImage.resize(width, height);
  }
}

void draw() {
  time += 0.02;
  marchX += 2.5;  // Marsch-Geschwindigkeit
  if (marchX > width + 800) marchX = -800;
  
  // Zyklischer Hintergrund: Schwarz → Gelb → Schwarz
  float bgPhase = (sin(time * 0.12) + 1) / 2;
  background(lerpColor(color(10), color(220, 200, 60), bgPhase));
  
  // Hintergrund-Bild overlay (getönt)
  if (bgImage != null) {
    tint(lerpColor(color(140, 40, 40, 140), color(255, 240, 100, 90), bgPhase));
    image(bgImage, 0, 0);
    noTint();
  }
  
  // Marschierende Soldaten (5–6 Figuren in einer Reihe, wiederholen)
  for (int row = 0; row < 3; row++) {  // Mehrere Reihen für Masse
    for (int i = 0; i < 8; i++) {
      float x = marchX + i * 120 + row * 40;  // Versatz pro Reihe
      float y = 220 + row * 140;
      
      fill(30, 200);
      rect(x, y, 60, 140);          // Körper
      ellipse(x + 30, y - 40, 50, 50);  // Kopf
      line(x + 10, y + 140, x - 10, y + 180);  // Bein links
      line(x + 50, y + 140, x + 70, y + 180);  // Bein rechts
      line(x, y + 60, x - 40, y + 100);        // Arm mit Gewehr
      line(x + 60, y + 60, x + 100, y + 40);   // Gewehr
    }
  }
  
  // Scrollende Slogans (von rechts nach links, verblassend)
  textSize(40);
  for (int i = 0; i < slogans.length; i++) {
    float alpha = map(sin(time * 3 + i * 2), -1, 1, 80, 255);
    fill(255, alpha);
    float txtX = width + 200 - (time * 60 + i * 400) % (width + 800);
    text(slogans[i], txtX, 100 + i * 60);
  }
  
  // Kleiner ironischer Fix-Text unten (Bell-Referenz)
  textSize(24);
  fill(220, 180);
  text("Fighting for civilization... at millions a day", width/2, height - 40);
  
  // Screenshot
  if (keyPressed && (key == 's' || key == 'S')) {
    saveFrame("marching-slogans-####.png");
    println("Animation-Frame gespeichert!");
  }
}
