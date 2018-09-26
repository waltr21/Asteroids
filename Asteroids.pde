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
    frameRate(60);
    player = new Ship();
    scene = 0;
    level = 1;
    buttons = new ArrayList<MenuButton>();
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Solo", 0, 1);
    play.setPrimary(51,51,51);
    play.setSecondary(146,221,200);
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
    // fill(255);
    // text(int(frameRate), 50, 50);
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
    showScene1Text();
    if(!player.show()){
        scene = 0;
        return;
    }
    showAsteroids();
    checkLevel();
}

void showScene1Text(){
    String levelString = "Level " + level + "\n" + player.getScore();
    fill(255);
    text(levelString, width/2, 50);
    String liveString = "";
    for (int i = 0; i < player.getLives(); i++){
        liveString += " | ";
    }
    text(liveString, 50, 50);
}

/**
 * Display all of the asteroids to the screen.
 */
void showAsteroids(){
    for (Asteroid a : asteroids){
        a.show();
    }
}

void resetAstroids(int level){
    asteroids.clear();
    int num = 2 + (level * 2) ;
    for (int i = 0; i < num; i++){
        float tempX = random(50, width - 50);
        float tempY = random(50, height/2 - 150) + ((height/2 + 150) * int(random(0, 2)));
        asteroids.add(new Asteroid(tempX, tempY, 3, player));
        player.resetPos();
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
    if (key == 'r')
        resetAstroids(level);
}
