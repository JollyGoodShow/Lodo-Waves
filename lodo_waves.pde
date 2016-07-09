int WIDTH, HEIGHT; //Screen dimensions
int n_x, n_y;      //Lights in x and y directions
float dt = 1.0;    //time step
float dx, dy;      //spacing between grid points
float c = 2.9;     //constant (wave speed)
float C2;          //Used to speed up calculations

float [][] uPrev;     //Stores values of u from previous time step
float [][] uCurrent;  //Stores current values of u
float [][] uNext;     //Temporary storage for next time step

float pi = 3.14159;

void setup() {
  WIDTH = 950;
  HEIGHT = 680;
  n_x = 7*6;
  n_y = 7*5;
  dx = float(WIDTH)/(n_x-1);
  dy = float(HEIGHT)/(n_y-1);
  C2 = pow(c*dt, 2.0);
  
  uPrev = new float[n_x][n_y];
  uCurrent = new float[n_x][n_y];
  uNext = new float[n_x][n_y];
  
  int i, j;
  for (i=0; i<n_x; i++) {
    for (j=0; j<n_y; j++) {
      uPrev[i][j] = 0.0;
      uCurrent[i][j] = 0.0;
      uNext[i][j] = 0.0;
    }
  }
  
  //setInitialCondition2();
 
  surface.setSize(WIDTH, HEIGHT);
}


//Some initial conditions

void setInitialCondition1() {
  int i, j;
  for (i=0; i<n_x; i++) {
    for (j=0; j<n_y; j++) {
      uCurrent[i][j] = 200*sin(2*pi*i/(n_x-1));
    }
  }
  for (i=0; i<n_x; i++) {
    for (j=0; j<n_y; j++) {
      uCurrent[i][j] += 200*sin(2*pi*j/(n_y-1));
    }
  }
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      uPrev[i][j] = uCurrent[i][j] + 0.5*C2*( (uCurrent[i-1][j] - 2*uCurrent[i][j] + uCurrent[i+1][j])/(dx*dx) + (uCurrent[i][j-1] - 2*uCurrent[i][j] + uCurrent[i][j+1])/(dy*dy) );
    }
  }
}

void setInitialCondition2() {
  int i, j;
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      uCurrent[i][j] = 5*(n_x-i);
    }
  }
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      //Backwards wave equation of sorts
      uPrev[i][j] = uCurrent[i][j] + 0.5*C2*( (uCurrent[i-1][j] - 2*uCurrent[i][j] + uCurrent[i+1][j])/(dx*dx) + (uCurrent[i][j-1] - 2*uCurrent[i][j] + uCurrent[i][j+1])/(dy*dy) );
    }
  }
}

void setInitialCondition3() {
  int i, j;
  uCurrent[n_x/2][n_y/2] = 1000;
  uCurrent[n_x/2-1][n_y/2] = 800;
  uCurrent[n_x/2+1][n_y/2] = 800;
  uCurrent[n_x/2][n_y/2+1] = 800;
  uCurrent[n_x/2][n_y/2-1] = 800;
  uCurrent[n_x/2+1][n_y/2-1] = 800;
  uCurrent[n_x/2-1][n_y/2-1] = 800;
  uCurrent[n_x/2+1][n_y/2+1] = 800;
  uCurrent[n_x/2-1][n_y/2+1] = 800;
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      //Backwards wave equation of sorts
      uPrev[i][j] = uCurrent[i][j] + 0.5*C2*( (uCurrent[i-1][j] - 2*uCurrent[i][j] + uCurrent[i+1][j])/(dx*dx) + (uCurrent[i][j-1] - 2*uCurrent[i][j] + uCurrent[i][j+1])/(dy*dy) );
    }
  }
}

// End initial conditions


float F(int i, int j) {
  //Enternal forces
  float Force = 0.0;
  float coord_x = i*dx;
  float coord_y = j*dy;
  float dist = pow( pow((mouseX-coord_x), 2.0) + pow((mouseY-coord_y), 2.0), 0.5);  //distance formula
  //If point is not next to mouse, no force
  if (dx > dy) {
    if (dist > dx) {
      return 0.0;
    }
  }
  else if (dist > dy) {
    return 0.0;
  }
  //Holding down the mouse creates a force
  if (mousePressed == true) {
    Force += 30;
  }
  //Adds an additional force due to mouse movement
  Force += pow( pow((pmouseX-mouseX), 2.0) + pow((pmouseY-mouseY), 2.0), 0.5);
  return Force;
}

void drawLights() {
  //Prints current values of u to the screen (in FULL TECHNICOLOR!)
  int i, j;
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      colorMode(HSB, 100, 100, 100);
      fill(-uCurrent[i][j]/3.5 + 60, 100, uCurrent[i][j]*1.5+80);
      ellipse(dx*(i), dy*(j), 8, 8);
    }
  }
}

void stepWave() {
  //Applies discrete wave equation to propogate the wave
  int i, j;
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      float innerDifference1 = (uCurrent[i-1][j]-2*uCurrent[i][j]+uCurrent[i+1][j])/(dx*dx);
      float innerDifference2 = (uCurrent[i][j-1]-2*uCurrent[i][j]+uCurrent[i][j+1])/(dy*dy);
      uNext[i][j] = C2*(innerDifference1 + innerDifference2) + 2*uCurrent[i][j] - uPrev[i][j] + (dt*dt)*F(i, j)/3;
    }
  }
  for (i=1; i<(n_x-1); i++) {
    for (j=1; j<(n_y-1); j++) {
      uPrev[i][j] = uCurrent[i][j];
      uCurrent[i][j] = uNext[i][j];
    }
  }
}

void dampen(float amount) {
  //Optionally causes the wave to decay
  //Takes numbers 1.000 and greater (or you're in for trouble)
  int i, j;
  for (i=0; i<n_x; i++) {
    for (j=0; j<n_y; j++) {
      uPrev[i][j] /= amount;
      uCurrent[i][j] /= amount;
    }
  }
}

void draw() {
  background(0);
  noStroke();
  drawLights();
  stepWave();
  dampen(1.003);
}
