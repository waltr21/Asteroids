public class OnlineScene extends GameScene{
    boolean isHost;
    InetSocketAddress socket;
    ArrayList<TeamShip> teammates;

    public OnlineScene(){
        super();
        teammates = new ArrayList<TeamShip>();
        try{
            udp = DatagramChannel.open();
            socket = new InetSocketAddress(address, port);
            Thread t1 = new Thread(new Runnable() {
                public void run() {
                    runUDP();
                }
            });
            t1.start();
        }
        catch(Exception e){
            System.out.println("Error in Online scene Constuctor: \n" + e);
        }
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
            udp.send(buff, new InetSocketAddress(address, port));
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

        try{
            String temp = String.format("%s,%.3f,%.3f,%.3f", playerName, player.getX(), player.getY(), player.getAngle());
            ByteBuffer buff = ByteBuffer.wrap(temp.getBytes());
            udp.send(buff, socket);
        }
        catch(Exception e){
            System.out.println("Error in OnlineScene show: \n" + e);
        }
    }

    private void showTeam(){
        for (TeamShip ts : teammates){
            ts.show();
        }
    }

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

    private void setTeamLoc(String name, String xString, String yString, String angleString){
        float tempX = Float.parseFloat(xString);
        float tempY = Float.parseFloat(yString);
        float tempAngle = Float.parseFloat(angleString);

        for (TeamShip ts : teammates){
            if (ts.getName().equals(name)){
                ts.setPos(tempX, tempY, tempAngle);
            }
        }

    }
}
