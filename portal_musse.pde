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

// Portal-Parameter
float portalProgress = 0.0;  // 0 = links (Not), 1 = rechts (Muße/Kontemplation)
float figureX = 0;

// Partikel für Übergang / Ekstase
int numParticles = 220;
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
  surface.setTitle("Portal der Muße – Clive Bell");
  
  selectInput("Hintergrund-Bild (optional):", "imageSelected");
  
  particleTexts = loadStrings("particle_texts.txt");
  if (particleTexts == null || particleTexts.length == 0) {
    particleTexts = new String[]{"Muße", "Ekstase", "Kontemplation", "Schönheit", "Freiheit"};
  }
  
  font = createFont("Arial Black", 36);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  // Partikel vorbereiten
  for (int i = 0; i < numParticles; i++) {
    pCol[i] = color(255);
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
  
  // Portal-Fortschritt durch MouseX
  portalProgress = map(mouseX, 0, width, 0, 1);
  portalProgress = constrain(portalProgress, 0, 1);
  
  // Links: Gefesselte Figur (Not, Sklaverei)
  pushMatrix();
  translate(width*0.25, height*0.6);
  scale(1.2 - portalProgress*0.4);  // Wird kleiner, wenn Fortschritt
  fill(80, 60, 60);
  ellipse(0, -80, 80, 100);  // Kopf
  rect(-40, -40, 80, 120);   // Körper
  stroke(120);
  strokeWeight(6);
  line(-60, -20, -100, 40);  // Kette links
  line(60, -20, 100, 40);    // Kette rechts
  fill(200, 40);
  textSize(24);
  text("Not / Arbeit", 0, 100);
  popMatrix();
  
  // Portal in der Mitte (Zivilisation)
  float portalX = width/2;
  float portalY = height/2;
  fill(lerpColor(color(40,40,80), color(200,220,255), portalProgress), 160);
  noStroke();
  ellipse(portalX, portalY, 320 + sin(time*2)*20, 400 + cos(time*2)*30);
  stroke(255, 180 + sin(time*3)*75);
  strokeWeight(12);
  noFill();
  ellipse(portalX, portalY, 340, 420);
  fill(255, 220);
  textSize(40);
  text("ZIVILISATION", portalX, portalY - 20);
  textSize(24);
  text("Muße • Bildung • Sicherheit", portalX, portalY + 20);
  
  // Rechts: Kontemplative Figur (guter Zustand)
  pushMatrix();
  translate(width*0.75, height*0.6);
  scale(0.8 + portalProgress*0.6);  // Wird größer bei Fortschritt
  fill(lerpColor(color(120,120,120), color(255,240,100), portalProgress));
  ellipse(0, -80, 90, 110);  // Kopf
  rect(-50, -50, 100, 140);  // Körper
  noStroke();
  fill(255, 180);
  ellipse(0, -100, 40, 40);  // Leuchtendes Auge / Kontemplation
  fill(255, 140);
  textSize(24);
  text("Muße", 0, 100);
  popMatrix();
  
  // Partikel-Übergang durch das Portal
  if (random(1) < 0.08) {
    int idx = int(random(numParticles));
    pX[idx] = width*0.25 + random(-80, 80);
    pY[idx] = height*0.6 + random(-100, 100);
    pVX[idx] = random(2, 6);  // Nach rechts
    pVY[idx] = random(-1.5, 1.5);
    pCol[idx] = lerpColor(color(140,40,40), color(200,220,255), portalProgress);
    pTxt[idx] = particleTexts[int(random(particleTexts.length))];
  }
  
  // Partikel zeichnen
  for (int i = 0; i < numParticles; i++) {
    pX[i] += pVX[i];
    pY[i] += pVY[i];
    pVY[i] += 0.03;
    fill(pCol[i], 160);
    noStroke();
    ellipse(pX[i], pY[i], 6 + sin(time*5 + i)*3, 6 + cos(time*5 + i)*3);
    
    fill(255, 140);
    textSize(12);
    text(pTxt[i], pX[i] + 10, pY[i]);
  }
  
  // Explosion bei Klick (Ekstase beim Durchschreiten)
  if (mousePressed && !exploding) {
    exploding = true;
    explodeTimer = 0;
    for (int i = 0; i < numParticles; i++) {
      pX[i] = width/2;
      pY[i] = height/2;
      pVX[i] = random(-8, 8);
      pVY[i] = random(-10, 0);
      pCol[i] = color(random(180, 255), random(180, 255), random(220, 255));
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
      ellipse(pX[i], pY[i], 10 + random(6), 10 + random(6));
      
      fill(255, map(explodeTimer, 0, 2, 220, 0));
      textSize(14 + random(6));
      text(pTxt[i], pX[i] + 12, pY[i]);
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
  if (key == 's' || key == 'S') saveFrame("portal-musse-####.png");
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
