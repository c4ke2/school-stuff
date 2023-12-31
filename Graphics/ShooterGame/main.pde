/*
Ground textures made by me.  All other
art is from https://opengameart.org/
with adjustments to color/exposure.
*/

TileGrid tiles1;
TileGrid tiles2;

PImage[] grassTexture;
PImage[] pillarTexture;

PImage[] pAnim;
PImage[] eAnim;

PImage[] explodeAnim;

EnemySpawner spawner;

final int MAX_PARTICLES = 400;
ArrayList particles;
final int MAX_SHOTS = 40;
ArrayList shots;

//borders for movement
final float W_LEFT=180;
final float W_RIGHT=-180;
final float W_TOP=180;
final float W_BOTTOM=-180;

int score = 0;

Player player;

boolean pause = true;
boolean gameOver = false;

void setup() 
{
  size(640, 640, P3D);
  colorMode(RGB, 1.0f);
  textureMode(NORMAL); // use normalized 0..1 texture coords
  textureWrap(REPEAT);
  
  setupPOGL();
  setupProjections();
  resetMatrix(); // do this here and not in draw() so that you don't reset the camera

  switchProjection();  //start in perspective because its cooler

  effectZ = Z_CENT*.65;
  
  pAnim = new PImage[4];
  pAnim[0] = loadImage("dragon1.png");
  pAnim[1] = loadImage("dragon2.png");
  pAnim[2] = loadImage("dragon3.png");
  pAnim[3] = loadImage("dragon4.png");
  
  eAnim = new PImage[4];
  eAnim[0] = loadImage("enemy1.png");
  eAnim[1] = loadImage("enemy2.png");
  eAnim[2] = loadImage("enemy3.png");
  eAnim[3] = loadImage("enemy4.png");
  
  grassTexture = new PImage[2];
  grassTexture[0]=loadImage("grass1.png");
  grassTexture[1]=loadImage("grass2.png");
  
  pillarTexture = new PImage[2];
  pillarTexture[0]=loadImage("rock1.png");
  pillarTexture[1]=loadImage("rock2.png");
  
  explodeAnim = new PImage[2];
  explodeAnim[0] = loadImage("explosion.png");
  explodeAnim[1] = loadImage("explosion2.png");
  
  particles = new ArrayList();
  shots = new ArrayList();
  
  tiles1 = new TileGrid();
  tiles2 = new TileGrid(0,-.99); //because -1 left the *tiniest* seam
  
  spawner = new EnemySpawner();
  player = new Player();
}


void draw()
{
  if(!pause)
  {
    background(0);
    
    tiles1.moveAllTiles();
    tiles1.drawAllTiles();
    
    tiles2.moveAllTiles();
    tiles2.drawAllTiles();
    
    player.movePlayer();
    player.drawPlayer();
    
    if(doEnemies)
      spawner.operateAll();
    
    updateAllParticles();
    updateAllProjectiles();
    
    drawScore();
  }
  else
  {
    //only draw certain things while paused
    tiles1.drawAllTiles();
    tiles2.drawAllTiles();
    
    updateAllParticles();
    updateAllProjectiles();
    
    if(gameOver)
    {
      doGameOverScreen();
    }
    else
      doIntroScreen();
  }
}

void mousePressed() 
{
  if(pause)
  {
      //begin a new game
      player.health = player.maxHealth;
      player.playerPosX = 0;
      player.playerPosY = 0;
      score = 0;
      spawner.resetEnemies();
      
      gameOver = false;
      pause = false;
  }
}

void doGameOverScreen()
{
    fill(0,.5);
    noStroke();
    pushMatrix();
    translate(0,0,effectZ/2);
    rect(-height/2,-width/2,width,height);
    fill(1);
    textAlign(CENTER);
    rotate(PI);
    textSize(32);
    text("GAME OVER",0,-40);
    textSize(16);
    text("Score: "+score,0,10);
    
    text("CLICK TO RESTART",0,50);
    
    popMatrix(); 
}

void doIntroScreen()
{
    fill(0,.5);
    noStroke();
    pushMatrix();
    
    translate(0,0,effectZ/2);
    rect(-height/2,-width/2,width,height);
    fill(1);
    textAlign(CENTER);
    rotate(PI);
    
    if(!inOrth)
    textSize(32);
    else
    textSize(64);
    
    text("Instructions",0,-50);
    
    if(!inOrth)
    textSize(16);
    else
    textSize(32);
    text("Move with WASD\nSPACE to shoot\nGet hit 3 times\nand GAME OVER\nCLICK TO START",0,-20);
   
    popMatrix(); 
}


void drawScore()
{    
    fill(0,.5);
    noStroke();
    pushMatrix();
    translate(0,0,effectZ);
    rect(W_LEFT*.35, W_TOP*.9, 128, 32, 28);
    fill(1);
    textSize(16);
    translate(W_LEFT,W_TOP);
    rotate(PI);
    textAlign(LEFT);
    text("Score: "+score,0,8);
    popMatrix();
}
