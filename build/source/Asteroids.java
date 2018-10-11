import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.*; 
import java.net.*; 
import java.nio.*; 
import java.nio.channels.*; 
import java.util.ArrayList; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Asteroids extends PApplet {







ArrayList<MenuButton> buttons;
ArrayList<Asteroid> asteroids;
MenuButton play, playOnline, network, search, host, menu;
TextBox nameBox, addressBox, portBox;
int scene, level, port;
Ship player;
DatagramChannel udp;
SocketChannel tcp;
String address, playerName;
GameScene soloScene;
OnlineScene onlineScene;
HostScene hostScene;
NetworkScene networkScene;

public void setup(){
    
    initScene();
}

/**
 * Initialize variables when the game first begins.
 */
public void initScene(){
    frameRate(60);
    loadData();

    player = new Ship();
    scene = 0;
    level = 1;
    buttons = new ArrayList<MenuButton>();
    address = "127.0.0.1";
    port = 8765;

    //Set up buttons
    play = new MenuButton(width/2, height/2 - 100, 2.5f, "Solo", 0, 1);
    playOnline = new MenuButton(width/2, height/2, 2.5f, "Online", 0, 3);
    search = new MenuButton(width/2 - 175, height/2 + 300, 2, "Search", 3, 4);
    host = new MenuButton(width/2 + 175, height/2 + 300, 2, "Host", 3, 5);
    network = new MenuButton(width/2, height/2 + 100, 2.5f, "Network", 0, 6);
    menu = new MenuButton(width/2, height/2 + 300, 2.5f, "Menu", 6, 0);

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

    asteroids = new ArrayList<Asteroid>();
    soloScene = new GameScene();
    onlineScene = new OnlineScene();
    hostScene = new HostScene();
    networkScene = new NetworkScene();
}

public void loadData(){
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
public void draw(){
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
public void scene0(){
    background(51);
    play.show();
    playOnline.show();
    network.show();
}

/**
 * Call the click buttons for the buttons when there is a mouse click.
 */
public void buttonsCLicked(){
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
                onlineScene = new OnlineScene();
                hostScene.sendStartPacket();
            }
            scene = tempScene;
        }
    }
}

/**
 * Mouse click handle.
 */
public void mousePressed(){
    buttonsCLicked();
    nameBox.setClicked();
    addressBox.setClicked();
    portBox.setClicked();
    //player.processClick();
}

/**
 * Button released handle.
 */
public void keyReleased(){
    player.processButtonReleased(key);
}

/**
 * Button pressed handle.
 */
public void keyPressed(){
    player.processButtonPress(key);
    if (scene == 6){
        nameBox.processKey(keyCode);
        addressBox.processKey(keyCode);
        portBox.processKey(keyCode);
    }
}
public class Asteroid{
    float x, y, size;
    int level, maxLevel;
    PVector velocity;
    Ship p;

    /**
     * Constructor for the Asteroid class.
     * @param x     X pos of the asteroid
     * @param y     Y pos of the asteroid
     * @param level Level of asteroid (1-3)
     * @param p     Current player (Used for x/y refernecing)
     */
    public Asteroid(float x, float y, int level, Ship p){
        this.x = x;
        this.y = y;
        this.size = 30 * level;
        this.level = level;
        this.maxLevel = 3;
        this.p = p;
        this.velocity = PVector.fromAngle(random(-PI, PI));
        this.velocity.mult(((maxLevel+1) - level) * 0.8f);
    }


