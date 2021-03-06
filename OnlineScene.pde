
/**
 * This class is used for drawing the online scene of the game.
 * It is also responsible for sending/receiving packets from the Server
 * to update the location of the other players in the game.
 */
public class OnlineScene extends GameScene{
    boolean isHost, temp;
    InetSocketAddress socket;
    ArrayList<TeamShip> teammates;
    long timeStamp;
    boolean out;

    /**
     * Constructor method for the OnlineScene class.
     * Calls the super class Constructor (GameScene) to reduce logic duplication.
     * @param host if we are the host of this scene.
     */
    public OnlineScene(boolean host){
        super();
        this.isHost = host;
        temp = true;
        out = false;
        timeStamp = millis();

        player.setLives(1);

        teammates = new ArrayList<TeamShip>();
        //Connect to the DatagramChannel.
        try{
            //Thread.sleep(500);

            udp = DatagramChannel.open();
            socket = new InetSocketAddress(address, port);
            Thread t1 = new Thread(new Runnable() {
                public void run() {
                    runUDP();
                }
            });
            t1.start();
            Thread t2 = new Thread(new Runnable() {
                public void run() {
                    runTCP();
                }
            });
            t2.start();
        }
        catch(Exception e){
            System.out.println("Error in Online scene Constuctor: \n" + e);
        }

        //If we are not the host then we do not want to generate our own asteroids.
        if (!host){
            asteroids.clear();
            player.setHost(false);
        }
        else{
            player.setHost(true);
            try{
                sendAllAsteroids();
            }
            catch (Exception e){
                System.out.println("Exception with sleep: " + e);
            }

        }
    }

    /**
     * Initialize the team ships for this game.
     * @param names ArrayList of names for each ship.
     */
    public void setTeam(ArrayList<String> names){
        for (String s : names){
            teammates.add(new TeamShip(s));
            System.out.println("Added: " + s);
        }
    }

    /**
     * Send UDP packets to the server. (Updates location/angle of ship.)
     */
    private void sendPackets(){
        try{
            ByteBuffer buff = ByteBuffer.wrap("This is a test".getBytes());
            udp.send(buff, new InetSocketAddress(address, port));
        }
        catch(Exception e){
            System.out.println("Error in sending coordinate packets: " + e);
        }
    }

    /**
     * Show the scene.
     */
    public void show(){
        background(0);
        super.showText();
        showPoints();
        showTeam();

        if(!out){
            if(!player.show()){
                out = true;
            }
        }

        player.showBullets();

        super.showAsteroids();
        if(isHost){
            if(super.checkLevel()){
                sendAllAsteroids();
                sendLevel();
                out = false;
                player.setAlive();
            }
        }

        sendLoc();

        if (isHost){
            if (millis() - timeStamp > 10000){
                sendAllAsteroids();
                timeStamp = millis();
            }
        }
    }

    private void showPoints(){
        String teamPoints = "";
        for (TeamShip ts : teammates){
            teamPoints += ts.getName() + ": " + ts.getPoints() + "\n";
        }
        textAlign(LEFT);
        text(teamPoints, 20, 50);
    }

    public void sendBullet(float x, float y, float angle){
        try{
            String packetString = String.format("%s,4,%.1f,%.1f,%.3f", playerName, x, y, angle);
            packetString += "~";
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            tcp.write(buffer);
        }
        catch(Exception e){
            System.out.println("Error in sendBullet: " + e);
        }
    }


    private void sendAllAsteroids(){
        String packString = playerName + ",6";
        for (Asteroid a : asteroids){
            packString += String.format(",%.1f!%.1f!%.2f!%d!%s", a.getX(), a.getY(), a.getAngle(), a.getLevel(), a.getID());
        }
        packString += "~";
        ByteBuffer buffer = ByteBuffer.wrap(packString.getBytes());
        try{
            tcp.write(buffer);
            //System.out.println("Sent: " + packString);
        }
        catch(Exception e){
            System.out.println("Error in send asteroids: " + e);
        }
    }

    public void sendAsteroids(Asteroid a){
        String packString = playerName + ",3";
        packString += String.format(",%.1f!%.1f!%.2f!%d!%s", a.getX(), a.getY(), a.getAngle(), a.getLevel(), a.getID());
        packString += "~";
        ByteBuffer buffer = ByteBuffer.wrap(packString.getBytes());
        try{
            tcp.write(buffer);
            //System.out.println("Sent: " + packString);
        }
        catch(Exception e){
            System.out.println("Error in send asteroids: " + e);
        }
    }

    /**
     * Show each of the team members
     */
    private void showTeam(){
        for (TeamShip ts : teammates){
            ts.show();
        }
    }

