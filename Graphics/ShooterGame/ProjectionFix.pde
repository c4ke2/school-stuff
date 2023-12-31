// Functions to compel Processing to let us edit the projection matrix

PGraphicsOpenGL pogl = null;

// called at the beginning of your code
void setupPOGL() 
{
  pogl = (PGraphicsOpenGL)g;
}

// for debugging
void printProjection() 
{
  pogl.projection.print();
}

// call immediately after using perspective() to create a view frustum
void fixFrustumYAxis() 
{
  PMatrix3D projection = getProjection();
  projection.preApply(new PMatrix3D(
    1, 0, 0, 0,
    0, -1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
    ));
  setProjection(projection);
}

PMatrix3D getProjection() 
{
  assert pogl != null: "no PGraphics OpenGL context";
  return pogl.projection.get();
}

void setProjection(PMatrix3D projectionMatrix) 
{
  assert pogl != null: "no PGraphics OpenGL context";
  pogl.projection.set(projectionMatrix.get());
  pogl.updateProjmodelview();
}
