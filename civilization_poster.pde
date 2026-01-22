PImage bgImage = null;
PFont boldFont;
String[] slogans;
float time = 0;

void setup() {
  size(800, 600);
  surface.setTitle("Satirisches Propaganda-Plakat – Civilization Essay");
  
  // Hintergrund-Bild auswählen
  selectInput("Wähle Hintergrund-Bild (z.B. Pelican Cover oder WWI-Poster):", "imageSelected");
  
  // Slogans laden
  slogans = loadStrings("slogans.txt");
  if (slogans == null || slogans.length < 3) {
    slogans = new String[]{
      "FIGHT FOR CIVILIZATION!",
      "JOIN UP FOR CIVILIZATION'S SAKE",
      "...and pay the price in millions a day"
    };
  }
  
  boldFont = createFont("Arial Black", 48); // Oder "Impact" für mehr Vintage-Look
  textFont(boldFont);
  textAlign(CENTER);
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = loadImage(selection.getAbsolutePath());
    if (bgImage != null) bgImage.resize(width, height);
  }
}

void draw() {
  time += 0.015;
  
  // Zyklischer Hintergrund: Schwarz → Gelb → Schwarz
  float bgPhase = (sin(time * 0.15) + 1) / 2;
  background(lerpColor(color(0), color(240, 220, 60), bgPhase));
  
  // Geladenes Hintergrund-Bild (getönt für Stimmung)
  if (bgImage != null) {
    tint(lerpColor(color(160, 30, 30, 160), color(255, 220, 100, 100), bgPhase));
    image(bgImage, 0, 0);
    noTint();
  }
  
  // Gelbe→Rote Wolke (Explosion/Rauch-Effekt)
  float cycle = (time % 25) / 25; // 25 Sekunden Zyklus
  float cloudOpacity = 0;
  color cloudBase;
  if (cycle < 0.4) {          // Aufbau gelb (0-10s)
    cloudOpacity = cycle / 0.4;
    cloudBase = color(255, 240, 80);
  } else if (cycle < 0.6) {   // Halten & Übergang zu Rot (10-15s)
    cloudOpacity = 1;
    cloudBase = lerpColor(color(255, 240, 80), color(220, 40, 0), (cycle - 0.4)/0.2);
  } else {                    // Abbau rot → transparent (15-25s)
    cloudOpacity = 1 - (cycle - 0.6)/0.4;
    cloudBase = color(220, 40, 0);
  }
  
  noStroke();
  for (int i = 0; i < 15; i++) {
    float ang = i * TWO_PI / 15 + time * 0.4;
    float rad = 100 + sin(time * 1.5 + i*2) * 60;
    float x = width/2 + cos(ang) * rad;
    float y = height/2 - 100 + sin(ang * 1.2) * rad * 0.7;
    fill(red(cloudBase), green(cloudBase), blue(cloudBase), cloudOpacity * 130);
    ellipse(x, y, 160 + sin(time*3 + i)*40, 160 + cos(time*3 + i)*40);
  }
  
  // Soldaten mit zeigendem Finger (direkt auf Betrachter)
  fill(20, 200);
  ellipse(400, 220, 110, 110);           // Kopf
  rect(370, 280, 60, 180);               // Körper
  triangle(460, 300, 540, 280, 540, 320); // Zeigender Arm + Finger
  line(400, 460, 360, 540);              // Bein links
  line(400, 460, 440, 540);              // Bein rechts
  
  // Texte (aus .txt)
  fill(255);
  textSize(54);
  text(slogans[0], width/2, 140);
  
  textSize(40);
  if ((frameCount / 2) % 80 < 40) {  // Etwas schnelleres Blinken
    fill(255, 220, 50);
    text(slogans[1], width/2, height - 110);
  }
  
  textSize(24);
  fill(230, 190);
  text(slogans[2], width/2, height - 40);
  
  // Screenshot
  if (keyPressed && (key == 's' || key == 'S')) {
    saveFrame("civilization-poster-####.png");
    println("Poster gespeichert!");
  }
}
