class Player
{
  float playerSpeed = 6;
  float playerPosX;
  float playerPosY;
  float playerPosZ = (Z_CENT)*.64;
  
  float pScaleX = 75;
  float pScaleY = 75;
  
  //banking
  final float BANK_AMOUNT = .1;
  final float BANK_AMOUNT_ORTH = PI/16;
  float bankX = 0;
  float bankY = 0;
  
  //frame animation
  final int MAX_FRAME = 48/pAnim.length;  //framerate for player animation
  int frameTime = 0;
  int currFrame = 0;
  PImage frame = pAnim[currFrame];
  
  //for drifting
  boolean drifting = false;
  float dSpeed = playerSpeed/4;
  //drifting only starts after idling for some time
  //because its very annoying if it starts as soon as you stop moving
  int driftTime = 0;
  int startDrift = 60;
  float driftTargetY = 120;
  
  color pColor; 
  
  int maxHealth = 3;
  int health = 3;
  color hurtTint = color (1,0,0);    //flash red when hit, only when textures on
  boolean hurt = false;
  
  float pHitRadius = pScaleX/2;
  
  Player()
  {
    pColor = color(.2,1,.8);
    playerPosX=0;
    playerPosY=0;
  }
  
  void drawPlayer()
  {
    fill(pColor);
    stroke(0);
    strokeWeight(2);
    
    pushMatrix();
    rotateX(bankX);
    rotateY(bankY);
    
    translate(playerPosX,playerPosY,playerPosZ);
    
    beginShape(TRIANGLES);   
    if(doTextures)
    {
      frameTime++;
      if(frameTime>=MAX_FRAME)
      {
        if(frame==pAnim[0])
          hurt = false;
        frameTime=0;
        currFrame = (currFrame+1)%pAnim.length;
        frame = pAnim[currFrame];
      }
             
      if(hurt)
      {
        tint(hurtTint);
      }
      
      texture(frame);
      noStroke();
    }

    vertex(-pScaleX/2,pScaleY/2,0,0,0);
    vertex(-pScaleX/2,-pScaleY/2,0,0,1);
    vertex(pScaleX/2,-pScaleY/2,0,1,1);
    vertex(-pScaleX/2,pScaleY/2,0,0,0);
    vertex(pScaleX/2,pScaleY/2,0,1,0);
    vertex(pScaleX/2,-pScaleY/2,0,1,1);
    endShape();
    if(hurt)
      tint(1);
    
    drawHealth();  //doing it here makes it move with the player
    popMatrix();

    
    noStroke();
  }
  
  void drawHealth()
  {
    float size = 10;
    float xOff = size*1.5;
    
    for(int i=0;i<health;i++)
    {
      fill(1,0,0);
      stroke(1);
      strokeWeight(3);
      pushMatrix();
      rect(-size/2+xOff,pScaleY/2 + size, size, size, 28);
      popMatrix();
      xOff-=size*1.5;
    }
  }
  
  void movePlayer()
  {
    //borders
    if(playerPosX>=W_LEFT)
    {
      moveLeft=false;
    }
    if(playerPosX<=W_RIGHT)
    {
      moveRight=false;
    }
    if(playerPosY>=W_TOP)
    {
      moveUp = false;
    }
    if(playerPosY<=W_BOTTOM)
    {
      moveDown=false;
    }

    float targetBX = 0;
    float targetBY = 0;

    //drifting
    drifting = true;
    if(moveLeft)
    {
      if(!inOrth)
        targetBY -= BANK_AMOUNT;
      else
        targetBY-=BANK_AMOUNT_ORTH;
      playerPosX+=playerSpeed;
      driftTime=0;
      drifting=false;
    }
    if(moveRight)
    {
      if(!inOrth)
        targetBY += BANK_AMOUNT;
      else
        targetBY+=BANK_AMOUNT_ORTH;

      playerPosX-=playerSpeed;
      driftTime=0;
      drifting=false;
    }
    if(moveUp)
    {
     if(!inOrth)
        targetBX += BANK_AMOUNT;
      else
        targetBX+=BANK_AMOUNT_ORTH;
        
       playerPosY+=playerSpeed;
       driftTime=0;
       drifting=false;
    }
    if(moveDown)
    {
      if(!inOrth)
        targetBX -= BANK_AMOUNT;
      else
        targetBX-=BANK_AMOUNT_ORTH;

      playerPosY -=playerSpeed;
      driftTime=0;
      drifting=false;
    }
    
    bankX=targetBX;
    bankY=targetBY;
    
    if(drifting && doDrifting)
    {
      driftTime++;
      if(driftTime>=startDrift)
        playerDrift();
    }
  }
  
  void playerDrift()
  {    
    bankX=0;
    bankY=0;

    if(playerPosX>0)
    {
      if(!inOrth)
        bankY += BANK_AMOUNT/2;
      else
        bankY+=BANK_AMOUNT_ORTH/2;
      playerPosX-=dSpeed;
    }
    if(playerPosX<0)
    {
      if(!inOrth)
        bankY -= BANK_AMOUNT/2;
      else
        bankY-=BANK_AMOUNT_ORTH/2;
      playerPosX+=dSpeed;
    }
    if(playerPosY<driftTargetY)
    {
      if(!inOrth)
        bankX += BANK_AMOUNT/2;
      else
        bankX+=BANK_AMOUNT_ORTH/2;

      playerPosY+=dSpeed;
    }
    if(playerPosY>driftTargetY)
    {
      if(!inOrth)
        bankX -= BANK_AMOUNT/2;
      else
        bankX-=BANK_AMOUNT_ORTH/2;

      playerPosY-=dSpeed;
    }
  }
  
  void shoot()
  {
     new Projectile(true,playerPosX,playerPosY,5,300);
  }
 
  void hurt()
  {
    health--;
    if(health<=0)
      die();
    else
    {
      hurt = true;
      frameTime=0;
    }
  }
  
  void die()
  {
    pause = true;
    gameOver=true;
  }
}
