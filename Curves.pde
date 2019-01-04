class Curve {
  ArrayList<PVector> path;
  PVector curr;
  int numBoids = 500;
  int boidCounter;

  Curve() {
    path = new ArrayList<PVector>();
    curr = new PVector();
  }

  void addPoint(int displayWingsFrame) {
    if (angle > -TWO_PI) {
      path.add(curr);
    }
  }

  void setX(float x) {
    curr.x = x;
  }
  
  void reset() {
    path.clear();
  }

  void setY(float y) {
    curr.y = y;
  }
  
  void show(float noiseWeight) {
    stroke(0, 50);
    strokeWeight(strokeW);
    noFill();
    if (lissalines) {
      pushMatrix();
      //translate(-w*3/4, -w*3/4);
      beginShape();
      for ( PVector v : path) {
        //vertex(v.x, v.y);
        wave = noise(((noiseWeight+v.x)*.01), (noiseWeight+v.y)*.008)*6-.5;
        strokeWeight(wave);
      //println("wave: "+wave);
        stroke(0, 255-map(wave, 0, 6, 0, 150));
        boidCounter++;
        //strokeWeight(1);
        point(v.x, v.y);
      }

      endShape();
      popMatrix();
    }
    if (debug) {
      strokeWeight(strokeW*8);
      point(curr.x, curr.y);
    }
    curr = new PVector();
  }
}