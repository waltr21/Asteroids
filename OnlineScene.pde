
/**
 * This class is used for drawing the online scene of the game.
 * It is also responsible for sending/receiving packets from the Server
 * to update the location of the other players in the game.
 */
public class OnlineScene extends GameScene{
    boolean isHost;
    InetSocketAddress socket;
    ArrayList<TeamShip> teammates;

    /**
     * Constructor method for the OnlineScene class.
     * Calls the super class Constructor (GameScene) to reduce logic duplication.
     * @param host if we are the host of this scene.
     */
    public OnlineScene(boolean host){
        super();
        this.isHost = host;

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
        showTeam();
        //If we die go back to the main.
        //TODO Change to exit only if everyone is dead.
        if(!player.show()){
            scene = 0;
            return;
        }
        super.showAsteroids();
        if(isHost)
            super.checkLevel();

        sendLoc();
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
        String packString = playerName + ",3";
        for (Asteroid a : asteroids){
            packString += String.format(",%.1f!%.1f!%.2f!%d", a.getX(), a.getY(), a.getAngle(), a.getLevel());
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
        packString += String.format(",%.1f!%.1f!%.2f!%d", a.getX(), a.getY(), a.getAngle(), a.getLevel());
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

                if (coordinates.length == 4){
                    setTeamLoc(coordinates[0], coordinates[1], coordinates[2], coordinates[3]);
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
            String temp = String.format("%s,%.1f,%.1f,%.2f", playerName, player.getX(), player.getY(), player.getAngle());
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
    private void setTeamLoc(String name, String xString, String yString, String angleString){
        float tempX = Float.parseFloat(xString);
        float tempY = Float.parseFloat(yString);
        float tempAngle = Float.parseFloat(angleString);

        //Search for ship by name and then set.
        for (TeamShip ts : teammates){
            if (ts.getName().equals(name)){
                ts.setPos(tempX, tempY, tempAngle);
                break;
            }
        }
    }

    public void sendRemove(int index){
        try{
            String packString = playerName + ",5," + index;
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
        while(true){
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
                break;
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
            asteroids.clear();
            System.out.println(asteroids.size());
            setAsteroids(splitMessage);
        }
        if (splitMessage[1].equals("4")){
            float tempX = Float.parseFloat(splitMessage[2]);
            float tempY = Float.parseFloat(splitMessage[3]);
            float tempAnle = Float.parseFloat(splitMessage[4]);

            //If we are the host we keep track of bullet hits
            if (isHost)
                player.addBullet(new Bullet(tempX, tempY, tempAnle));
            //Else we just send the bullets.
            else
                player.addBullet(new Bullet(tempX, tempY, tempAnle));
        }
        if (splitMessage[1].equals("5")){
            int tempIndex = Integer.parseInt(splitMessage[2]);
            asteroids.remove(tempIndex);
        }
    }

    private void setAsteroids(String[] splitMessage){
        for (int i = 2; i < splitMessage.length; i++){
            String[] temp = splitMessage[i].split("!");
            float tempX = Float.parseFloat(temp[0]);
            float tempY = Float.parseFloat(temp[1]);
            float tempAngle = Float.parseFloat(temp[2]);
            int tempLev = Integer.parseInt(temp[3]);
            asteroids.add(new Asteroid(tempX, tempY, tempAngle, tempLev));
        }
    }
}
