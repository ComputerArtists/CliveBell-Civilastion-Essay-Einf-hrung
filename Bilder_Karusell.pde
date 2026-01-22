PImage bgImage = null;
PImage[] carouselImages;  // Alle Bilder aus dem Ordner
PFont font;
float time = 0;
boolean paused = false;

// Farbwechsel & Modi (wie zuvor)
color[] randomColors;
int numColors = 5;
int currentColorIndex = 0;
float colorPhase = 0;
int colorMode = 0;  // 0: Random, 1: Kandinsky, 2: Kriegsfarben, 3: Pelican

// Zoom & Pan (wie zuvor)
float zoomLevel = 1.0;
float minZoom = 0.01;
float maxZoom = 3.0;
float panX = 0;
float panY = 0;
boolean panMode = false;
boolean autoZoomMode = false;

// Karussell-Parameter
float rotationSpeed = 0.2;
float currentRotation = 0;
int focusPanel = 0;

// Partikel (wie zuvor)
int numParticles = 100;
float[] partX = new float[numParticles];
float[] partY = new float[numParticles];
float[] partVX = new float[numParticles];
float[] partVY = new float[numParticles];
color[] partColor = new color[numParticles];
boolean exploding = false;
float explodeTime = 0;

void setup() {
  size(900, 600);
  surface.setTitle("Karussell aus Ordner-Bildern – Pelican Pages");
  
  // Hintergrund (optional, wie zuvor)
  selectInput("Optionales Hintergrund-Bild (oder leer lassen):", "imageSelected");
  
  // 1. Bilder aus Ordner laden
  loadImagesFromFolder("/home/computerartist-thl/CliveBell/Essay-Civilisation/Introduktion/Bilder_Karusell/images");  // ← Hier deinen Ordnernamen ändern!
  
  if (carouselImages == null || carouselImages.length == 0) {
    println("Kein Ordner 'images' oder keine Bilder gefunden!");
    // Fallback: Leeres Karussell oder Test-Text
    carouselImages = new PImage[1];
    carouselImages[0] = createImage(1, 1, RGB);  // Dummy
  } else {
    println("Geladen: " + carouselImages.length + " Bilder aus Ordner");
  }
  
  font = createFont("Arial Black", 42);
  textFont(font);
  textAlign(CENTER);
  
  generateColors();
  
  // Partikel initialisieren
  for (int i = 0; i < numParticles; i++) {
    partColor[i] = color(255);
  }
}

void loadImagesFromFolder(String folderName) {
  java.io.File folder = new java.io.File(dataPath(folderName));
  if (!folder.exists() || !folder.isDirectory()) {
    println("Ordner '" + folderName + "' nicht gefunden!");
    return;
  }
  
  java.io.File[] files = folder.listFiles();
  ArrayList<PImage> imgList = new ArrayList<PImage>();
  
  for (java.io.File file : files) {
    if (file.isFile()) {
      String name = file.getName().toLowerCase();
      if (name.endsWith(".jpg") || name.endsWith(".jpeg") || 
          name.endsWith(".png") || name.endsWith(".gif") || name.endsWith(".tif")) {
        PImage img = loadImage(file.getAbsolutePath());
        if (img != null) {
          imgList.add(img);
        }
      }
    }
  }
  
  carouselImages = imgList.toArray(new PImage[imgList.size()]);
}

