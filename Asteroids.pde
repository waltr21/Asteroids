import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.ArrayList;

ArrayList<MenuButton> buttons;
ArrayList<Asteroid> asteroids;
MenuButton play, playOnline, netWork, search, host;
int scene, level, port;
Ship player;
DatagramChannel udp;
SocketChannel tcp;
String address, playerName;
GameScene soloScene, onlineScene;
HostScene hostScene;

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
    address = "127.0.0.1";
    port = 8765;

    //Set up buttons
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Solo", 0, 1);
    playOnline = new MenuButton(width/2, height/2, 2.5, "Online", 0, 3);
    search = new MenuButton(width/2 - 175, height/2 + 300, 2, "Search", 3, 4);
    host = new MenuButton(width/2 + 175, height/2 + 300, 2, "Host", 3, 5);
    buttons.add(play);
    buttons.add(playOnline);
    buttons.add(search);
    buttons.add(host);
    playerName = "SoCo";


    asteroids = new ArrayList<Asteroid>();
    soloScene = new GameScene(player, asteroids, false);
    onlineScene = new GameScene(player, asteroids, true);
    hostScene = new HostScene();

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
            soloScene.show();
            break;
        case 2:
            onlineScene.show();
            break;
        case 3:
            hostScene.show();
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
    playOnline.show();
}

/**
 * Call the click buttons for the buttons when there is a mouse click.
 */
void buttonsCLicked(){
    for (MenuButton mb : buttons){
        int tempScene = mb.setClicked(scene);
        if (tempScene >= 0){
            if (tempScene == 5){
                hostScene.setHost();
                return;
            }
            else if (tempScene == 4){
                hostScene.setSearch();
                return;
            }

            if (tempScene == 1){
                soloScene = new GameScene(player, asteroids, false);
                System.out.println("hit");
            }
            else if (tempScene == 2){
                onlineScene = new GameScene(player, asteroids, true);
            }
            scene = tempScene;
        }
    }
}

/**
 * Mouse click handle.
 */
void mousePressed(){
    buttonsCLicked();
    //player.processClick();
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