    /**
     * Bound the Asteroid to stay inside of the screen.
     */
    public void bound(){
        if (x + size < 0){
            x = width + size/2;
        }
        else if (x - size > width){
            x = 0 - size/2;
        }

        if (y + size < 0){
            y = height + size/2;
        }
        else if (y - size > height){
            y = 0 - size/2;
        }
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public void checkHit(){
        float distance = dist(x, y, p.getX(), p.getY());
        //System.out.println(distance);
        if (distance < size/2 + p.getSize()){
            p.setHit();
        }
    }

    public void explode(){
        if (level > 1){
            int numChildren = 2;
            asteroids.remove(this);
            for (int i = 0; i < numChildren; i++){
                asteroids.add(new Asteroid(x, y, level - 1, player));
            }
        }
        else{
            asteroids.remove(this);
        }
    }

    public int getScore(){
        if (level == 1)
            return 100;
        else if (level == 2)
            return 50;
        else
            return 20;

    }

    public void show(){
        pushMatrix();
        checkHit();
        travel();
        bound();
        noFill();
        stroke(255);
        ellipseMode(CENTER);
        translate(x, y);
        ellipse(0, 0, size, size);
        popMatrix();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public float getSize(){
        return size;
    }
}
public class Bullet{
    float x, y, angle, size;
    int count;
    PVector velocity;
    Ship p;

    public Bullet(float x, float y, float angle, Ship p){
        this.x = x;
        this.y = y;
        this.angle = angle - PI/2;
        this.size = 50;
        this.count = 0;
        this.p = p;
        this.velocity = PVector.fromAngle(this.angle);
        this.velocity.mult(8);
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public boolean bound(){
        if (x + size < 0){
            x = width + size;
        }
        else if (x - size > width){
            x = 0 - size;
        }

        if (y + size < 0){
            y = height + size;
        }
        else if (y - size > height){
            y = 0 - size;
        }

        if(count > 900){
            return true;
        }
        else{
            count += 8;
            return false;
        }
    }

    public void checkHit(){
        for (Asteroid a : asteroids){
            float distance = dist(a.getX(), a.getY(), x, y);
            if (distance < a.getSize()/2 + size/2){
                p.addScore(a.getScore());
                a.explode();
                count = 1000;
                break;
            }
        }
    }

    public void show(){
        pushMatrix();
        ellipseMode(CENTER);
        translate(x, y);
        travel();
        noStroke();
        fill(255);
        ellipse(0, 0, size, size);
        popMatrix();
        checkHit();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

}
public class GameScene{
    boolean online;

    public GameScene(){
        level = 1;
        resetAstroids(level);
    }

    /**
     * Show the text of the scene
     */
    private void showText(){
        textSize(30);
        String levelString = "Level " + level + "\n" + player.getScore();
        fill(255);
        textSize(30);
        text(levelString, width/2, 50);
        String liveString = "";
        for (int i = 0; i < player.getLives(); i++){
            liveString += " | ";
        }
        text(liveString, 50, 50);
    }

    private void resetAstroids(int level){
        asteroids.clear();
        int num = 2 + (level * 2) ;
        for (int i = 0; i < num; i++){
            float tempX = random(50, width - 50);
            float tempY = random(50, height/2 - 150) + ((height/2 + 150) * PApplet.parseInt(random(0, 2)));
            asteroids.add(new Asteroid(tempX, tempY, 3, player));
            player.resetPos();
            player.clearBullets();
        }
    }

    /**
     * Display all of the asteroids to the screen.
     */
    private void showAsteroids(){
        for (Asteroid a : asteroids){
            a.show();
        }
    }

    private void checkLevel(){
        if (asteroids.size() < 1){
            level++;
            resetAstroids(level);
        }
    }

    public void show(){
        background(0);
        showText();
        if(!player.show()){
            scene = 0;
            return;
        }
        showAsteroids();
        checkLevel();
    }
}
public class HostScene{
    boolean searchBool, hostBool, threadMade, hostScene, error;
    String hostString, searchString, allClients;
    ArrayList<String> clientList;
    Thread tempThread;

    public HostScene(){
        searchBool = false;
        hostBool = false;
        hostScene = true;
        threadMade = false;
        error = false;
        hostString = "Waiting for players...";
        searchString = "Searching for games...";
        allClients = "";
        clientList = new ArrayList<String>();
    }

    public void setSearch(){
        if (!threadMade){
            try{
                udp = DatagramChannel.open();
                tcp = SocketChannel.open();
                tcp.connect(new InetSocketAddress(address, port));
                tempThread = new Thread(new Runnable() {
                    public void run() {
                        runTCP();
                    }
                });
                tempThread.start();
                threadMade = true;
            }
            catch(Exception e){
                System.out.println(e);
            }
        }
        host.setText("Host");
        host.setScene(5);
        hostBool = false;
        searchBool = true;
        sendSearchPacket();
    }

    public void setHost(){
        if (!threadMade){
            try{
                udp = DatagramChannel.open();
                tcp = SocketChannel.open();
                tcp.connect(new InetSocketAddress(address, port));
                Thread t = new Thread(new Runnable() {
                    public void run() {
                        runTCP();
                    }
                });
                t.start();
                threadMade = true;
            }
            catch(Exception e){
                System.out.println(e);
            }
        }

        hostBool = true;
        searchBool = false;
        address = "127.0.0.1";
        sendHostPacket();
        if (!error){
            host.setText("Start");
            host.setScene(2);
        }
    }

    private void showHostText(){
        if (hostBool){
            fill(146,221,200);
            textAlign(CENTER);
            text(hostString, width/2, 100);
        }
    }

    private void showSearchText(){
        if (searchBool){
            fill(146,221,200);
            textAlign(CENTER);
            text(searchString, width/2, 100);
        }
    }

    private boolean sendHostPacket(){
        try{
            //Connect to TCP
            String packetString = playerName + ",1";
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            tcp.write(buffer);
            hostString = "Waiting for players...";
        }
        catch(Exception e){
            System.out.println("Error in sendInitPacket " + e);
            hostString = ("\n\nError connecting to local server. You probably didn't open the server.");
            error = true;
            return false;
        }
        error = false;
        return true;
    }

    private boolean sendSearchPacket(){
        try{
            String packetString = playerName + ",0";
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            tcp.write(buffer);
            searchString = "Searching for games...";
        }
        catch(Exception e){
            System.out.println("Error in sendSearchPacket " + e);
            searchString = ("Error connecting to server. IP adress is probably wrong.");
            return false;
        }
        searchString = "Game found! Waiting for host to start.";
        return true;
    }

    public void sendStartPacket(){
        try{

            String packetString = playerName + ",2";
            for (String s : clientList){
                playerName += "," + s;
            }
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            host.setText("Host");
            host.setScene(5);
            hostScene = false;
            hostBool = false;
            searchBool = true;
            tcp.write(buffer);
            String temp = playerName + ",-1";
            System.out.println("Sent: " + packetString);

            ByteBuffer buffer2 = ByteBuffer.wrap(temp.getBytes());
            tcp.write(buffer2);
            onlineScene.setTeam(clientList);
        }
        catch(Exception e){
            System.out.println("Error in sendStartPacket " + e);
        }
    }

    public void show(){
        background(51);
        search.show();
        showHostText();
        host.show();
        showSearchText();
    }

    //Search for tcp packets back from the server.
    private void runTCP(){
        System.out.println("Thread Made.");
        //Keep searching while we are in this scene.
        while(hostScene){
            try{
                ByteBuffer buffer = ByteBuffer.allocate(1024);
                tcp.read(buffer);
                String temp = new String (buffer.array()).trim();
                // System.out.println("new String(buffer.array()).trim()");
                processTCP(temp);
            }
            catch(Exception e){
                System.out.println(e);
                threadMade = false;
                break;
            }
        }
        System.out.println("Thread closed.");
    }

    private void processTCP(String packet){
        String[] splitMessage = packet.split(",");
        if (splitMessage[1].equals("0") && hostBool){
            addClient(splitMessage[0]);
            hostString = "Waiting for players...\n" + allClients;
        }
        if (splitMessage[1].equals("2")){
            //System.out.println(splitMessage[2]);
            clientList.add(splitMessage[0]);
            for (int i = 2; i < splitMessage.length; i++){
                if (!splitMessage[i].equals(playerName)){
                    clientList.add(splitMessage[i]);
                }
            }
            host.setText("Host");
            host.setScene(5);
            hostScene = false;
            onlineScene = new OnlineScene();
            onlineScene.setTeam(clientList);
            scene = 2;
        }
    }

    private void addClient(String name){
        boolean found = false;
        for (String temp : clientList){
            if (name.equals(name)){
                found = true;
                break;
            }
        }

        if (!found){
            allClients += name;
            clientList.add(name);
        }
    }
}
public class MenuButton{
    float x, y, w, h, scale, aWidth, speed;
    int scene, currentScene;
    int primary, secondary;
    String text;
    boolean clicked, hovered, animationFinished;

    /**
     * Constuctor for the MenuButton class. Button is drawn from the center
     * @param x            X pos for the button to be displayed.
     * @param y            Y pos for the button to be displayed.
     * @param scale        Scale the buttons up (above 1) if they are too small.
     * @param text         Text to display in the button
     * @param scene        Scene you wish to transition to.
     * @param currentScene Scene the button currently lives in.
     */
    public MenuButton(float x, float y, float scale, String text, int currentScene, int scene){
        this.x = x;
        this.y = y;
        this.aWidth = 0;
        this.scene = scene;
        this.currentScene = currentScene;
        this.text = text;
        this.scale = scale;
        this.speed = 12 * scale;
        this.w = 150 * scale;
        this.h = 23 * scale;
        this.primary = color(51,51,51);
        this.secondary = color(146,221,200);
        this.clicked = false;
        this.hovered = false;
        this.animationFinished = false;

        PFont font = createFont("AppleSDGothicNeo-Thin-48.vlw", 80);
        textFont(font);
    }

    /**
     * Animation for when the cursor is hovered over the button.
     */
    public void animateHover(){
        //Is the cursor over the button? If so expand the animation rect.
        if (isHovered()){
            //Make sure the animation rect stops growing when it is larger than
            //the button width.
            if (aWidth < w)
                aWidth += speed;
            //Snap the animation rect to the width of the button if it is too large.
            if (aWidth > w)
                aWidth = w;
        }
        //If we are not hovered over the button then shrink the animation rect.
        else{
            //Make sure the animation rect stops shrinking when it is smaller than 0
            if(aWidth > 0)
                aWidth -= speed;
            //Snap the animation rect to the width of the button if it is too small.
            if(aWidth < 0)
                aWidth = 0;
        }

        //Simply draw the rect if it is larger than 0
        if (aWidth > 0){
            rectMode(CORNER);
            fill(secondary);
            rect((x - w/2), y - (h/2), aWidth, h);
        }
    }

    /**
     * Display a click if the button is actually clicked
     * @param s [description]
     */
    public int setClicked(int s){
        //If the mouse is over the button and we are in the current scene of the
        //button.
        if (isHovered() && s == currentScene){
            aWidth = 0;
            cursor(ARROW);
            return scene;
        }
        return -1;
    }

    /**
     * Change the primary color of the button (RGB)
     * @param r red
     * @param g green
     * @param b blue
     */
    public void setPrimary(int r, int g, int b){
        primary = color(r, g, b);
    }

    /**
     * Change the secondary color of the button (RGB)
     * @param r red
     * @param g green
     * @param b blue
     */
    public void setSecondary(int r, int g, int b){
        secondary = color(r, g, b);
    }

    //Display the button to the screen.
    public void show(){
        noStroke();

        fill(primary);
        rectMode(CENTER);
        rect(x, y, w, h);

        animateHover();

        if (aWidth > w/2)
            fill(primary);
        else
            fill(secondary);

        textSize(12 * scale);
        textAlign(CENTER);
        text(text, x, y + (3 * scale));
    }

    /**
     * Set the scene to a different value.
     * @param s Scene number
     */
    public void setScene(int s){
        scene = s;
    }

    /**
     * Set the button text to a differnt value
     * @param s String val
     */
    public void setText(String s){
        text = s;
    }

    /**
     * Check to see if the mouse is hovered over the button.
     * @return [description]
     */
    public boolean isHovered(){
        if (mouseX > x - w/2 && mouseX < x + w/2){
            if (mouseY > y - h/2 && mouseY < y + h/2){
                hovered = true;
                cursor(HAND);
                return true;
            }
        }

        if(hovered)
            cursor(ARROW);

        hovered = false;
        return false;
    }

}
public class NetworkScene{
    String userName;

    public  NetworkScene(){

    }

    public void show(){
        background(51);
        nameBox.show();
        addressBox.show();
        portBox.show();
        menu.show();
    }
}
public class OnlineScene extends GameScene{
    boolean isHost;
    ArrayList<TeamShip> teammates;
    public OnlineScene(){
        super();
        teammates = new ArrayList<TeamShip>();
    }

    public void setTeam(ArrayList<String> names){
        for (String s : names){
            teammates.add(new TeamShip(s));
            System.out.println("Added: " + s);
        }
    }

    private void sendPackets(){
        try{
            ByteBuffer buff = ByteBuffer.wrap("This is a test".getBytes());
            //udp.send(buff, new InetSocketAddress(address, port));
        }
        catch(Exception e){
            System.out.println("Error in sending coordinate packets: " + e);
        }
    }

    public void show(){
        background(0);
        super.showText();
        showTeam();
        if(!player.show()){
            scene = 0;
            return;
        }
        super.showAsteroids();
        super.checkLevel();
    }

    public void showTeam(){
        for (TeamShip ts : teammates){
            ts.show();
        }
    }
}
public class Ship{
    float x, y, size, angle, turnRadius, deRate;
    ArrayList<Character> pressedChars;
    ArrayList<Bullet> bullets;
    boolean turn, accelerate, dead, noHit;
    long timeStamp;
    char k;
    int lives, maxLives, score;
    PVector velocity;

    /**
     * Constuctor for the ship class.
     * @param a Asteroids in the game for the ship to reference.
     */
    public Ship(){
        //X and Y for the ship.
        this.x = width/2;
        this.y = height/2;
        //Size of the ship.
        this.size = 20;
        this.angle = 0;
        this.turnRadius = 0.08f;
        this.deRate = 0.05f;
        this.turn = false;
        this.accelerate = false;
        this.dead = false;
        this.noHit = false;
        this.maxLives = 3;
        this.lives = maxLives;
        this.score = 0;
        //ArrayList for the current pressed characters.
        //(Mainly used for making turning less janky.)
        this.pressedChars = new ArrayList<Character>();
        this.bullets = new ArrayList<Bullet>();
        this.velocity = new PVector();
    }

    /**
     * Removes one of the current pressed characters from the Array.
     * If there are no characters left then we stop turning.
     * @param k key entered by the user.
     */
    private void freezeTurn(char k){

        //Loop through and find characters we should remove.
        for (int i = pressedChars.size() - 1; i >= 0; i--){
            if (pressedChars.get(i) == k){
                pressedChars.remove(i);
            }
        }

        //If there are no more charaters then we should stop turning.
        if(pressedChars.size() < 1)
            turn = false;
    }

    /**
     * Tell the ship to start to turn in the appropriate direction.
     * @param k key entered by the user.
     */
    private void setTurn(char k){
        //System.out.println("Turn");
        turn = true;
        this.k = Character.toLowerCase(k);
        pressedChars.add(this.k);
    }

    /**
     * Turn the ship X radians.
     */
    private void turn(){
        //Make sure we are in the scene and we should be turning.
        if (turn){
            if (k == 'a'){
                angle -= turnRadius;
            }
            if (k == 'd'){
                angle += turnRadius;
            }
        }
    }

    /**
     * Bound the player to stay inside of the screen.
     */
    private void bound(){
        if (x + size < 0){
            x = width + size;
        }
        else if (x - size > width){
            x = 0 - size;
        }

        if (y + size < 0){
            y = height + size;
        }
        else if (y - size > height){
            y = 0 - size;
        }
    }

    public void resetPos(){
        x = width/2;
        y = height/2;
        velocity.mult(0);
        angle = 0;
    }

    public void resetVars(){
        lives = maxLives;
        dead = false;
        score = 0;
        bullets.clear();
    }

    public void clearBullets(){
        bullets.clear();
    }

    /**
     * Move in the direction of the current velocity.
     */
    private void move(){
        x += velocity.x;
        y += velocity.y;

        //Adds "friction" to slow down the ship.
        velocity.mult(0.99f);
    }

    private void hyperDrive(){
        x = random(20, width - 20);
        y = random(20, height - 20);
    }

    /**
     * Accelerates the ship in the current faced direction.
     */
    private void accelerate(){
        if (accelerate){
            PVector force = PVector.fromAngle(angle - PI/2);
            //Limit how strong the force is.
            force.mult(0.08f);
            velocity.add(force);
        }
    }

    /**
     * Display the bullets and remove if out of the screen.
     */
    private void showBullets(){
        for (int i = bullets.size() - 1; i >= 0; i--){
            Bullet b = bullets.get(i);
            b.show();

            //If the bullet is out of the screen then we want to remove it.
            if (b.bound())
                bullets.remove(i);
        }
    }

    public void setHit(){
        if (!noHit){
            lives--;
            if (lives < 1){
                dead = true;
            }
            else{
                noHit = true;
                timeStamp = millis();
                resetPos();
            }
        }
    }

    private void checkNoHit(){
        if(noHit){
            if (millis() - timeStamp > 3000)
                noHit = false;
        }
    }

    private void shoot(){
        if (bullets.size() < 40){
            bullets.add(new Bullet(x, y, angle, this));
        }
    }

    public void addScore(int s){
        score += s;
    }

    /**
     * Display the ship to the screen.
     */
    public boolean show(){
        if (!dead){
            checkNoHit();
            pushMatrix();
            //Display the bullets
            showBullets();

            //Edit pos of the ship.
            turn();
            move();
            accelerate();
            bound();

            noFill();
            stroke(255);
            if (noHit)
                stroke(56, 252, 159);
            strokeWeight(3);
            translate(x, y);
            rotate(angle);

            triangle(-size, size, 0, -size - 5, size, size);

            popMatrix();
            return true;
        }
        resetVars();
        resetPos();
        return false;
    }

    /**
     * Handle the button pressed by the user.
     * @param k key entered by the user.
     */
    public void processButtonPress(char k){

        k = Character.toLowerCase(k);
        if (k == 'a' || k == 'd'){
            setTurn(k);
        }

        if (k == 'w'){
            accelerate = true;
        }

        if (k == ' '){
            shoot();
        }

        if (k == '\n'){
            hyperDrive();
        }
    }

    /**
     * Handle the button released by the user.
     * @param k key entered by the user.
     */
    public void processButtonReleased(char k){
        k = Character.toLowerCase(k);
        if (k == 'a' || k == 'd'){
            freezeTurn(k);
        }
        if (k == 'w'){
            accelerate = false;
        }
    }

    public void processClick(){
        shoot();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public float getSize(){
        return size;
    }

    public int getLives(){
        return lives;
    }

    public int getScore(){
        return score;
    }
}
public class TeamShip{
    String name;
    float x, y, angle, size;
    boolean dead;

    public TeamShip(String name){
        this.name = name;
        this.x = width/2;
        this.y = height/2;
        this.dead = false;
        this.angle = 0;
        this.size = 20;

    }

    public void show(){
        pushMatrix();

        noFill();
        stroke(255);
        strokeWeight(3);

        translate(x, y);
        rotate(angle);
        triangle(-size, size, 0, -size - 5, size, size);
        fill(255);
        text(name, x, y + size + 10);

        popMatrix();
    }
}
public class TextBox{
    float x, y, scale, w, h, blinkX;
    boolean clicked, blink, isInt;
    String text, plate;
    int limit;

    public TextBox(float x, float y, float scale, String plate){
        this.x = x;
        this.y = y;
        this.scale = scale;
        this.plate = plate;
        this.w = 150 * scale;
        this.h = 23 * scale;
        this.limit = 20;
        this.clicked = false;
        this.isInt = false;
        this.text = "";
        this.blink = true;
        this.blinkX = this.x;
        PFont font = createFont("AppleSDGothicNeo-Thin-48.vlw", 80);
        textFont(font);
    }

    public void show(){
        animate();
        noFill();
        strokeWeight(4);
        stroke(146,221,200);
        rectMode(CENTER);
        rect(x, y, w, h, 7);

        fill(255);
        textSize(12 * scale);
        textAlign(CENTER);
        text(text, x, y + (3 * scale));
        text(plate, x - (w/2 + textWidth(plate)/2 + 20), y + (3 * scale));

        if (blink && clicked){
            float yPos1 = y - (h/2 - 10) ;
            float yPos2 = y + (h/2 - 10);
            strokeWeight(2);
            line(blinkX, yPos1, blinkX, yPos2);
        }

        if(frameCount % 30 == 0){
            blink = !blink;
        }
    }

    public void setText(String s){
        text = s;
    }

    public void setLimit(int x){
        limit = x;
    }

    public void setInt(){
        isInt = true;
    }

    public void setClicked(){
        if (isHovered()){
            clicked = true;
            blink = true;
            return;
        }
        clicked = false;
    }

    public boolean isHovered(){
        if (mouseX > x - w/2 && mouseX < x + w/2){
            if (mouseY > y - h/2 && mouseY < y + h/2){
                return true;
            }
        }
        return false;
    }

    public void animate(){
        float difference = ((textWidth(text)/2) + 8 + x) - blinkX;
        //System.out.println(difference);

        if (difference >= 3){
            blinkX += 3;
            blink = true;
        }
        else if (difference <= -3){
            blinkX -= 3;
            blink = true;
        }
    }

    public void processKey(int code){
        if(clicked){
            //System.out.println((char) code);
            //Upper case
            if (text.length() < limit){
                if (code >= 65 && code <= 90 && !isInt){
                    text += (char) code;
                }
                //Lower case
                if (code >= 97 && code <= 122 && !isInt){
                    text += (char) code;
                }
                if (code >= 48 && code <= 57){
                    text += (char) code;
                }
                if (code == 46 && !isInt){
                    text += (char) code;
                }
            }
            if (code == 8){
                if (text.length() >= 1)
                    text = text.substring(0, text.length() - 1);
            }

            if (code == 10){
                //For the port
                if (isInt){
                    int tempNum = Integer.parseInt(text);
                    port = tempNum;
                }
                //For the player name
                else if (limit == 5){
                    playerName = text;
                }
                //For the IP address
                else{
                    address = text;
                }
                clicked = false;
                String[] tempData = {playerName, address, port + ""};
                saveStrings("Network.txt", tempData);
            }
         }
    }

}
    public void settings() {  size(900, 900, OPENGL); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Asteroids" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
