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

// Transformation
boolean transforming = false;
float transformProgress = 0;

// Werkzeuge (Positionen & Typen)
int numTools = 8;
float[] toolX = new float[numTools];
float[] toolY = new float[numTools];
String[] toolNames = {"Hammer", "Coin", "Law", "Shield", "Factory", "Book", "Gear", "Scale"};

// Partikel für Transformation
int numParticles = 250;
float[] pX = new float[numParticles];
float[] pY = new float[numParticles];
float[] pVX = new float[numParticles];
float[] pVY = new float[numParticles];
color[] pCol = new color[numParticles];
String[] pTxt = new String[numParticles];

void setup() {
  size(900, 600);
  surface.setTitle("Werkzeugkasten → Transformation in Kunst – Clive Bell");
  
  selectInput("Hintergrund-Bild (optional):", "imageSelected");
  
  particleTexts = loadStrings("particle_texts.txt");
  if (particleTexts == null || particleTexts.length == 0) {
    particleTexts = new String[]{"Ecstasy", "Contemplation", "Joy", "Significant Form"};
  }
  
  font = createFont("Arial Black", 36);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  // Werkzeuge initial platzieren (im Kasten)
  for (int i = 0; i < numTools; i++) {
    toolX[i] = width/2 - 120 + (i % 4)*80;
    toolY[i] = height - 180 + (i / 4)*80;
  }
}

void generateColors() {
  randomColors = new color[numColors];
  if (colorMode == 0) {
    for (int i = 0; i < numColors; i++) randomColors[i] = color(random(60, 240), random(60, 240), random(60, 240));
  } else if (colorMode == 1) { // Kandinsky
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
  
  // Werkzeugkasten (rechteckiger Kasten unten)
  fill(120, 80, 40, 220);
  stroke(80);
  strokeWeight(8);
  rect(width/2 - 200, height - 280, 400, 260, 20);
  
  // Werkzeuge zeichnen (vor Transformation)
  if (!transforming) {
    for (int i = 0; i < numTools; i++) {
      fill(lerpColor(color(180), color(255,220,80), sin(time + i)*0.5 + 0.5));
      textSize(28);
      text(toolNames[i], toolX[i], toolY[i]);
    }
    fill(255, 200);
    textSize(32);
    text("Civilization's Toolbox", width/2, height - 320);
  }
  
  // Transformation starten (automatisch alle 12 Sekunden oder bei Klick)
  if (!transforming && time % 12 < 0.1) {
    transforming = true;
    transformProgress = 0;
    initParticles();
  }
  
  if (transforming) {
    transformProgress += 0.015;
    if (transformProgress > 1) transforming = false;
    
    // Werkzeuge fliegen heraus & zerfallen
    for (int i = 0; i < numTools; i++) {
      toolX[i] += random(-3,3);
      toolY[i] -= 2 + random(3);  // Nach oben fliegen
      fill(255, map(transformProgress, 0, 1, 255, 0));
      text(toolNames[i], toolX[i], toolY[i]);
    }
    
    // Partikel & Kunst-Transformation
    for (int i = 0; i < numParticles; i++) {
      pX[i] += pVX[i];
      pY[i] += pVY[i];
      pVY[i] += 0.05;
      
      float fade = map(transformProgress, 0, 1, 255, 80);
      fill(pCol[i], fade);
      noStroke();
      ellipse(pX[i], pY[i], 8 + sin(time*5 + i)*4, 8 + cos(time*5 + i)*4);
      
      // Zufälliger Text als Kunst-Fragment
      fill(255, fade);
      textSize(12 + random(6));
      text(pTxt[i], pX[i] + 10, pY[i]);
    }
    
    // Finale Kunst-Komposition (Kandinsky-Style)
    if (transformProgress > 0.6) {
      pushMatrix();
      translate(width/2, height/2 - 100);
      rotate(time * 0.1);
      scale(1 + sin(time*2)*0.2);
      
      for (int j = 0; j < 12; j++) {
        float ang = j * TWO_PI / 12 + time * 0.3;
        float r = 80 + sin(time + j)*40;
        float px = cos(ang) * r;
        float py = sin(ang) * r;
        
        fill(lerpColor(color(255,200,0), color(0,100,255), sin(time + j)*0.5 + 0.5), 140);
        noStroke();
        ellipse(px, py, 50 + sin(time*4 + j)*20, 50 + cos(time*4 + j)*20);
        
        // Linien-Verbindungen (Kandinsky)
        stroke(255, 80);
        line(0, 0, px, py);
      }
      popMatrix();
    }
  }
  
  // Zoom-Logik
  if (autoZoomMode) {
    zoomLevel = 1.2 + sin(time * 0.5) * 1.1;
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
  }
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
}

void initParticles() {
  for (int i = 0; i < numParticles; i++) {
    pX[i] = width/2 + random(-180, 180);
    pY[i] = height - 200 + random(-80, 80);
    pVX[i] = random(-6, 6);
    pVY[i] = random(-8, -1);
    pCol[i] = color(random(150, 255), random(150, 255), random(80, 220));
    pTxt[i] = particleTexts[int(random(particleTexts.length))];
  }
}

void mousePressed() {
  if (!transforming) {
    transforming = true;
    transformProgress = 0;
    initParticles();
  }
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') saveFrame("werkzeug-transformation-####.png");
  if (key == 'r' || key == 'R') {
    time = 0;
    panX = panY = 0;
    zoomLevel = 1.0;
    transforming = false;
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
