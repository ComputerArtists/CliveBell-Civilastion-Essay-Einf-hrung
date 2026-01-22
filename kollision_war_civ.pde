PImage bgImage = null;
PFont font;
String[] slogans;
float time = 0;

// Partikel-Arrays für Explosion
int numParticles = 150;
float[] pX = new float[numParticles];
float[] pY = new float[numParticles];
float[] pVX = new float[numParticles];
float[] pVY = new float[numParticles];
boolean exploding = false;

void setup() {
  size(900, 600);
  surface.setTitle("Abstrakte Kollision: Krieg vs. Zivilisation");
  
  // Hintergrund laden
  selectInput("Wähle Hintergrund (Pelican Cover, Buchseite oder abstrakt):", "imageSelected");
  
  // Slogans laden
  slogans = loadStrings("slogans.txt");
  if (slogans == null || slogans.length < 2) {
    slogans = new String[]{
      "YOU ARE FIGHTING FOR CIVILIZATION",
      "...while destroying it"
    };
  }
  
  font = createFont("Arial Black", 48);
  textFont(font);
  textAlign(CENTER);
  
  // Partikel initialisieren
  for (int i = 0; i < numParticles; i++) {
    pX[i] = width/2;
    pY[i] = height/2;
    pVX[i] = random(-8, 8);
    pVY[i] = random(-10, 5);
  }
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = loadImage(selection.getAbsolutePath());
    if (bgImage != null) bgImage.resize(width, height);
  }
}

void draw() {
  time += 0.015;
  
  // Zyklischer Hintergrund: Dunkel → Rot/Gelb → Dunkel
  float phase = (sin(time * 0.18) + 1) / 2;
  background(lerpColor(color(20), color(180, 30, 30), phase));  // Dunkel zu Blutrot
  
  // Hintergrund-Bild (getönt, "zerbrechlich")
  if (bgImage != null) {
    tint(lerpColor(color(255, 100, 100, 140), color(255, 220, 80, 90), phase));
    image(bgImage, 0, 0);
    noTint();
  }
  
  // Zivilisations-Symbole (Bücher + Statue) – werden bei Explosion "zerstört" (verblassen/verschieben)
  float shake = exploding ? random(-5, 5) : 0;
  fill(220, 200);
  rect(180 + shake, 380, 120, 180);  // Buch 1
  rect(480 + shake, 380, 120, 180);  // Buch 2
  ellipse(400 + shake, 280, 180, 240);  // Statue/Kopf
  
  // Interaktive Bombe (Maus folgt)
  fill(255, 0, 0, 220);
  noStroke();
  ellipse(mouseX, mouseY, 60, 60);
  fill(255);
  ellipse(mouseX, mouseY, 20, 20);  // Zünder
  
  // Explosion-Partikel
  if (exploding) {
    for (int i = 0; i < numParticles; i++) {
      pX[i] += pVX[i];
      pY[i] += pVY[i];
      pVY[i] += 0.15;  // Gravitation
      fill(255, random(100, 255), 0, random(100, 220));
      ellipse(pX[i], pY[i], random(4, 12), random(4, 12));
    }
  }
  
  // Explosion triggern & reset
  if (mousePressed && !exploding) {
    exploding = true;
    for (int i = 0; i < numParticles; i++) {
      pX[i] = mouseX;
      pY[i] = mouseY;
      pVX[i] = random(-12, 12);
      pVY[i] = random(-15, -5);
    }
  }
  if (exploding && frameCount % 120 == 0) exploding = false;  // Nach ~2s reset
  
  // Haupt-Text Overlay (zynisch)
  fill(255);
  textSize(52);
  text(slogans[0], width/2, 120);
  
  textSize(32);
  fill(255, 220, 80);
  text(slogans[1], width/2, height - 60);
  
  // Screenshot
  if (keyPressed && (key == 's' || key == 'S')) {
    saveFrame("kollision-war-civ-####.png");
    println("Frame gespeichert!");
  }
}
