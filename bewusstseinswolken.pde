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

// Wolken
int numClouds = 12;
float[] cloudX = new float[numClouds];
float[] cloudY = new float[numClouds];
float[] cloudSize = new float[numClouds];
float[] cloudSpeed = new float[numClouds];
color[] cloudCol = new color[numClouds];
String[] cloudTxt = new String[numClouds];

// Partikel für Wolken-Explosion
int numParticles = 200;
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
  surface.setTitle("Bewusstseinswolken über Zivilisation – Clive Bell");
  
  selectInput("Hintergrund-Bild (Stadt/Landschaft empfohlen):", "imageSelected");
  
  particleTexts = loadStrings("particle_texts.txt");
  if (particleTexts == null || particleTexts.length == 0) {
    particleTexts = new String[]{"Ecstasy", "Contemplation", "Joy", "Love", "Clarity"};
  }
  
  font = createFont("Arial Black", 32);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  // Wolken initialisieren
  for (int i = 0; i < numClouds; i++) {
    cloudX[i] = random(width);
    cloudY[i] = height + random(200);  // Starten unten, außerhalb
    cloudSize[i] = random(80, 180);
    cloudSpeed[i] = random(0.5, 2.5);
    cloudCol[i] = color(random(150, 255), random(150, 255), random(200, 255), 140);
    cloudTxt[i] = particleTexts[int(random(particleTexts.length))];
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
  if (!paused) time += 0.02;
  
  // Farbwechsel
  colorPhase += 0.005;
  if (colorPhase >= 1) {
    colorPhase = 0;
    currentColorIndex = (currentColorIndex + 1) % numColors;
  }
  background(lerpColor(randomColors[currentColorIndex], randomColors[(currentColorIndex+1)%numColors], colorPhase));
  
  // Zivilisationslandschaft (Hintergrund-Bild oder einfache Skyline)
  if (bgImage != null && bgImage.width > 0) {
    pushMatrix();
    translate(width/2 + panX, height/2 + panY);
    scale(zoomLevel);
    translate(-width/2, -height/2);
    tint(255, 140);
    image(bgImage, 0, 0);
    noTint();
    popMatrix();
  } else {
    // Fallback: einfache Stadt-Skyline
    fill(80, 120);
    rect(0, height*0.6, width, height*0.4);
    for (int i = 0; i < 20; i++) {
      fill(100 + i*8);
      rect(i*45, height*0.6 + random(-50,50), 40, random(80, 300));
    }
  }
  
  // Bewusstseinswolken aufsteigen
  for (int i = 0; i < numClouds; i++) {
    cloudY[i] -= cloudSpeed[i] * (1 + sin(time + i)*0.3);
    
    // Wenn Wolke oben raus ist → zurücksetzen unten
    if (cloudY[i] < -cloudSize[i]*2) {
      cloudY[i] = height + random(200);
      cloudX[i] = random(width);
      cloudSpeed[i] = random(0.5, 2.5);
      cloudTxt[i] = particleTexts[int(random(particleTexts.length))];
    }
    
    float pulse = sin(time * 3 + i) * 0.5 + 0.5;
    fill(lerpColor(cloudCol[i], color(255,240,100), pulse), 100 + pulse*140);
    noStroke();
    ellipse(cloudX[i], cloudY[i], cloudSize[i] + pulse*30, cloudSize[i]*0.6 + pulse*20);
    
    // Text in der Wolke
    fill(255, 180 + pulse*75);
    textSize(16 + pulse*8);
    text(cloudTxt[i], cloudX[i], cloudY[i]);
    
    // Kleine Verbindungen zu anderen Wolken (Kandinsky-Feeling)
    for (int j = 0; j < numClouds; j++) {
      if (j != i && dist(cloudX[i], cloudY[i], cloudX[j], cloudY[j]) < 200) {
        stroke(255, 60);
        line(cloudX[i], cloudY[i], cloudX[j], cloudY[j]);
      }
    }
  }
  
  // Wolken-Explosion bei Klick
  if (mousePressed && !exploding) {
    exploding = true;
    explodeTimer = 0;
    int nearest = 0;
    float minDist = 9999;
    for (int i = 0; i < numClouds; i++) {
      float d = dist(mouseX, mouseY, cloudX[i], cloudY[i]);
      if (d < minDist) {
        minDist = d;
        nearest = i;
      }
    }
    // Explosion an Position der nächsten Wolke
    for (int i = 0; i < numParticles; i++) {
      pX[i] = cloudX[nearest];
      pY[i] = cloudY[nearest];
      pVX[i] = random(-7, 7);
      pVY[i] = random(-10, 2);
      pCol[i] = color(random(180, 255), random(180, 255), random(200, 255));
      pTxt[i] = particleTexts[int(random(particleTexts.length))];
    }
  }
  
  if (exploding) {
    explodeTimer += 0.05;
    if (explodeTimer > 2) exploding = false;
    for (int i = 0; i < numParticles; i++) {
      pX[i] += pVX[i];
      pY[i] += pVY[i];
      pVY[i] += 0.08;
      fill(pCol[i], map(explodeTimer, 0, 2, 255, 0));
      noStroke();
      ellipse(pX[i], pY[i], 8 + random(4), 8 + random(4));
      
      fill(255, map(explodeTimer, 0, 2, 220, 0));
      textSize(12 + random(6));
      text(pTxt[i], pX[i] + 10, pY[i]);
    }
  }
  
  // Zoom-Logik
  if (autoZoomMode) {
    zoomLevel = 1.2 + sin(time * 0.5) * 1.0;
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
  }
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') saveFrame("bewusstseinswolken-####.png");
  if (key == 'r' || key == 'R') {
    time = 0;
    panX = panY = 0;
    zoomLevel = 1.0;
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
