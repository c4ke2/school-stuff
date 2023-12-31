//responsible for making and running
//the enemies, and resetting them
//at the start of a new game

class EnemySpawner
{
  int maxSpawns = 5;
  
  Enemy[] list = new Enemy[maxSpawns];
  
  EnemySpawner()
  {
     list[0] = new Enemy(900);
     list[1] = new Enemy(700);
     list[2] = new Enemy(400);
     list[3] = new Enemy(200);
     list[4] = new Enemy(100);
  }
  
  void operateAll()
  {
    for(int i=0;i<list.length;i++)
    {
      list[i].moveEnemy();
      list[i].drawEnemy();
    }
  }
  
  void resetEnemies()
  {
     list[0].dormant =(900);
     list[1].dormant =(700);
     list[2].dormant =(400);
     list[3].dormant =(200);
     list[4].dormant =(100);
  }
}
