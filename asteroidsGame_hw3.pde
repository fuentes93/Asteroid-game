 // Luis Fuentes 900414515 cs3310 Professor Ling Xu
// background of stars moving in background
Star[] stars = new Star[600];
Ship ship;
Timer sw;

import ddf.minim.*;    // omport sound librery
Minim minim;
                      // different audiofiles for game
AudioPlayer file;
AudioPlayer ex;
AudioPlayer bgm;
boolean upPressed = false;//CHANGE LEFT AND RIGHT TO UP AND DOWN( IN SHIP TOO)
boolean downPressed = false;
boolean rightPressed = false;
boolean leftPressed = false;

float speed;
float shipSpeed = 2;
float bulletSpeed = 13;
int ammo=20;            // you start with 20 bullets for every hit with an asteroid you gain 2 bullets 
int numAsteroids = 31; //the number of asteroids
int startingRadius = 31; //the size of an asteroid
int score;
PImage asteroidPic;
PImage rocket;
int health=100;        // ship health

ArrayList<Bullet> bullets;
ArrayList<Asteroid> asteroids;

int crash=30;    // if a ship crashes they lose 30-60 health points depending on the asteroid health
PFont font;

// game state variables
int gameState;
public final int INTRO = 1;
public final int PLAY = 2;
public final int PAUSE = 3;
public final int GAMEOVER = 4;
public final int WON = 5;
public final int CREDITS = 6;

void setup()
{


   background(0);
   size(1000,600);
   font = createFont("Cambria", 32); 
   frameRate(24);
   minim= new Minim(this);
  println (millis());
            sw = new Timer();
            sw.start();
   asteroidPic = loadImage("asteroid.png");
   rocket = loadImage("rocket.png");
 
   asteroids = new ArrayList<Asteroid>(0);
 
   gameState = INTRO;
      file = minim.loadFile("laser.mp3");
      ex = minim.loadFile("explosion.mp3");
      bgm =minim.loadFile("bgm.mp3");
      
      // star background
    for (int i = 0; i < stars.length; i++) {
    stars[i] = new Star();
  }
}


void draw()
{             bgm.play();
  switch(gameState) 
  {
    case INTRO:
      drawScreen("Welcome!", "Press s to start");
      break;
    case PAUSE:
      drawScreen("PAUSED", "Press p to resume");
      break;
    case GAMEOVER:
      drawScreen("GAME OVER", "Press s to try again");
      health=100;
      ammo=20;
      score=0;
      break;
        case CREDITS:
      drawScreen("Credits: \nHW 3  \nBy Luis Fuentes", "Press c to resume");        // credits for game
      break;
        case WON:
      drawScreen("You won", "Press s to try again");                      // You win if you get 100 points within 30 seconds
      health=100;
      score=0;
      break;
    case PLAY:
      background(0);
      ship.update();
      ship.render(); 
    
    speed = map(mouseX, 0, width, 0, 20);                  // speed of background increases as mouse moves to the right
                 
      if(ship.checkCollision(asteroids) || asteroids.size() <=0)        // checks for asteroid collision
      health=health-crash;                                              // If ship colides 30-60 health dmage depending on asteroid health
            if(health<=10)
             gameState = GAMEOVER;
          if(score>99&& sw.second()<31)                          // you win if you have over 100 points in less than 30 seconds
          gameState= WON;
      else
      {   fill(0, 102, 153);
            text("Health", 50, 5);                  //  displays text on upper left side
            text(health,115,5);
            text("Score", 45, 33);
            text(score,105,33);
           text("ammo", 50, 60);   
  text(ammo,115,60); 
          textSize(20);
  text(nf(sw.minute(), 2)+":"+nf(sw.second(), 2), 400, 1);
          for(int i = 0; i < bullets.size(); i++)
          {    
             bullets.get(i).update();
             bullets.get(i).render();
            if(bullets.get(i).checkCollision(asteroids))      // checks if bullets have collided with asteroid
            {
               bullets.remove(i);                              // Player receives +2 ammo and 5 points for every asteroid hit, it takes 2 hits to destroy an asteroid
                      ammo++;    ammo++;
              score++;score++;score++;score++;score++;
               i--;
            }                        
          }     
          for(int i=0; i<asteroids.size(); i++)//(Asteroid a : asteroids)
          {
             asteroids.get(i).update();            
             asteroids.get(i).render(); 
          }
          
         float theta = heading2D(ship.rotation)+PI/2;    
             if(leftPressed)
              rotate2D(ship.rotation,-radians(5));     
             if(rightPressed)
              rotate2D(ship.rotation, radians(5));
             if(upPressed)
         {
            ship.acceleration = new PVector(0,shipSpeed); 
            rotate2D(ship.acceleration, theta);
         }    
      translate(width/2, height/2);
                 for (int i = 0; i < stars.length; i++) {
                  stars[i].update();
                  stars[i].show();
  }         
       }
       break;
  }
}
//Initialize the game settings. Create ship, bullets, and asteroids
void initializeGame() 
{
   ship  = new Ship();
   bullets = new ArrayList<Bullet>();   
   asteroids = new ArrayList<Asteroid>();
   
   for(int i = 0; i <numAsteroids; i++)
   {
      PVector position = new PVector((int)(Math.random()*width), 50);      
      asteroids.add(new Asteroid(position, startingRadius, asteroidPic));
   }
}                                            // function that fires bullets, the sound file is played and the player loses one bullet
void fireBullet()
  { 
  
  println("fire");//this line is for debugging purpose
      ammo--;
      file.play();
  file.rewind();
  // ship vectors and postion
  PVector pos = new PVector(0, ship.r*2);
  rotate2D(pos,heading2D(ship.rotation) + PI/2);
  pos.add(ship.position);
  // bullet position and vectors
  PVector vel  = new PVector(0, bulletSpeed);
  rotate2D(vel, heading2D(ship.rotation) + PI/2);
  bullets.add(new Bullet(pos, vel));
        }

