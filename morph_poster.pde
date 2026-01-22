PImage bgImage = null;
PFont font;
String[] goals;
float time = 0;
boolean paused = false;

// Farbwechsel
color[] randomColors;
int numColors = 5;
int currentColorIndex = 0;
float colorPhase = 0;

// Farb-Modi (für Vorschlag 9)
int colorMode = 0;  // 0: Random, 1: Kandinsky (Primärfarben), 2: Kriegsrot/Grau, 3: Pelican-Gelb/Schwarz

// Zoom & Pan
float zoomLevel = 1.0;
float minZoom = 0.01;
float maxZoom = 3.0;
float panX = 0;
float panY = 0;
boolean panMode = false;
boolean autoZoomMode = false;  // Neuer Zoom-Modus (Vorschlag 1/2 mit 'q')

// Partikel für Form-Zerteilen (Vorschlag 5)
int numParticles = 200;
float[] partX = new float[numParticles];
float[] partY = new float[numParticles];
float[] partVX = new float[numParticles];
float[] partVY = new float[numParticles];
color[] partColor = new color[numParticles];
boolean exploding = false;
float explodeTime = 0;

void setup() {
  size(900, 600);
  surface.setTitle("Morphende Propagandaposter – Enhanced Kandinsky Style");
  
  selectInput("Wähle Hintergrund-Bild:", "imageSelected");
  
  goals = loadStrings("goals.txt");
  if (goals == null || goals.length == 0) {
    goals = new String[]{
      "Justice for Belgium",
      "Crusade against Antichrist",
      "Reject Nietzsche",
      "For Civilization"
    };
  }
  
  font = createFont("Arial Black", 48);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();  // Initiale Farben generieren
}

void generateColors() {
  randomColors = new color[numColors];
  if (colorMode == 0) {  // Random
    for (int i = 0; i < numColors; i++) {
      randomColors[i] = color(random(50, 220), random(50, 220), random(50, 220));
    }
  } else if (colorMode == 1) {  // Kandinsky: Primärfarben + Schwarz
    randomColors[0] = color(255, 0, 0);  // Rot
    randomColors[1] = color(0, 0, 255);  // Blau
    randomColors[2] = color(255, 255, 0);  // Gelb
    randomColors[3] = color(0);  // Schwarz
    randomColors[4] = color(255);  // Weiß
  } else if (colorMode == 2) {  // Kriegsrot/Grau
    randomColors[0] = color(150, 0, 0);
    randomColors[1] = color(50, 50, 50);
    randomColors[2] = color(100, 20, 20);
    randomColors[3] = color(200, 50, 50);
    randomColors[4] = color(80, 80, 80);
  } else if (colorMode == 3) {  // Pelican-Gelb/Schwarz
    randomColors[0] = color(255, 220, 0);
    randomColors[1] = color(0);
    randomColors[2] = color(200, 180, 50);
    randomColors[3] = color(50, 50, 50);
    randomColors[4] = color(255, 200, 80);
  }
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = requestImage(selection.getAbsolutePath());
  }
}

