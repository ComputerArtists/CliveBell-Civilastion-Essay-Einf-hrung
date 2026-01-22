PImage bgImage = null;
PFont font;
String[] goals;
float time = 0;
float timelinePos = 0;
boolean paused = false;

// Farbwechsel
color[] randomColors;
int numColors = 5;
int currentColorIndex = 0;
float colorPhase = 0;

// Zoom & Pan
float zoomLevel = 1.0;
float minZoom = 0.01;
float maxZoom = 3.0;
float panX = 0;
float panY = 0;
boolean panMode = false;

void setup() {
  size(900, 600);
  surface.setTitle("Timeline der Kriegsziele – Clive Bell Style");
  
  selectInput("Wähle Hintergrund-Bild:", "imageSelected");
  
  goals = loadStrings("goals.txt");
  if (goals == null || goals.length == 0) {
    goals = new String[]{
      "Justice for Belgium",
      "Crusade against Antichrist (Kaiser)",
      "Reject Nietzsche's Imperialism",
      "Fight for Civilization"
    };
  }
  
  font = createFont("Arial Black", 36);
  textFont(font);
  textAlign(CENTER);
  
  randomColors = new color[numColors];
  for (int i = 0; i < numColors; i++) {
    randomColors[i] = color(random(50, 220), random(50, 220), random(50, 220));
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
    // timelinePos jetzt im Bereich 0 bis goals.length (loopbar)
    timelinePos = (time % (goals.length * 5)) / 5.0;
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
  
  // Timeline-Linie (fix)
  stroke(255);
  strokeWeight(8);
  line(100, height/2, width - 100, height/2);
  
  // Dynamische Positionierung für beliebige Anzahl von goals
  if (goals.length > 0) {
    float spacing = (width - 200) / max(1, goals.length - 1.0);
    
    for (int i = 0; i < goals.length; i++) {
      float x = 100 + i * spacing;
      
      // Fade basierend auf Distanz zur aktuellen Phase
      float dist = abs(timelinePos - i);
      float fadeDist = min(dist, goals.length - dist); // für Loop-Effekt
      float alpha = map(constrain(1.5 - fadeDist, 0, 1.5), 0, 1.5, 0, 255);
      
      fill(255, alpha);
      text(goals[i], x, height/2 + 60);
      
      // Symbole zyklisch wiederholen (Mod 4)
      if (alpha > 50) {
        fill(255, 255, 0, alpha);
        int symIdx = i % 4;
        float symSize = 40;
        
        if (symIdx == 0) ellipse(x, height/2 - 50, symSize, symSize);          // Waage
        else if (symIdx == 1) triangle(x - 20, height/2 - 60, x, height/2 - 20, x + 20, height/2 - 60); // Kreuz
        else if (symIdx == 2) rect(x - 20, height/2 - 60, symSize, symSize);   // Buch
        else ellipse(x, height/2 - 50, symSize + 10, symSize + 10);            // Globus
      }
    }
  }
  
  // Ironischer End-Text (wenn wir nah am letzten Ziel sind)
  if (timelinePos > goals.length - 1.5) {
    fill(255, 0, 0, map(timelinePos - (goals.length - 1.5), 0, 1.5, 0, 255));
    text("...at millions a day", width/2, height - 50);
  }
  
  if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
    zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
  }
}

void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("timeline-####.png");
    println("Screenshot gespeichert!");
  }
  if (key == 'r' || key == 'R') {
    time = 0;
    timelinePos = 0;
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
    for (int i = 0; i < numColors; i++) {
      randomColors[i] = color(random(50, 220), random(50, 220), random(50, 220));
    }
    colorPhase = 0;
    currentColorIndex = 0;
    println("Neue Farbpalette!");
  }
  if (key == 'z' || key == 'Z') {
    panMode = !panMode;
    println(panMode ? "Pan-Modus aktiviert" : "Zoom-Modus aktiviert");
  }
}
