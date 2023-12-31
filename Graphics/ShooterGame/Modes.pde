final char KEY_VIEW = 'r'; // switch between orthographic and perspective views

// player character
final char KEY_LEFT = 'a';
final char KEY_RIGHT = 'd';
final char KEY_UP = 'w';
final char KEY_DOWN = 's';
final char KEY_SHOOT = ' ';

// useful for debugging to turn textures or collisions on/off
final char KEY_TEXTURE = 't';
final char KEY_COLLISION = 'c';

final char KEY_BONUS = 'b';

final char KEY_DRIFT = 'k';//enable or disable drifting while idle
final char KEY_ENEMY = 'v';//enable or disable enemies

boolean doBonus = false;
boolean doTextures = true;
boolean doCollision = true;
boolean doDrifting = true;
boolean doEnemies = true;

boolean moveLeft = false;
boolean moveRight = false;
boolean moveUp = false;
boolean moveDown = false;

void keyPressed()
{
  switch(key)
  {
    //for the control keys
    case KEY_VIEW: switchProjection(); break;
    case KEY_TEXTURE: doTextures = !doTextures; break;
    case KEY_COLLISION: doCollision = !doCollision; break;
    case KEY_BONUS: doBonus = !doBonus; break;
    case KEY_DRIFT: doDrifting=!doDrifting;break;
    case KEY_ENEMY: doEnemies=!doEnemies;break;
  }
  
  //for the movement keys
  if(key == KEY_LEFT)
    moveLeft=true;
  if(key == KEY_RIGHT)
    moveRight=true;
  if(key == KEY_DOWN)
    moveDown=true;
  if(key == KEY_UP)
    moveUp=true;
  if(key==' ')
    player.shoot();
}

void keyReleased() 
{
  if(key == KEY_LEFT)
    moveLeft=false;
  if(key == KEY_RIGHT)
    moveRight=false;
  if(key == KEY_DOWN)
    moveDown=false;
  if(key == KEY_UP)
    moveUp=false;
}
