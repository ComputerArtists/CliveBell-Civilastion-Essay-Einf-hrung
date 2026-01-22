PImage bgImage = null;
PFont boldFont;
String[] slogans;
float time = 0;          // Für Animationen
float cloudBuild = 0;    // Aufbau der Wolke (0 → 1)
boolean cloudToRed = false;  // Phase: false = gelb aufbauen, true = zu rot wandeln

void setup() {
  size(800, 600);
  surface.setTitle("Satirisches WWI-Propaganda-Plakat – Clive Bell Style");
  
  // 1. Hintergrund-Bild laden via Dialog
  selectInput("Wähle ein Plakat-Hintergrund-Bild (JPG/PNG):", "imageSelected");
  
  // 2. Texte aus Datei laden
  slogans = loadStrings("slogans.txt");
  if (slogans == null || slogans.length == 0) {
    slogans = new String[]{"FIGHT FOR CIVILIZATION!", "JOIN UP FOR CIVILIZATION'S SAKE", "...and pay the price in millions a day"};
  }
  
  boldFont = createFont("Arial Black", 48);
  textFont(boldFont);
  textAlign(CENTER);
}

void imageSelected(File selection) {
  if (selection == null) {
    println("Kein Bild ausgewählt – nutze schwarzen Hintergrund.");
  } else {
    bgImage = loadImage(selection.getAbsolutePath());
    if (bgImage != null) {
      bgImage.resize(width, height);  // Zentriert skalieren
      println("Hintergrund geladen: " + selection.getName());
    }
  }
}

void draw() {
  time += 0.01;
  
  // Zyklischer Hintergrund-Farbwechsel: Schwarz → Gelb → Schwarz
  float bgPhase = (sin(time * 0.2) + 1) / 2;  // 0..1
  color bgColor = lerpColor(color(0), color(220, 220, 80), bgPhase);  // Schwarz zu Gelb
  background(bgColor);
  
  // Geladenes Plakat-Bild als getöntes Overlay (falls vorhanden)
  if (bgImage != null) {
    tint(lerpColor(color(180, 20, 20, 180), color(255, 255, 255, 120), bgPhase));  // Rot → neutral
    image(bgImage, 0, 0);
    noTint();
  }
  
  // 2. Gelbe Wolke aufbauen & zu Rot wandeln (zyklisch alle ~20 Sekunden)
  float cycle = (time % 20) / 20;  // 0..1 pro 20 Sekunden
  if (cycle < 0.5) {
    cloudBuild = cycle * 2;        // Aufbau 0→1 in ersten 10s
    cloudToRed = false;
  } else {
    cloudBuild = 1 - (cycle - 0.5) * 2;  // Abbau 1→0 in nächsten 10s
    cloudToRed = true;
  }
  
  // Wolken-Partikel (Explosionen / Rauch)
  noStroke();
  for (int i = 0; i < 12; i++) {
    float angle = i * TWO_PI / 12 + time * 0.3;
    float dist = 120 + sin(time + i) * 40;
    float x = width/2 + cos(angle) * dist;
    float y = height/2 - 80 + sin(angle) * dist * 0.6;
    
    color cloudColor;
    if (!cloudToRed) {
      cloudColor = color(255, 220, 80, cloudBuild * 120);  // Gelb → transparent
    } else {
      cloudColor = color(lerp(255, 200, cloudBuild), lerp(220, 0, cloudBuild), 0, cloudBuild * 140);  // Gelb → Rot
    }
    fill(cloudColor);
    ellipse(x, y, 140 + sin(time * 2 + i) * 30, 140 + cos(time * 2 + i) * 30);
  }
  
  // Soldaten-Figur mit zeigendem Finger (Kitchener-Style)
  fill(0, 220);
  rect(360, 280, 80, 220);                // Körper
  ellipse(400, 220, 100, 100);            // Kopf
  triangle(450, 300, 520, 320, 520, 280); // Zeigender Arm/Finger
  line(400, 500, 350, 560);               // Bein links
  line(400, 500, 450, 560);               // Bein rechts
  
  // Texte aus der .txt-Datei (Haupt-Slogan fix, Rest blinkend/zyklisch)
  fill(255);
  textSize(52);
  text(slogans[0], width/2, 140);  // Erster Text immer sichtbar
  
  textSize(38);
  if (frameCount % 80 < 40) {
    fill(255, 220, 60);
    text(slogans[1], width/2, height - 100);
  }
  
  textSize(22);
  fill(220, 180);
  text(slogans[2], width/2, height - 40);
  
  // Optional: Bild speichern mit s (Screenshot)
  if (keyPressed && key == 's') {
    saveFrame("propaganda-plakat-####.png");
    println("Gespeichert!");
  }
}
