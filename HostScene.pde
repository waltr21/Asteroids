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
            buffer = ByteBuffer.wrap(temp.getBytes());
            tcp.write(buffer);
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
            scene = 2;
            host.setText("Host");
            host.setScene(5);
            clientList.clear();
            allClients = "";
            hostScene = false;
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
