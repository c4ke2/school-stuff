// for the sphere and its tessellation
final int SPHERE_RADIUS = 250;
final int THETA_DIVISIONS = 40;
final int PHI_DIVISIONS = 20;

class Sphere {
  final int NUM_DIMENSIONS = 3;
  final boolean SPHERICAL_TRIANGLE = true;

  int radius;
  int phiDivisions;
  int thetaDivisions;

  float[] northPole;
  float[] southPole;

  float[][][] vertices;
  Triangle[] tessellation;

  Sphere(int rad, int phiDiv, int thetaDiv) {
    radius = rad;
    phiDivisions = phiDiv;
    thetaDivisions = thetaDiv;

    northPole = pointOnSphereFromPhiTheta(0, 0);
    southPole = pointOnSphereFromPhiTheta(PI, 0);

    vertices = new float[phiDivisions][thetaDivisions+1][NUM_DIMENSIONS];
    generateVertices();
    
    tessellation = new Triangle[2*thetaDivisions*(phiDivisions-1)];
    generateTessellation();    
  }

  void generateTessellation() {
    tessellateNorthPole();
    tessellateSouthPole();
    tessellateEquator();
  }

  void tessellateNorthPole() {
    for (int j=0; j<thetaDivisions; j++) {
      tessellation[j] = new Triangle(northPole, vertices[1][j+1], vertices[1][j], SPHERICAL_TRIANGLE);
    }
  }

  void tessellateSouthPole() {
    for (int j=0; j<thetaDivisions; j++) {
      tessellation[thetaDivisions+j] = new Triangle(southPole, vertices[phiDivisions-1][j], vertices[phiDivisions-1][j+1], SPHERICAL_TRIANGLE);
    }
  }

  void tessellateEquator() {
    for (int i=1; i<phiDivisions-1; i++) {
      for (int j=0; j<thetaDivisions; j++) {
        tessellation[2*i*thetaDivisions + 2*j] = new Triangle(vertices[i][j], vertices[i][j+1], vertices[i+1][j], SPHERICAL_TRIANGLE);
        tessellation[2*i*thetaDivisions + 2*j+1] = new Triangle(vertices[i][j+1], vertices[i+1][j+1], vertices[i+1][j], SPHERICAL_TRIANGLE);
      }
    }
  }

  void generateVertices() {
    for (int i=1; i<phiDivisions; i++) {
      for (int j=0; j<=thetaDivisions; j++) {
        vertices[i][j] = pointOnSphereFromPhiTheta(i*PI/phiDivisions, j*TWO_PI/thetaDivisions);
      }
    }
  }

  float[] pointOnSphereFromPhiTheta(float phi, float theta) {
    float[] point = new float[NUM_DIMENSIONS];
    point[X] = radius*sin(phi)*cos(theta);
    point[Y] = radius*cos(phi);
    point[Z] = radius*sin(phi)*sin(theta);
    return point;
  }
  
  Triangle[] getTessellation() {
    return tessellation;
  }
}
