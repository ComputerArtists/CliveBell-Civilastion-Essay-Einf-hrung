PImage bgImage = null;
PFont font;
String[] texts;
float time = 0;
float crosshairScale = 0;  // 0 → 1 für Zoom-In

void setup() {
  size(900, 600);
  surface.setTitle("Civilization im Fadenkreuz – Tatort Style");
  
  selectInput("Hintergrund-Bild (z.B. Pelican Cover oder Auge-Bild):", "imageSelected");
  
  texts = loadStrings("slogans.txt");
  if (texts == null || texts.length < 2) {
    texts = new String[]{
      "CIVILIZATION",
      "YOU ARE FIGHTING FOR CIVILIZATION",
      "...at millions a day"
    };
  }
  
  font = createFont("Arial Black", 72);
  textFont(font);
  textAlign(CENTER, CENTER);
}

void imageSelected(File selection) {
  if (selection != null) {
    bgImage = loadImage(selection.getAbsolutePath());
    if (bgImage != null) bgImage.resize(width, height);
  }
}

void draw() {
  time += 0.02;
  
  // Zyklischer dunkler Hintergrund (Tatort-ähnlich: schwarz-grau-rot)
  float phase = (sin(time * 0.3) + 1) / 2;
  background(lerpColor(color(10, 10, 20), color(80, 0, 20), phase));
  
  if (bgImage != null) {
    tint(100 + phase * 80, 100);  // Dunkel getönt
    image(bgImage, 0, 0);
    noTint();
  }
  
  // Auge (einfach stilisiert: Kreis + Pupille)
  float eyeX = width/2;
  float eyeY = height/2;
  fill(255);
  ellipse(eyeX, eyeY, 300, 180);  // Weißes Auge
  fill(0);
  ellipse(eyeX + sin(time * 2) * 20, eyeY, 100, 100);  // Pupille (leicht bewegt für "Leben")
  
  // Fadenkreuz zoomt ein (Tatort-Style: mehrere Ringe + Kreuz)
  crosshairScale = min(1, time * 0.4);  // Langsamer Zoom-In, dann halten
  if (time > 10) crosshairScale = 1 - (time - 10) * 0.1;  // Nach 10s langsam rauszoomen & loop
  
  noFill();
  stroke(255, 0, 0, 220);
  strokeWeight(4);
  float size = 400 * crosshairScale;
  
  // Konzentrische Kreise
  ellipse(eyeX, eyeY, size, size);
  ellipse(eyeX, eyeY, size * 0.7, size * 0.7);
  ellipse(eyeX, eyeY, size * 0.4, size * 0.4);
  
  // Kreuz-Linien
  line(eyeX - size/2, eyeY, eyeX + size/2, eyeY);
  line(eyeX, eyeY - size/2, eyeX, eyeY + size/2);
  
  // Text im Zentrum (wenn Fadenkreuz voll da)
  if (crosshairScale > 0.8) {
    fill(255, map(sin(time * 5), -1, 1, 150, 255));  // Pulsierend
    textSize(80);
    text(texts[0], eyeX, eyeY - 20);
    
    textSize(40);
    fill(255, 200, 0);
    text(texts[1], eyeX, eyeY + 80);
    
    textSize(28);
    fill(220, 180);
    text(texts[2], eyeX, height - 60);
  }
}
 void keyPressed(){
  // Screenshot
  if (keyPressed && (key == 's' || key == 'S')) {
    saveFrame("fadenkreuz-civilization-####.png");
  }
}
