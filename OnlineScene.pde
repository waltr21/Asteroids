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
        System.out.println(teammates.size());
        for (TeamShip ts : teammates){
            ts.show();
        }
    }
}
