final int DORMANT_TIME = 1000;    //when an enemy is created, it is dormant.
class Enemy
{
  float speed = .01;  //amount to lerp by
  float posX;
  float posY;
  float posZ = (Z_CENT)*.64;
  
  float targetX;
  float targetY;
  
  float scaleX = 50;
  float scaleY = 50;
  
  float hitRadius = scaleX/2;
  
  color c;

  final int MAX_FRAME = 24/eAnim.length;  //framerate for enemy animation
  int frameTime = 0;
  int currFrame = 0;
  PImage frame = eAnim[currFrame];
  
  final int DIRECT_TIMER = 60;  //time to wait before changing move target
  int timeInDirection = 0;

  int dormant = 0;                  //when an enemy is killed, it disappears, switches its postion and becomes dormant
                                    //when the enemy is done being dormant, it appears and can be killed in a sort of 'respawn' system.  
  Enemy()
  {
    c = color(1,.5,5);
    
    posX = random(W_RIGHT,W_LEFT);
    posY = W_BOTTOM-scaleY;//random(W_BOTTOM,W_TOP);
    
    targetX =  random(W_RIGHT,W_LEFT);
    targetY =  random(W_BOTTOM,W_TOP);        //enemies spawn below the screen, then move up
    
    dormant = DORMANT_TIME;  //enemy is immediately awake
  }
  
  Enemy(int d)
  {
    c = color(1,.5,5);
    
    dormant = d;
    
    targetX = random(W_LEFT,W_RIGHT);
    targetY = random(W_BOTTOM,W_TOP);
    
    posX = random(W_RIGHT,W_LEFT);
    posY = W_BOTTOM-scaleY;  //enemies spawn below the screen, then move up
  }
  
  void drawEnemy()
  {
    if(dormant >= DORMANT_TIME)
    {
      fill(c);
      stroke(0);
      strokeWeight(2);
      
      pushMatrix();    
      translate(posX,posY,posZ);
      
      beginShape(TRIANGLES);   
      if(doTextures)
      {
        frameTime++;
      if(frameTime>=MAX_FRAME)
      {
        frameTime=0;
        currFrame = (currFrame+1)%eAnim.length;
        frame = eAnim[currFrame];
      }
      
      texture(frame);
        noStroke();
      }
      
      vertex(-scaleX/2,scaleY/2,0,0,0);
      vertex(-scaleX/2,-scaleY/2,0,0,1);
      vertex(scaleX/2,-scaleY/2,0,1,1);
      vertex(-scaleX/2,scaleY/2,0,0,0);
      vertex(scaleX/2,scaleY/2,0,1,0);
      vertex(scaleX/2,-scaleY/2,0,1,1);
      endShape();
      
      popMatrix();
      noStroke();
    }
    else
      dormant++;
  }
  
  void moveEnemy()
  {
    if(dormant>=DORMANT_TIME)
    {
      checkCollision();
      
      timeInDirection++;
      decideMovement(); 

      posX=lerp(posX,targetX,speed);
      posY=lerp(posY,targetY,speed);
    }
  }
  
  void decideMovement()
  {
    if(timeInDirection>=DIRECT_TIMER)
    {
      //change target destination
      targetX =  random(W_RIGHT,W_LEFT);
      targetY =  random(W_BOTTOM,W_TOP);
      
      //have a chance to shoot
      if((int)random(0,2)==1)
        new Projectile(false,posX,posY,5,300);
      
      timeInDirection = 0;
    }
  }
  
  void checkCollision()
  {
    //if collided with player, kill player
    if(doCollision)
    if(dist(posX,posY,player.playerPosX,player.playerPosY)<hitRadius)
    {
      color c1 = color(0,0,1);
      color c2 = color(0,1,1);
      for(int i=0;i<30;i++)
        new explodeParticle(4, 30, player.playerPosX, player.playerPosY,c1);
      for(int i=0;i<30;i++)
        new explodeParticle(3, 20, player.playerPosX, player.playerPosY,c2);
      player.die();
    }
  }
}
