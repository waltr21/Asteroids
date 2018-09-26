ArrayList<MenuButton> buttons;
ArrayList<Asteroid> asteroids;
MenuButton play;
int scene, level;
Ship player;

void setup(){
    size(900, 900, OPENGL);
    initScene();
}

/**
 * Initialize variables when the game first begins.
 */
void initScene(){
    player = new Ship();
    scene = 0;
    level = 1;
    buttons = new ArrayList<MenuButton>();
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Single Player", 0, 1);
    asteroids = new ArrayList<Asteroid>();
    resetAstroids(level);
    buttons.add(play);
}

/**
 * Draw the appropriate scene
 */
void draw(){
    switch(scene){
        case 0:
            scene0();
            break;
        case 1:
            scene1();
            break;
    }
}

/**
 * Scene for the main menu.
 */
void scene0(){
    background(51);
    play.show();
}

/**
 * Scene for the actual game.
 */
void scene1(){
    background(0);
    String levelString = "Level " + level;
    fill(255);
    text(levelString, width/2, 50);
    player.show();
    showAsteroids();
    checkLevel();
}

void showAsteroids(){
    for (Asteroid a : asteroids){
        a.show();
    }
}

void resetAstroids(int level){
    asteroids.clear();
    int num = 2 + (level * 2) ;
    for (int i = 0; i < num; i++){
        float tempX = random(100, width - 100);
        float tempY = random(100, height/2 - 200); //+ (random(100, height/2 - 200) * int(random(0, 2)));
        asteroids.add(new Asteroid(tempX, tempY, 3));
    }
}

void checkLevel(){
    if (asteroids.size() < 1){
        level++;
        resetAstroids(level);
    }
}

/**
 * Call the click buttons for the buttons when there is a mouse click.
 */
void buttonsCLicked(){
    for (MenuButton mb : buttons){
        int tempScene = mb.setClicked(scene);
        if (tempScene > 0){
            scene = tempScene;
            if (tempScene == 1){
                level = 1;
                resetAstroids(level);
            }
        }
    }
}

/**
 * Mouse click handle.
 */
void mousePressed(){
    buttonsCLicked();
    player.processClick();
}

/**
 * Button released handle.
 */
void keyReleased(){
    player.processButtonReleased(key);
}

/**
 * Button pressed handle.
 */
void keyPressed(){
    player.processButtonPress(key);
}