void generateColors() {
  randomColors = new color[numColors];
  // ... (wie im vorherigen Skript – Kandinsky, Kriegs, Pelican, Random)
  if (colorMode == 0) {
    for (int i = 0; i < numColors; i++) {
      randomColors[i] = color(random(50, 220), random(50, 220), random(50, 220));
    }
  } else if (colorMode == 1) {
    randomColors[0] = color(255, 0, 0); randomColors[1] = color(0, 0, 255);
    randomColors[2] = color(255, 255, 0); randomColors[3] = color(0);
    randomColors[4] = color(255);
  } else if (colorMode == 2) {
    randomColors[0] = color(150, 0, 0); randomColors[1] = color(50, 50, 50);
    randomColors[2] = color(100, 20, 20); randomColors[3] = color(200, 50, 50);
    randomColors[4] = color(80, 80, 80);
  } else if (colorMode == 3) {
    randomColors[0] = color(255, 220, 0); randomColors[1] = color(0);
    randomColors[2] = color(200, 180, 50); randomColors[3] = color(50, 50, 50);
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
    time += 0.03;
    currentRotation += rotationSpeed;
  }
  
  // Hintergrund-Farbe + Bild (wie zuvor)
  color bgStart = randomColors[currentColorIndex];
  color bgEnd = randomColors[(currentColorIndex + 1) % numColors];
  background(lerpColor(bgStart, bgEnd, colorPhase));
  
  if (bgImage != null && bgImage.width > 0) {
    pushMatrix();
    translate(width/2 + panX, height/2 + panY);
    scale(zoomLevel);
    translate(-width/2, -height/2);
    tint(lerpColor(color(255, 200, 200, 140), color(255, 220, 80, 100), colorPhase));
    image(bgImage, 0, 0);
    noTint();
    popMatrix();
  }
  
  // Karussell – jetzt mit Bildern statt Text-Panels
  if (carouselImages.length > 0) {
    pushMatrix();
    translate(width/2, height/2);
    rotate(currentRotation);
    
    float panelAngle = TWO_PI / carouselImages.length;
    float radius = 240;
    
    for (int i = 0; i < carouselImages.length; i++) {
      pushMatrix();
      rotate(i * panelAngle);
      translate(0, -radius);
      
      // Panel-Rahmen mit semi-transparenz
      fill(lerpColor(color(200, 150), color(100, 50), sin(time + i) * 0.5 + 0.5), 160);
      stroke(255, 100);
      rect(-110, -140, 220, 280, 25);
      
      // Bild rendern (zentriert & skaliert)
      PImage img = carouselImages[i];
      if (img != null) {
        float scaleFactor = min(200.0 / img.width, 240.0 / img.height);
        image(img, -img.width * scaleFactor / 2, -img.height * scaleFactor / 2, 
              img.width * scaleFactor, img.height * scaleFactor);
      }
      
      popMatrix();
    }
    popMatrix();
    
    // Fokussiertes Panel (größer, hervorgehoben)
    float focusAngle = currentRotation + panelAngle * focusPanel;
    float fx = width/2 + cos(focusAngle) * radius;
    float fy = height/2 + sin(focusAngle) * radius;
    
    pushMatrix();
    translate(fx, fy);
    scale(1.4 + sin(time * 2) * 0.15);
    fill(255, 220, 0, 220);
    ellipse(0, 0, 280, 280);
    
    // Bild im Fokus größer zeigen
    PImage fImg = carouselImages[focusPanel];
    if (fImg != null) {
      float s = min(220.0 / fImg.width, 260.0 / fImg.height);
      image(fImg, -fImg.width * s / 2, -fImg.height * s / 2, fImg.width * s, fImg.height * s);
    }
    popMatrix();
  }
  
  // Partikel-Explosion (bei Klick)
  if (exploding) {
    // ... (wie zuvor – Partikel zeichnen)
  }
  
  // Zoom-Logik (wie zuvor)
  if (autoZoomMode) {
    zoomLevel = 1.5 + sin(time * 0.6) * 1.0;
  } else if (!panMode) {
    zoomLevel = map(mouseY, 0, height, maxZoom, minZoom);
  }
  zoomLevel = constrain(zoomLevel, minZoom, maxZoom);
}

void mousePressed() {
  rotationSpeed = 0.8;
  focusPanel = (focusPanel + 1) % carouselImages.length;
  exploding = true;
  explodeTime = 0;
  // Partikel-Initialisierung (wie zuvor)
}

void mouseReleased() {
  rotationSpeed = 0.2;
}

// mouseDragged, keyPressed, generateColors() – wie in der vorherigen Version
// (kopiere sie einfach aus dem letzten Skript – 'q', 'z', 'w', 'c' etc.)

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
void mouseDragged() {
  if (panMode) {
    panX += (mouseX - pmouseX);
    panY += (mouseY - pmouseY);
  }
}
