final int PART_SIZE = 5;
float effectZ;

class explodeParticle
{
  float xPos;
  float yPos;
  float zPos;
  
  float xSpeed;
  float ySpeed;
  float zSpeed;
  
  int maxLife;
  int life = 0;
  
  color col;
  
  boolean dead = false;
  
  explodeParticle(float speed, int mL, float x, float y, color c)
  {
    xSpeed = random(-speed,speed);
    ySpeed = random(-speed,speed);
    zSpeed = random(-speed*2,speed*2); // size*2 makes the 3D effect more drastic
    xPos = x;
    yPos = y;
    zPos = effectZ;
    maxLife = mL;

    col = c;
    
    particles.add(this);
    if(particles.size()>MAX_PARTICLES)
      particles.remove(0);
  }
  
  void updateParticle()
  {
    if(!dead)
    {
      //draw
      beginShape();
      if(doTextures)
      {
        texture(explodeAnim[1]);
        tint(col,1-(float)life/(float)maxLife);
      }
      else
       fill(col,1-((float)life/(float)maxLife));

      pushMatrix();
      vertex(xPos-PART_SIZE,yPos+PART_SIZE,zPos,0,0);
      vertex(xPos-PART_SIZE,yPos-PART_SIZE,zPos,0,1);
      vertex(xPos+PART_SIZE,yPos-PART_SIZE,zPos,1,1);
      vertex(xPos+PART_SIZE,yPos+PART_SIZE,zPos,1,0);
      if(doTextures)
        tint(1,1);
      endShape(CLOSE);
      popMatrix();
      
      //update
      life++;
      xPos+=xSpeed;
      yPos+=ySpeed;
      zPos+=zSpeed;
      if(life>=maxLife)
        dead=true;
    }
  }
  
}

void updateAllParticles()
{
  for(int i=0;i<particles.size();i++)
  {
    explodeParticle e = (explodeParticle)particles.get(i);
    e.updateParticle();
  }
}