    /**
     * Search the socket for UDP packets. (mainly just location of team ships.)
     */
    private void runUDP(){
        System.out.println("Thread created.");
        try{
            while(true){
                ByteBuffer buffer = ByteBuffer.allocate(1024);
        		udp.receive(buffer);
                String message = new String(buffer.array());
                message = message.trim();
                String[] coordinates = message.split(",");
                //System.out.println(message);


                if (coordinates.length == 6){
                    if (coordinates[5].equals("1"))
                        setTeamLoc(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], false);
                    else
                        setTeamLoc(coordinates[0], coordinates[1], coordinates[2], coordinates[3], coordinates[4], true);

                }
            }
        }
        catch(Exception e){
            System.out.println("Error in Online UDP thread: \n" + e);
        }
        System.out.println("Thread closed.");
    }

    /**
     * Send current location to the server.
     */
    private void sendLoc(){
        try{
            String temp = String.format("%s,%.1f,%.1f,%.2f,%d,", playerName, player.getX(), player.getY(), player.getAngle(), player.getScore());
            if (!out)
                temp += "1";
            else
                temp += "0";
            ByteBuffer buff = ByteBuffer.wrap(temp.getBytes());
            udp.send(buff, socket);
        }
        catch(Exception e){
            System.out.println("Error in OnlineScene show: \n" + e);
        }
    }

    /**
     * Change the values of a ship based on the packet info we receive.
     * @param name        Name of ship.
     * @param xString     X pos as a string.
     * @param yString     Y pos as a string.
     * @param angleString Angle of ship as a string.
     */
    private void setTeamLoc(String name, String xString, String yString, String angleString, String score, boolean b){
        float tempX = Float.parseFloat(xString);
        float tempY = Float.parseFloat(yString);
        float tempAngle = Float.parseFloat(angleString);
        int tempScore = Integer.parseInt(score);
        boolean found = false;

        //Search for ship by name and then set.
        for (TeamShip ts : teammates){
            if (ts.getName().equals(name)){
                ts.setPos(tempX, tempY, tempAngle);
                ts.setDead(b);
                ts.setPoints(tempScore);
                found = true;
                break;
            }
        }

        if (!found){
            teammates.add(new TeamShip(name));

        }
    }

    public void sendRemove(String id){
        try{
            String packString = playerName + ",5," + id;
            packString += "~";
            ByteBuffer buffer = ByteBuffer.wrap(packString.getBytes());
            tcp.write(buffer);
        }
        catch(Exception e){
            System.out.println("Error in send asteroids: " + e);
        }
    }

    public void sendLevel(){
        try{
            String packString = playerName + ",7," + level;
            packString += "~";
            ByteBuffer buffer = ByteBuffer.wrap(packString.getBytes());
            tcp.write(buffer);
        }
        catch(Exception e){
            System.out.println("Error in send asteroids: " + e);
        }
    }

    private void runTCP(){
        System.out.println("Thread Made.");
        //Keep searching while we are in this scene.
        while(temp){
            String temp = "";
            try{
                ByteBuffer buffer = ByteBuffer.allocate(1024);
                tcp.read(buffer);
                temp = new String (buffer.array()).trim();
                processTCP(temp);

                // System.out.println("new String(buffer.array()).trim()");
            }
            catch(Exception e){
                System.out.println("Error in runTCP (onlineScene): " + e);
            }

        }
        System.out.println("Thread closed.");
    }

    private void processTCP(String packet){
        // System.out.println(packet);
        packet = packet.trim();
        String[] splitMessage = packet.split(",");
        //System.out.println(packet);
        if (splitMessage[1].equals("3")){
            //asteroids.clear();
            //System.out.println(asteroids.size());
            setAsteroids(splitMessage);
        }
        if (splitMessage[1].equals("6")){
            asteroids.clear();
            //System.out.println(asteroids.size());
            setAsteroids(splitMessage);
        }
        if (splitMessage[1].equals("4")){
            float tempX = Float.parseFloat(splitMessage[2]);
            float tempY = Float.parseFloat(splitMessage[3]);
            float tempAngle = Float.parseFloat(splitMessage[4]);

            Bullet b = new Bullet(tempX, tempY, tempAngle);
            b.setOwner(false);

            //If we are the host we keep track of bullet hits

            player.addBullet(b);
            //Else we just send the bullets.
            // else
            //     player.addBullet(new Bullet(tempX, tempY, tempAngle));
        }
        if (splitMessage[1].equals("5")){
            String tempID = splitMessage[2];
            for (Asteroid a : asteroids){
                if (a.getID().equals(tempID)){
                    asteroids.remove(a);
                    break;
                }
            }
        }
        if (splitMessage[1].equals("7")){
            level++;
            out = false;
            player.setAlive();
            player.resetPos();
        }
        if (splitMessage[1].equals("8")){
            scene = 0;
        }
    }

    private void setAsteroids(String[] splitMessage){
        for (int i = 2; i < splitMessage.length; i++){
            String[] temp = splitMessage[i].split("!");
            float tempX = Float.parseFloat(temp[0]);
            float tempY = Float.parseFloat(temp[1]);
            float tempAngle = Float.parseFloat(temp[2]);
            int tempLev = Integer.parseInt(temp[3]);
            String tempID = temp[4];
            asteroids.add(new Asteroid(tempX, tempY, tempAngle, tempLev, tempID));
        }
    }
}