void keyPressed()         
{ 
  if(key== 's' && ( gameState==INTRO || gameState==GAMEOVER || gameState==WON )) 
  {
    initializeGame();  
    gameState=PLAY;    
  }
          if(key=='p' && gameState==PLAY)
      gameState=PAUSE;
          else if(key=='p' && gameState==PAUSE)
      gameState=PLAY;
  
          if(key=='c' && gameState==PLAY)
      gameState=CREDITS;
          else if(key=='c' && gameState==CREDITS)
       gameState=PLAY;
  //when space key is pressed, fire a bullet only if ammo is greater than 1
        if(key == ' ' && gameState == PLAY&&ammo>=1)
     fireBullet();
        if(key==CODED && gameState == PLAY)
        
  {                     // if statements for ship movements
     if(keyCode==UP) 
       upPressed=true;
     else if(keyCode==DOWN)
       downPressed=true;
     else if(keyCode == LEFT)
       leftPressed = true;  
     else if(keyCode==RIGHT)
       rightPressed = true;        
  }
}
 
void keyReleased()          // function for key releases
{
        if(key==CODED)
    {
        if(keyCode==UP)
   {
     upPressed=false;
     ship.acceleration = new PVector(0,0);  
   } 
        else if(keyCode==DOWN)
   {
     downPressed=false;
     ship.acceleration = new PVector(0,0); 
   } 
       else if(keyCode==LEFT)
      leftPressed = false; 
       else if(keyCode==RIGHT)
      rightPressed = false;           
  } 
}

void drawScreen(String title, String instructions) 
{
      background(0,0,0); 
  // draw title
      fill(255,100,0);
      textSize(60);
      textAlign(CENTER, BOTTOM);
      text(title, width/2, height/2);
  // draw instructions
      fill(255,255,255);
      textSize(32);
      textAlign(CENTER, TOP);
      text(instructions, width/2, height/2);
}
float heading2D(PVector pvect)
{
   return (float)(Math.atan2(pvect.y, pvect.x));  
}
    void rotate2D(PVector v, float theta) 
{
    float xTemp = v.x;
    v.x = v.x*cos(theta) - v.y*sin(theta);
    v.y = xTemp*sin(theta) + v.y*cos(theta);
}