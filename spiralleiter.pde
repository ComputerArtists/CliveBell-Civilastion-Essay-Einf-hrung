PImage bgImage = null;
PFont font;
String[] particleTexts;
float time = 0;
boolean paused = false;

// Farbwechsel & Modi
color[] randomColors;
int numColors = 5;
int currentColorIndex = 0;
float colorPhase = 0;
int colorMode = 0;

// Zoom & Pan
float zoomLevel = 1.0;
float minZoom = 0.33;  // Beschränkt auf 33%
float maxZoom = 3.0;   // Bis 300%
float panX = 0;
float panY = 0;
boolean panMode = false;
boolean autoZoomMode = false;

// Spirale & Aufstieg
float spiralOffset = 0;
float scrollSpeed = 0.8;

// Partikel
int numParticles = 180;
float[] pX = new float[numParticles];
float[] pY = new float[numParticles];
float[] pVX = new float[numParticles];
float[] pVY = new float[numParticles];
color[] pCol = new color[numParticles];
String[] pTxt = new String[numParticles];
boolean exploding = false;
float explodeTimer = 0;

void setup() {
  size(900, 600);
  surface.setTitle("Verbesserte Spiralleiter zu guten Geisteszuständen – Clive Bell");
  
  selectInput("Hintergrund-Bild (optional):", "imageSelected");
  
  particleTexts = loadStrings("particle_texts.txt");
  if (particleTexts == null || particleTexts.length == 0) {
    particleTexts = new String[]{"Ecstasy", "Joy", "Contemplation"};
  }
  
  font = createFont("Arial Black", 36);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  for (int i = 0; i < numParticles; i++) {
    pCol[i] = color(160, 130, 90);
    pTxt[i] = "";
  }
}

void generateColors() {
  randomColors = new color[numColors];
  if (colorMode == 0) {
    for (int i = 0; i < numColors; i++) randomColors[i] = color(random(60, 240), random(60, 240), random(60, 240));
  } else if (colorMode == 1) {
    randomColors[0] = color(255,0,0); randomColors[1] = color(0,0,255);
    randomColors[2] = color(255,255,0); randomColors[3] = color(0);
    randomColors[4] = color(255);
  } else if (colorMode == 2) {
    randomColors[0] = color(140,0,0); randomColors[1] = color(60,60,60);
    randomColors[2] = color(180,40,40); randomColors[3] = color(80,80,80);
    randomColors[4] = color(200,60,60);
  } else if (colorMode == 3) {
    randomColors[0] = color(255,220,0); randomColors[1] = color(0);
    randomColors[2] = color(220,180,60); randomColors[3] = color(40,40,40);
    randomColors[4] = color(255,200,100);
  }
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = requestImage(selection.getAbsolutePath());
  }
}

