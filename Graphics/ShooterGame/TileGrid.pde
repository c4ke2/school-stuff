//a grid of tiles
//this class controls the movement of all its tiles

//the program has two of these.  When one goes off the top of the screen,
//it wraps back down and is reinitialized (tiles are randomized) to scroll up again

final int GRID_SIZE = 13;
class TileGrid
{
  Tile[][] tileMap;
  float xPos;
  float yPos;

  float ySpeed = 3;
  
  float yWrap = GRID_SIZE*TSIZE;  //y cord to warp down when reached

  TileGrid()
  {
    tileMap = new Tile[GRID_SIZE][GRID_SIZE];
    fillGrid();
  }
  
  TileGrid(float x, float y)
  {
    tileMap = new Tile[GRID_SIZE][GRID_SIZE];
    xPos = x*(GRID_SIZE*TSIZE);
    yPos = y*(GRID_SIZE*TSIZE);
    
    fillGrid();
  }
  
  void fillGrid()
  {
    //fill the grid with new tiles
    for(int i=0;i<GRID_SIZE;i++)
      for(int j=0;j<GRID_SIZE;j++)
      {
         tileMap[i][j] = new Tile(i-(GRID_SIZE/2),j-(GRID_SIZE/2));
      } 
      
    yPos-=ySpeed;
    moveAllTiles();
  }
  
  void drawAllTiles()
  {
    for(int i=0;i<GRID_SIZE;i++)
      for(int j=0;j<GRID_SIZE;j++)
        tileMap[i][j].drawTile();
  }
  
  void moveAllTiles()
  {   
    //moves the grid and updates the tiles
    if(yPos>=yWrap)
    {
      yPos = -yWrap+GRID_SIZE;
      fillGrid();
    }
    else
      yPos+=ySpeed;
    
    for(int i=0;i<GRID_SIZE;i++)
      for(int j=0;j<GRID_SIZE;j++)
        tileMap[i][j].moveTile(xPos,yPos);
  }
}
