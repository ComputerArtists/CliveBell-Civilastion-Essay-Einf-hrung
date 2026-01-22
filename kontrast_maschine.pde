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
float minZoom = 0.33;
float maxZoom = 3.0;
float panX = 0;
float panY = 0;
boolean panMode = false;
boolean autoZoomMode = false;

// Kontrast-Maschine
float balance = width/2;  // MouseX steuert diesen Wert (links = schlecht, rechts = gut)
float machineSpeed = 1.0;

// Partikel (fließen von links nach rechts)
int numParticles = 300;
float[] pX = new float[numParticles];
float[] pY = new float[numParticles];
float[] pVX = new float[numParticles];
float[] pVY = new float[numParticles];
color[] pCol = new color[numParticles];
String[] pTxt = new String[numParticles];
boolean[] pGood = new boolean[numParticles];  // Gut oder schlecht?

void setup() {
  size(900, 600);
  surface.setTitle("Kontrast-Maschine: Schlechte vs. gute Zustände – Clive Bell");
  
  selectInput("Hintergrund-Bild (optional):", "imageSelected");
  
  particleTexts = loadStrings("particle_texts.txt");
  if (particleTexts == null || particleTexts.length == 0) {
    particleTexts = new String[]{"Fear", "Pain", "Greed", "Ecstasy", "Joy", "Clarity", "Love"};
  }
  
  font = createFont("Arial Black", 28);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  initParticles();
}

void generateColors() {
  randomColors = new color[numColors];
  // wie in vorherigen Skripten (Random, Kandinsky, Kriegs, Pelican)
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

void initParticles() {
  for (int i = 0; i < numParticles; i++) {
    pX[i] = random(width);
    pY[i] = random(height);
    pVX[i] = random(-1.5, 3.5);  // Tendenz nach rechts
    pVY[i] = random(-1, 1);
    if (random(1) < 0.5) {
      // Schlecht (links)
      pCol[i] = color(random(100, 180), random(20, 80), random(20, 80));
      pGood[i] = false;
      pTxt[i] = particleTexts[int(random(3))];  // Negative Texte
    } else {
      // Gut (rechts)
      pCol[i] = color(random(150, 255), random(150, 255), random(200, 255));
      pGood[i] = true;
      pTxt[i] = particleTexts[int(random(3, particleTexts.length))];
    }
  }
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = requestImage(selection.getAbsolutePath());
  }
}

void draw() {
  if (!paused) time += 0.025;
  
  colorPhase += 0.005;
  if (colorPhase >= 1) {
    colorPhase = 0;
    currentColorIndex = (currentColorIndex + 1) % numColors;
  }
  background(lerpColor(randomColors[currentColorIndex], randomColors[(currentColorIndex+1)%numColors], colorPhase));
  
  if (bgImage != null && bgImage.width > 0) {
    pushMatrix();
    translate(width/2 + panX, height/2 + panY);
    scale(zoomLevel);
    translate(-width/2, -height/2);
    tint(255, 110);
    image(bgImage, 0, 0);
    noTint();
    popMatrix();
  }
  
  // Balance durch MouseX
  balance = mouseX;
  
  // Maschine in der Mitte (Zahnräder + Pfeil)
  fill(200, 180, 60, 220);
  stroke(160);
  strokeWeight(6);
  ellipse(width/2, height/2, 180, 180);  // Großes Zahnrad
  for (int a = 0; a < 360; a += 30) {
    float rad = radians(a + time*30);
    line(width/2 + cos(rad)*90, height/2 + sin(rad)*90,
         width/2 + cos(rad)*110, height/2 + sin(rad)*110);
  }
  // Pfeil nach rechts
  fill(255, 220, 80, 200);
  triangle(width/2 + 80, height/2 - 40, width/2 + 140, height/2, width/2 + 80, height/2 + 40);
  
  // Partikel bewegen sich tendenziell nach rechts (Maschine pumpt)
  for (int i = 0; i < numParticles; i++) {
    pX[i] += pVX[i] * (1 + (balance - width/2)/width * 2);  // Je weiter rechts, desto schneller nach rechts
    pY[i] += pVY[i] + sin(time + i)*0.2;
    
    // Wenn Partikel rechts rauskommt → reset links + ggf. positiv machen
    if (pX[i] > width + 50) {
      pX[i] = -50;
      pY[i] = random(height);
      if (random(1) < 0.7) {  // Wahrscheinlichkeit, „verbessert“ zu werden
        pGood[i] = true;
        pCol[i] = color(random(150, 255), random(150, 255), random(200, 255));
        pTxt[i] = particleTexts[int(random(3, particleTexts.length))];
      }
    }
    
    fill(pCol[i], 160);
    noStroke();
    ellipse(pX[i], pY[i], 8 + sin(time*6 + i)*3, 8 + cos(time*6 + i)*3);
    
    fill(255, 140);
    textSize(12);
    text(pTxt[i], pX[i] + 12, pY[i]);
  }
  
  // Links = schlechte Zone (dunkel, chaotisch)
  fill(40, 20, 20, 80);
  rect(0, 0, balance, height);
  fill(255, 80);
  textSize(40);
  text("Schlechte Zustände", balance/2, height/2);
  
  // Rechts = gute Zone (hell, harmonisch)
  fill(200, 220, 255, 60);
  rect(balance, 0, width - balance, height);
  fill(0, 80);
  textSize(40);
  text("Gute Zustände", balance + (width - balance)/2, height/2);
  
  // Zoom-Logik
  if (autoZoomMode) {
    zoomLevel = 1.2 + sin(time * 0.5) * 1.0;
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
  }
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
}

void mousePressed() {
  // Maschine beschleunigt kurz
  machineSpeed = 3.0;
  // Partikel-Explosion in der Mitte
  for (int i = 0; i < numParticles; i++) {
    if (random(1) < 0.3) {
      pX[i] = width/2;
      pY[i] = height/2;
      pVX[i] = random(-5, 8);
      pVY[i] = random(-6, 3);
    }
  }
}

void mouseReleased() {
  machineSpeed = 1.0;
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') saveFrame("kontrast-maschine-####.png");
  if (key == 'r' || key == 'R') {
    time = 0;
    panX = panY = 0;
    zoomLevel = 1.0;
    initParticles();
  }
  if (key == 'l' || key == 'L') selectInput("Neues Bild:", "imageSelected");
  if (key == 'p' || key == 'P') paused = !paused;
  if (key == 'c' || key == 'C') generateColors();
  if (key == 'w' || key == 'W') {
    colorMode = (colorMode + 1) % 4;
    generateColors();
  }
  if (key == 'z' || key == 'Z') {
    panMode = !panMode;
    autoZoomMode = false;
  }
  if (key == 'q' || key == 'Q') {
    autoZoomMode = !autoZoomMode;
    panMode = false;
  }
}
