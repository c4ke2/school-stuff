 //these are offsets for translations for changing
 //a part back to world 0 so they can be properly trasformed
 float pikaCenterRot = 0;
 float pikaCenterX = 0;
 float pikaCenterY = 0;

  //some colors to use
  final color BLACK = color(0);
  final color WHITE = color(255);
  final color BROWN = color(180, 120, 60);
  final color BROWN2 = color(71, 45, 21);
  final color BROWN3 = color(90, 75, 60);
  final color YELLOW = color(240, 225, 110);
  final color YELLOW2 = color(235, 232, 52);
  final color YELLOW3 = color(240, 225, 110);
  final color YELLOW4 = color(245, 243, 142);
  final color YELLOW5 = color(210, 200, 4);
  final color RED = color(245, 60, 15);
  final color RED2 = color(255, 50, 10);
  final color RED3 = color(100, 10, 0);

//=========================
// transformChild
//
// scales, rotates, and transforms
// the model matrix
//=========================
void transformChild(float scaleX, float scaleY, float angle, float tranX, float tranY)
{
  //assumes child is at the center
  myScale(scaleX,scaleY);
  myRotate(angle);
  myTranslate(tranX,tranY);
}

//=========================
// Draws a pikachu
//
// y, b, r - yellow, red, brown colors to use
// stretch - tail proportion
//=========================
void drawPikachu(color y, color b, color r,float stretch)
{
  pikaYellow = y;
  pikaBrown = b;
  pikaRed = r;
  fill(pikaYellow);
  stroke(BLACK);
  strokeWeight(cameraZoom*1.5);
  
  myPush();
  transformChild(0.08,0.1,pikaCenterRot,pikaCenterX,pikaCenterY);
  drawPikaBody(stretch);
  myPop();
}
//colours of current pikachu
color pikaYellow;
color pikaBrown;
color pikaRed;

//=========================
// Draw the body and its children
//
// stretch - tail proportion
//=========================
void drawPikaBody(float stretch)
{
  //tail
  myPush();
  myTranslate(-pikaCenterX,-pikaCenterY);
  myRotate(-pikaCenterRot);
  
  transformChild(.6+(stretch/16),-.6,PI/2,0.03,-0.08);

  myRotate(pikaCenterRot);
  myTranslate(pikaCenterX,pikaCenterY);
  drawPikaTail();
  myPop();
  
  //body
  beginShape();
  myVertex(-1,-1);
  myVertex(1,-1);
  myVertex(.75,1);
  myVertex(-.75,1);
  endShape(CLOSE);

  //head
  myPush();
  myTranslate(-pikaCenterX,-pikaCenterY);
  myRotate(-pikaCenterRot);
  
  transformChild(1.2,1.2,0,0,0.12);

  myRotate(pikaCenterRot);
  myTranslate(pikaCenterX,pikaCenterY);
  drawPikaHead();
  myPop();
}

//=========================
// Draw the head and its children
//=========================
void drawPikaHead()
{
  //ears
  myPush();
  float m2 = model.m02;
  float m12 = model.m12;
  
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  transformChild(1,0.7,PI/6,-0.08,0.1);

  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaEar();
  myPop();
  
  myPush();
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  transformChild(1,0.7,-PI/6,0.08,0.1);

  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaEar();  
  myPop();
  
  //head itself
  beginShape();
  fill(pikaYellow);
  myVertex(-1,0);
  myVertex(-.5,-.6);
  myVertex(.5,-.6);
  myVertex(1,0);
  myVertex(.5,.6);
  myVertex(-.5,.6);
  endShape(CLOSE);
  
  //move eyes to position
  myPush();
  myPush();
  //move to center
  m2 = model.m02;
  m12 = model.m12;
  
  //first eye
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  transformChild(0.3,0.3,0,-.025,0.01);
  
  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaEye();
  
  myPop();
  //second eye
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  transformChild(0.3,0.3,0,.025,0.01);
  
  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaEye();
  
  myPop();
  
  println("Test mode: "+testMode);
  myPush();
  
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  myScale(1.5,1.5);
  myTranslate(-.045,-.02);
  
  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaSpot();
  
  myPop();
  
  myPush();
  
  myTranslate(-m2,-m12);
  myRotate(-pikaCenterRot);
  
  myScale(1.5,1.5);
  myTranslate(.045,-.02);
  
  myRotate(pikaCenterRot);
  myTranslate(m2,m12);
  drawPikaSpot();
  
  myPop();
}

//=========================
// Draw an eye
//=========================
void drawPikaEye()
{
    beginShape(QUADS);
    fill(BLACK);
    stroke(BLACK);
    myVertex(.3,.5);
    myVertex(.3,-.5);
    myVertex(-.3,-.5);
    myVertex(-.3,.5);
    endShape();
    
    //highlight
    beginShape(LINES);
    stroke(WHITE);
    myVertex(.2,.4);
    myVertex(.2,.2);
    endShape(); 
}

//=========================
// Draw an ear
//=========================
void drawPikaEar()
{
    beginShape();
    fill(pikaYellow);
    stroke(BLACK);
    myVertex(0,1);
    myVertex(-.2,0.3);
    myVertex(-.2,-.8);
    myVertex(.2,-.8);
    myVertex(.2,.3);
    endShape(CLOSE);
    
    //brown tips
    beginShape();
    fill(pikaBrown);
    stroke(BLACK);
    myVertex(0,1);
    myVertex(-.2,0.3);
    myVertex(-.2,.2);
    myVertex(.2,.2);
    myVertex(.2,.3);
    endShape(CLOSE);
}

//=========================
// Draw a spot
//=========================
void drawPikaSpot()
{
    beginShape();
    fill(pikaRed);
    stroke(BLACK);
    myVertex(0,0.1);
    myVertex(-.1,0);
    myVertex(0,-0.1);
    myVertex(.1,0);
    endShape(CLOSE);
}

//=========================
// Draw the tail
//=========================
void drawPikaTail()
{
  float size = 1;  //size of one length of the lightning pattern
  beginShape();
  fill(pikaYellow);
  stroke(BLACK);
  myVertex(0,0);
  myVertex(size,size);
  myVertex(size*1.5,0);
  myVertex(size*3,size*2);
  myVertex(size*3,size*3);
  myVertex(size*1.5,size*1.5);
  myVertex(size,size*2);
  endShape(CLOSE);
}
