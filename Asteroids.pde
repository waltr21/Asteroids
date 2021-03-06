import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.concurrent.CopyOnWriteArrayList;


ArrayList<MenuButton> buttons;
CopyOnWriteArrayList<Asteroid> asteroids;
MenuButton play, playOnline, network, search, host, menu;
TextBox nameBox, addressBox, portBox;
int scene, level, port, numBullets;
Ship player;
DatagramChannel udp;
SocketChannel tcp;
String address, playerName;
GameScene soloScene;
OnlineScene onlineScene;
HostScene hostScene;
NetworkScene networkScene;
boolean online;

void setup(){
    size(1000, 700, OPENGL);
    initScene();
}

/**
 * Initialize variables when the game first begins.
 */
void initScene(){
    frameRate(60);
    loadData();

    player = new Ship();
    scene = 0;
    level = 1;
    numBullets = 0;
    buttons = new ArrayList<MenuButton>();
    // address = "127.0.0.1";
    port = 8765;
    online = false;

    //Set up buttons
    play = new MenuButton(width/2, height/2 - 100, 2.5, "Solo", 0, 1);
    playOnline = new MenuButton(width/2, height/2, 2.5, "Online", 0, 3);
    search = new MenuButton(width/2 - 175, height/2 + 300, 2, "Search", 3, 4);
    host = new MenuButton(width/2 + 175, height/2 + 300, 2, "Host", 3, 5);
    network = new MenuButton(width/2, height/2 + 100, 2.5, "Network", 0, 6);
    menu = new MenuButton(width/2, height/2 + 300, 2.5, "Menu", 6, 0);

    buttons.add(play);
    buttons.add(playOnline);
    buttons.add(search);
    buttons.add(host);
    buttons.add(network);
    buttons.add(menu);

    nameBox = new TextBox(width/2, height/2 - 100, 3, "Name:");
    nameBox.setText(playerName);
    nameBox.setLimit(5);

    addressBox = new TextBox(width/2, height/2, 3, "IP:");
    addressBox.setText(address);

    portBox = new TextBox(width/2, height/2 + 100, 3, "Port:");
    portBox.setText(port + "");
    portBox.setInt();
    portBox.setLimit(6);

    asteroids = new CopyOnWriteArrayList<Asteroid>();
    soloScene = new GameScene();
    //onlineScene = new OnlineScene();
    hostScene = new HostScene();
    networkScene = new NetworkScene();
}

void loadData(){
    String[] data = loadStrings("Network.txt");
    if (data == null){
        String[] tempData = {"Temp", "127.0.0.1", "8765"};
        saveStrings("Network.txt", tempData);
        data = loadStrings("Network.txt");
    }

    playerName = data[0];
    address = data[1];
    port = Integer.parseInt(data[2]);
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
            online = false;
            break;
        case 2:
            onlineScene.show();
            online = true;
            break;
        case 3:
            hostScene.show();
            break;
        case 6:
            networkScene.show();
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
    network.show();
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
                soloScene = new GameScene();
            }
            else if (tempScene == 2){
                hostScene.sendStartPacket();
            }
            scene = tempScene;
        }
    }
}

/**
 * Mouse click handle.
 */
void mousePressed(){
    if(scene == 6){
        nameBox.setClicked();
        addressBox.setClicked();
        portBox.setClicked();
    }
    buttonsCLicked();
    //player.processClick();
}

/**
 * Button released handle.
 */
void keyReleased(){
    int code;
    if (keyCode > 40){
        code = int(Character.toLowerCase(key));
    }
    else{
        code = keyCode;
    }
    player.processButtonReleased(int(Character.toLowerCase(code)));
}

/**
 * Button pressed handle.
 */
void keyPressed(){
    // char k = key;
    //System.out.println(keyCode);
    int code;
    if (keyCode > 40){
        code = int(Character.toLowerCase(key));
    }
    else{
        code = keyCode;
    }

    if (key == TAB)
        scene = 0;
    // System.out.println("KeyCode: " + keyCode);
    // System.out.println("Code: " + code);


    player.processButtonPress(code);
    if (scene == 6){
        nameBox.processKey(keyCode);
        addressBox.processKey(keyCode);
        portBox.processKey(keyCode);
    }
}