void draw() {
  if (!paused) {
    time += 0.02;
    spiralOffset += scrollSpeed;  // Auto-Aufstieg
  }
  
  colorPhase += 0.005;
  if (colorPhase >= 1) {
    colorPhase = 0;
    currentColorIndex = (currentColorIndex + 1) % numColors;
  }
  background(lerpColor(randomColors[currentColorIndex], randomColors[(currentColorIndex+1)%numColors], colorPhase));
  
  // Hintergrund-Bild (in der Fläche bleiben – Zoom beeinflusst es, aber bleibt zentriert)
  if (bgImage != null && bgImage.width > 0) {
    pushMatrix();
    translate(width/2 + panX, height/2 + panY);
    scale(zoomLevel);
    translate(-width/2, -height/2);
    tint(255, 120);
    image(bgImage, 0, 0);
    noTint();
    popMatrix();
  }
  
  pushMatrix();
  translate(width/2, height - 100);  // Spirale von unten starten
  
  // Verbesserte Spirale (offener, nicht zu dicht, umgedreht – richtig orientiert)
  float turns = 6;  // Weniger Windungen für offeneren Look
  int steps = 300;  // Weniger Schritte für Klarheit
  stroke(180, 120);
  strokeWeight(6);
  noFill();
  beginShape();
  for (int i = 0; i < steps; i++) {
    float angle = map(i, 0, steps, 0, turns * TWO_PI) + spiralOffset * 0.05;  // Umgedreht durch + statt -
    float r = map(i, 0, steps, 50, 200);  // Kleinerer Radius-Bereich für weniger Dichte
    float x = cos(angle) * r * 0.8;  // Skalierung für bessere Anordnung
    float y = sin(angle) * r * 0.8 - i * 3;  // Höherer vertikaler Schritt für Aufstieg
    vertex(x, y);
    
    // Symbole entlang der Spirale (besser platziert, ausgerichtet)
    if (i % 35 == 0) {
      float progress = map(i, 0, steps, 0, 1);
      fill(lerpColor(color(80), color(255,220,100), progress), 180);
      textSize(18 + progress*20);
      pushMatrix();
      translate(x, y);
      rotate(angle + PI/2);  // Ausrichten entlang der Spirale
      text(getSymbol(i/35), 0, 0);
      popMatrix();
    }
  }
  endShape();
  
  // Kleine Abwärts-Treppe (Barbarismus-Kontrast, links unten in der Fläche)
  stroke(100, 40, 40, 160);
  strokeWeight(4);
  for (int i = 0; i < 50; i++) {
    float y = height/2 - 100 + i * 12;  // Von oben nach unten
    float x = -width/3 + sin(i*0.25)*15;
    line(x-25, y, x+25, y);
    if (i % 7 == 0) {
      fill(140, 20, 20, 140);
      textSize(14);
      text("Fear / Pain", x, y+8);
    }
  }
  
  // Leuchtende Kugeln am oberen Ende
  for (int i = 0; i < 8; i++) {
    float ang = time * 0.35 + i * TWO_PI / 8;
    float rad = 90 + sin(time*2.5 + i)*25;
    float px = cos(ang) * rad;
    float py = sin(ang) * rad - 1200 - sin(time*0.7)*30;  // Höher positioniert
    float pulse = sin(time*3.5 + i)*0.5 + 0.5;
    fill(lerpColor(color(120,60,220), color(255,240,100), pulse), 160 + pulse*90);
    noStroke();
    ellipse(px, py, 60 + pulse*35, 60 + pulse*35);
    
    fill(255, 180);
    textSize(14);
    text("Good State", px, py);
  }
  
  popMatrix();
  
  // Bröckeln
  if (random(1) < 0.07) {
    int idx = int(random(numParticles));
    pX[idx] = width/2 + random(-200, 200);
    pY[idx] = height/2 - 400 + random(-150, 150);
    pVX[idx] = random(-3, 3);
    pVY[idx] = random(1, 4);  // Nach unten fallen
    pCol[idx] = color(160, 130, 90);
    pTxt[idx] = particleTexts[int(random(particleTexts.length))];
  }
  
  // Explosion bei Klick
  if (mousePressed && !exploding) {
    exploding = true;
    explodeTimer = 0;
    for (int i = 0; i < numParticles; i++) {
      if (random(1) < 0.5) {
        pX[i] = width/2;
        pY[i] = height/2 - 500;
        pVX[i] = random(-8, 8);
        pVY[i] = random(-9, -1);
        pCol[i] = color(random(180, 255), random(180, 255), random(100, 220));
        pTxt[i] = particleTexts[int(random(particleTexts.length))];
      }
    }
  }
  
  // Partikel zeichnen
  if (exploding || random(1) < 0.15) {
    explodeTimer += 0.04;
    if (explodeTimer > 2) exploding = false;
    for (int i = 0; i < numParticles; i++) {
      pX[i] += pVX[i];
      pY[i] += pVY[i];
      pVY[i] += 0.1;
      fill(pCol[i], map(explodeTimer, 0, 2, 220, 0));
      noStroke();
      ellipse(pX[i], pY[i], 6 + random(4), 6 + random(4));
      
      fill(255, map(explodeTimer, 0, 2, 220, 0));
      textSize(12 + random(6));
      text(pTxt[i], pX[i] + 10, pY[i]);
    }
  }
  
  // Zoom
  if (autoZoomMode) {
    zoomLevel = 1.2 + sin(time * 0.4) * 1.1;
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
  }
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
  
  // Scroll-Speed mit MouseY beeinflussen
  scrollSpeed = map(mouseY, 0, height, 1.5, 0.3);  // Oben = schneller Aufstieg
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("spiralleiter-####.png");
    println("Screenshot!");
  }
  if (key == 'r' || key == 'R') {
    time = 0;
    spiralOffset = 0;
    panX = panY = 0;
    zoomLevel = 1.0;
    println("Reset!");
  }
  if (key == 'l' || key == 'L') {
    selectInput("Neues Hintergrund-Bild:", "imageSelected");
  }
  if (key == 'p' || key == 'P') {
    paused = !paused;
    println(paused ? "Pausiert" : "Fortgesetzt");
  }
  if (key == 'c' || key == 'C') {
    generateColors();
    println("Neue Farben!");
  }
  if (key == 'w' || key == 'W') {
    colorMode = (colorMode + 1) % 4;
    generateColors();
    println("Farbmodus: " + colorMode);
  }
  if (key == 'z' || key == 'Z') {
    panMode = !panMode;
    autoZoomMode = false;
    println(panMode ? "Pan-Modus" : "Zoom-Modus");
  }
  if (key == 'q' || key == 'Q') {
    autoZoomMode = !autoZoomMode;
    panMode = false;
    println(autoZoomMode ? "Auto-Zoom an" : "Auto-Zoom aus");
  }
}

// Symbol-Funktion
String getSymbol(int idx) {
  String[] syms = {"Factory", "Coin", "Scroll", "Sword", "Book", "Column", "Note", "Gear", "Canvas"};
  return syms[idx % syms.length];
}
