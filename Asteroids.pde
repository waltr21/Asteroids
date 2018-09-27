import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.ArrayList;

ArrayList<MenuButton> buttons;
ArrayList<Asteroid> asteroids;
MenuButton play, playOnline;
int scene, level, port;
Ship player;
DatagramChannel udp;
SocketChannel tcp;
String address;

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
    playOnline = new MenuButton(width/2, height/2, 2.5, "Online", 0, 2);
    playOnline.setPrimary(51,51,51);
    playOnline.setSecondary(146,221,200);
    asteroids = new ArrayList<Asteroid>();
    resetAstroids(level);
    buttons.add(play);
    buttons.add(playOnline);

    try{
        //Connnect to UDP
        udp = DatagramChannel.open();
        address = "127.0.0.1";
        port = 8765;
        //Connect to TCP
        tcp = SocketChannel.open();
        tcp.connect(new InetSocketAddress(address, port));
    }
    catch(Exception e){
        System.out.println("Error in initScene: " + e);
    }

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
        case 2:
            scene2();
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

void scene2(){
    background(0);
    showScene1Text();
    if(!player.show()){
        scene = 0;
        return;
    }
    showAsteroids();
    checkLevel();
    try{
        ByteBuffer buff = ByteBuffer.wrap("This is a test".getBytes());
        //udp.send(buff, new InetSocketAddress(address, port));
    }
    catch(Exception e){
        System.out.println("Error in sending coordinate packets: " + e);
    }
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

void sendName(){
    try{
        String name = "Soco";
        ByteBuffer b = ByteBuffer.wrap(name.getBytes());
        tcp.write(b);
    }
    catch (Exception e){
        System.out.println("Error in sending name: " + e);
    }
}

void sendPackets(){

}

/**
 * Call the click buttons for the buttons when there is a mouse click.
 */
void buttonsCLicked(){
    for (MenuButton mb : buttons){
        int tempScene = mb.setClicked(scene);
        if (tempScene > 0){
            scene = tempScene;
            if (tempScene == 1 || tempScene == 2){
                level = 1;
                resetAstroids(level);
            }
            if (tempScene == 2){
                sendName();
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
