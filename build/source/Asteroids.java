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
MenuButton play, playOnline, netWork, search, host;
int scene, level, port;
Ship player;
DatagramChannel udp;
SocketChannel tcp;
String address, playerName;
GameScene soloScene, onlineScene;
HostScene hostScene;

public void setup(){
    
    initScene();
}

/**
 * Initialize variables when the game first begins.
 */
public void initScene(){
    frameRate(60);
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
public void mousePressed(){
    buttonsCLicked();
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
        this.size = 5;
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
            if (distance < a.getSize()/2){
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
    Ship player;
    ArrayList<Asteroid> asteroids;
    boolean online;

    public GameScene(Ship player, ArrayList<Asteroid> asteroids, boolean online){
        this.player = player;
        this.asteroids = asteroids;
        this.online = online;
        level = 1;
        resetAstroids(level);
    }

    /**
     * Show the text of the scene
     */
    private void showText(){
        String levelString = "Level " + level + "\n" + player.getScore();
        fill(255);
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

    private void sendName(){
        try{
            String name = "Soco";
            ByteBuffer b = ByteBuffer.wrap(name.getBytes());
            tcp.write(b);
        }
        catch (Exception e){
            System.out.println("Error in sending name: " + e);
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
        showText();
        if(!player.show()){
            scene = 0;
            return;
        }
        showAsteroids();
        checkLevel();

        if (online){
            sendPackets();
        }
    }
}
public class HostScene{
    boolean searchBool, hostBool, threadMade, hostScene;
    String hostString, searchString;

    public HostScene(){
        searchBool = false;
        hostBool = false;
        hostScene = true;
        threadMade = false;
        hostString = "Waiting for players...";
        searchString = "Searching for games...";
    }

    public void setSearch(){
        if (!threadMade){
            try{
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
        hostBool = false;
        searchBool = true;
        sendSearchPacket();
    }

    public void setHost(){
        hostBool = true;
        searchBool = false;
        address = "127.0.0.1";
        sendHostPacket();
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
            // //Connnect to UDP
            udp = DatagramChannel.open();

            //Connect to TCP
            hostString = "Waiting for players...";
            return true;
        }
        catch(Exception e){
            System.out.println("Error in sendInitPacket " + e);
            hostString = "Waiting for players...";
            hostString += ("\n\nError connecting to local server. You probably didn't open the server.");
            return false;
        }
    }

    private boolean sendSearchPacket(){
        try{
            //Change to desired address.

            String packetString = playerName + ",0";
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            tcp.write(buffer);
            searchString = "Searching for games...";
        }
        catch(Exception e){
            System.out.println("Error in sendSearchPacket " + e);
            searchString = "Searching for games...";
            searchString += ("\n\nError connecting to server. IP adress is probably wrong.");
            return false;
        }
        searchString = "Game found! Waiting for host to start.";
        return true;
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
                System.out.println(new String(buffer.array()).trim());
            }
            catch(Exception e){
                System.out.println(e);
                threadMade = false;
                break;
            }
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
        if (bullets.size() < 4){
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
