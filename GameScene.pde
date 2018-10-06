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
            float tempY = random(50, height/2 - 150) + ((height/2 + 150) * int(random(0, 2)));
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
