//for 'bullets' fired by player and enemies

class Projectile
{
  boolean playerOwn;  //whether this was shot by the player
  
  float speed;
  float posX;
  float posY;
  
  boolean dead=false;  //dead projectiles are not moved or drawn, and cannot collide with anything
  int life;       //how long it has existed
  int maxLife;    //how long the particle will fly
  
  float size=10;
  float hitRadius;  //projectile has hit anything in this radius
  
  //frame animation
  final int MAX_FRAME = 24/explodeAnim.length;
  int frameTime = 0;
  int currFrame = 0;
  PImage frame = explodeAnim[currFrame];
  
  Projectile(boolean p, float x, float y, float s, int mL)
  {
    playerOwn = p;
    posX = x;
    posY = y;
    speed = s;
    maxLife = mL;
    
    if(p)
    {
      size = 16;
      speed*=-1;
    }
      
    hitRadius = size/2;
    
    shots.add(this);
    if(shots.size()>MAX_SHOTS)  //remove oldest projectile so there's never more than MAX_SHOTS
      shots.remove(0);
  }
  
  //------------------------
  // moves, draws and checks collision
  // of this projectile
  void operateProjectile()
  {
    if(!dead)
    {
      //animation
      frameTime++;
      if(frameTime>=MAX_FRAME)
      {
        frameTime=0;
        currFrame = (currFrame+1)%explodeAnim.length;
        frame = explodeAnim[currFrame];
      }
      
      //update
      posY += speed;
      
      if(doCollision&&!pause)
      {
        if(playerOwn)
          checkCollisionForEnemy();
        else
          checkCollisionForPlayer();
          
        checkCollisionShots();
      }
      
      //draw
      beginShape();
      if(doTextures)
      {
        texture(frame);
        if(playerOwn)
          tint(1);
        else
          tint(1,0,1);
      }
      else
       fill(1);
      
      vertex(posX-size/2,posY+size/2,effectZ,0,0);
      vertex(posX-size/2,posY-size/2,effectZ,0,1);
      vertex(posX+size/2,posY-size/2,effectZ,1,1);
      vertex(posX+size/2,posY+size/2,effectZ,1,0);
      tint(1);
      endShape(CLOSE);
      
      life++;
      if(life>=maxLife)
        dead=true;
    }
  }
  
  void checkCollisionShots()
  {
     //check if collides with opposite team projectile
     for(int i=0;i<shots.size();i++)
     {
        Projectile p = (Projectile)shots.get(i);
        if(p.playerOwn == !this.playerOwn && !p.dead)
        {
           if(dist(this.posX,this.posY,p.posX,p.posY)<=this.hitRadius)
           {
             score += 1;
             p.die();
             this.die();
           }
        }
     }
  }
  
  void checkCollisionForPlayer()
  {
    //check if collides with player    
    if(dist(player.playerPosX,player.playerPosY,posX,posY)<=player.pHitRadius)
    {
      die();
      player.hurt();
    }
  }
  
  void checkCollisionForEnemy()
  {
      //check if collides with enemy
      for(int i=0;i<spawner.list.length;i++)
      {
        if(spawner.list[i].dormant>=DORMANT_TIME)
        if(dist(posX,posY,spawner.list[i].posX,spawner.list[i].posY)<=spawner.list[i].hitRadius)
        {
          //destroy enemy
          spawner.list[i].dormant = (int)random(0,DORMANT_TIME*.9);
          spawner.list[i].posX = random(W_RIGHT,W_LEFT);
          spawner.list[i].posY = W_BOTTOM-spawner.list[i].scaleY;  //enemies respawn below the screen, then move up
          die();
          score+=5;
        }
      }
      //else enemy is sleeping so we don't disturb them :)
  }
  
  void die()
  {
    dead=true;

    
    if(!playerOwn)
    {
      color c1 = color(1,0,1);
      color c2 = color(1,1,1);
      for(int i=0;i<30;i++)
        new explodeParticle(3, 20, posX, posY,c1);
      for(int i=0;i<30;i++)
        new explodeParticle(2, 10, posX, posY,c2);
    }
    else
    {
      color c1 = color(1,0,0);
      color c2 = color(1,1,0);
    
      for(int i=0;i<30;i++)
        new explodeParticle(3, 30, posX, posY,c1);
      for(int i=0;i<30;i++)
        new explodeParticle(2, 20, posX, posY,c2);
    }
  }
}

void updateAllProjectiles()
{
  for(int i=0;i<shots.size();i++)
  {
     Projectile p = (Projectile)shots.get(i);
     p.operateProjectile();   
  }
}
