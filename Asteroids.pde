ArrayList<MenuButton> buttons;
ArrayList<Asteroid> asteroids;
MenuButton play;
int scene;
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
    buttons = new ArrayList<MenuButton>();
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Single Player", 0, 1);
    asteroids = new ArrayList<Asteroid>();
    asteroids.add(new Asteroid(100, 100, 4));
    asteroids.add(new Asteroid(100, 100, 5));
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
    player.show();
    showAsteroids();
}

void showAsteroids(){
    for (Asteroid a : asteroids){
        a.show();
    }
}

/**
 * Call the click buttons for the buttons when there is a mouse click.
 */
void buttonsCLicked(){
    for (MenuButton mb : buttons){
        int tempScene = mb.setClicked(scene);
        if (tempScene > 0)
            scene = tempScene;
    }
}

/**
 * Mouse click handle.
 */
void mousePressed(){
    buttonsCLicked();
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
