ArrayList<MenuButton> buttons;
MenuButton play;
int scene;
Ship player;

void setup(){
    size(900, 900, OPENGL);
    initScene();
}

void initScene(){
    player = new Ship();
    scene = 0;
    buttons = new ArrayList<MenuButton>();
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Single Player", 0, 1);
    buttons.add(play);
}

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

void scene0(){
    background(51);
    play.show();
}

void scene1(){
    background(0);
    player.show();
}

void buttonsCLicked(){
    for (MenuButton mb : buttons){
        int tempScene = mb.setClicked(scene);
        if (tempScene > 0)
            scene = tempScene;
    }
}

void mousePressed(){
    buttonsCLicked();
}

void keyReleased(){
    player.processButtonReleased(key);
}

void keyPressed(){
    player.processButtonPress(key);
}
