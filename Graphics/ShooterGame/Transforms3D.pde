/*
Put your projection and camera operations here.
Add more constants, variables and functions as needed.
*/

PMatrix3D projectOrtho, projectPerspective;
final float FAR = 600;
final float NEAR = 10;
final float Z_CENT = (FAR+NEAR)/2;

boolean inOrth = true;

void setupProjections() 
{
  ortho(-width/3,width/3,height/3,-height/3,NEAR,FAR);
  projectOrtho = getProjection();
  
  perspective(PI/2,float(width)/float(height),NEAR,FAR);
  fixFrustumYAxis();
  projectPerspective = getProjection();
}

void switchProjection()
{
  //change to other projection
  inOrth = !inOrth;
  if(inOrth)
  {
    println("PROJECTION: ortho");
    setProjection(projectOrtho);
    camera(0,0,0,0,0,(NEAR+FAR)/2,0,1,0);
  }
  else
  {
    println("PROJECTION: perspective");
    setProjection(projectPerspective);
    camera(0,0,1,0,0,(NEAR+FAR)/2,0,1,0);
  }
}