void draw() {
  if (!paused) {
    time += 0.025;
  }
  
  colorPhase += 0.005;
  if (colorPhase >= 1) {
    colorPhase = 0;
    currentColorIndex = (currentColorIndex + 1) % numColors;
  }
  
  color bgStart = randomColors[currentColorIndex];
  color bgEnd = randomColors[(currentColorIndex + 1) % numColors];
  background(lerpColor(bgStart, bgEnd, colorPhase));
  
  if (bgImage != null && bgImage.width > 0) {
    if (bgImage.width != width || bgImage.height != height) {
      bgImage.resize(width, height);
    }
    
    pushMatrix();
    translate(width/2 + panX, height/2 + panY);
    scale(zoomLevel);
    translate(-width/2, -height/2);
    
    tint(lerpColor(color(255, 200, 200, 140), color(255, 220, 80, 100), colorPhase));
    image(bgImage, 0, 0);
    noTint();
    popMatrix();
  }
  
  // 1. Fade-In/Out des Morph-Bereichs (Vorschlag 1)
  float globalAlpha = sin(time % 1 * PI) * 255;  // 0 → 255 → 0 pro Phase
  
  // Morphende Komposition
  int phase = floor(time % goals.length);
  float morph = time % 1;
  
  pushMatrix();
  translate(width/2, height/2 - 50);
  scale(1 + morph * 0.2);
  rotate(morph * PI / 8);
  
  // 3. Gradients & Semi-Transparenz (Vorschlag 3: in verschiedenen Ausführungen)
  int symCount = 4;
  for (int j = 0; j < symCount; j++) {
    float offset = j * TWO_PI / symCount + time * 0.1;
    float rad = 100 + sin(time + j) * 50;
    float xOff = cos(offset) * rad;
    float yOff = sin(offset) * rad;
    
    color symStart = lerpColor(color(255, 200, 0), color(200, 0, 0), morph + j * 0.2);
    color symEnd = lerpColor(symStart, color(0, 0, 255), morph);
    
    // Gradient-Fill (verschiedene Ausführungen: radial/linear)
    PGraphics grad = createGraphics(200, 200);
    grad.beginDraw();
    if (j % 2 == 0) {  // Radial Gradient
      for (int r = 0; r < 100; r++) {
        grad.stroke(lerpColor(symStart, symEnd, r / 100.0));
        grad.noFill();
        grad.ellipse(100, 100, r*2, r*2);
      }
    } else {  // Linear Gradient
      grad.noStroke();
      for (int y = 0; y < 200; y++) {
        grad.stroke(lerpColor(symStart, symEnd, y / 200.0));
        grad.line(0, y, 200, y);
      }
    }
    grad.endDraw();
    
    // Semi-Transparenz (versch. Levels: 50-150)
    tint(255, 50 + (j * 25));
    image(grad, xOff - 100, yOff - 100);
    noTint();
    
    int symIdx = (phase + j) % 4;
    fill(symStart, 100 + j*20);  // Semi-transparent
    noStroke();
    if (symIdx == 0) ellipse(xOff, yOff, 80 + sin(time) * 20, 80 + cos(time) * 20);
    else if (symIdx == 1) triangle(xOff - 40, yOff - 40, xOff, yOff + 40, xOff + 40, yOff - 40);
    else if (symIdx == 2) rect(xOff - 50, yOff - 50, 100, 100);
    else {
      line(xOff - 60, yOff, xOff + 60, yOff);
      ellipse(xOff, yOff, 60, 60);
    }
    
    if (j > 0) {
      stroke(255, 100);
      line(0, 0, xOff, yOff);
    }
  }
  popMatrix();
  
  // 2. Dynamische Textgröße & Zeilenumbruch (Vorschlag 2)
  float txtSize = 48;
  String currText = goals[phase];
  String nextText = goals[(phase + 1) % goals.length];
  if (textWidth(currText) > width * 0.8) {
    txtSize = 48 * (width * 0.8 / textWidth(currText));
  }
  textSize(txtSize);
  
  fill(255, map(morph, 0, 1, globalAlpha, 0));
  text(currText, width/2, height - 100);
  fill(255, map(morph, 0, 1, 0, globalAlpha));
  text(nextText, width/2, height - 100);
  
  if (phase == goals.length - 1) {
    fill(255, 0, 0, map(morph, 0, 1, 0, globalAlpha));
    text("...at millions a day", width/2, height - 50);
  }
  
  // Auto-Zoom-Modus (Vorschlag 1/2 mit 'q')
  if (autoZoomMode) {
    zoomLevel = 1.0 + sin(time * 0.5) * 1.5;  // Pulsierender Zoom 1-2.5x
    zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
    zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
  }
  
  // Explosion-Partikel (Vorschlag 5)
  if (exploding) {
    explodeTime += 0.05;
    if (explodeTime > 2) exploding = false;
    
    for (int i = 0; i < numParticles; i++) {
      partX[i] += partVX[i];
      partY[i] += partVY[i];
      partVY[i] += 0.1;  // Gravitation
      fill(partColor[i], map(explodeTime, 0, 2, 255, 0));
      ellipse(partX[i], partY[i], 8, 8);
    }
  }
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void mousePressed() {
  // 5. Form zerteilen bei mousePressed (Partikel-Explosion)
  exploding = true;
  explodeTime = 0;
  for (int i = 0; i < numParticles; i++) {
    partX[i] = width/2;
    partY[i] = height/2 - 50;
    partVX[i] = random(-5, 5);
    partVY[i] = random(-10, -2);
    partColor[i] = color(random(100, 255), random(100, 255), random(100, 255));
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("morph-poster-####.png");
    println("Screenshot gespeichert!");
  }
  if (key == 'r' || key == 'R') {
    time = 0;
    panX = 0;
    panY = 0;
    zoomLevel = 1.0;
    println("Reset!");
  }
  if (key == 'l' || key == 'L') {
    selectInput("Neues Hintergrund-Bild laden:", "imageSelected");
  }
  if (key == 'p' || key == 'P') {
    paused = !paused;
    println(paused ? "Pausiert" : "Fortgesetzt");
  }
  if (key == 'c' || key == 'C') {
    generateColors();  // Vorschlag 9: 'c' generiert neue Farben im aktuellen Modus
    println("Neue Farben im Modus " + colorMode + " generiert!");
  }
  if (key == 'w' || key == 'W') {
    colorMode = (colorMode + 1) % 4;  // Vorschlag 9: 'w' wechselt Farb-Modus
    generateColors();
    println("Farb-Modus gewechselt zu: " + colorMode);
  }
  if (key == 'z' || key == 'Z') {
    panMode = !panMode;
    autoZoomMode = false;  // Deaktiviere Auto-Zoom bei Pan
    println(panMode ? "Pan-Modus aktiviert" : "Zoom-Modus aktiviert");
  }
  if (key == 'q' || key == 'Q') {
    autoZoomMode = !autoZoomMode;
    panMode = false;  // Deaktiviere Pan bei Auto-Zoom
    println(autoZoomMode ? "Auto-Zoom-Modus aktiviert" : "Auto-Zoom deaktiviert");
  }
}
