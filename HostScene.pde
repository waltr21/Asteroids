public class HostScene{
    boolean searchBool, hostBool, threadMade, hostScene;
    String hostString, searchString, allClients;

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
            //udp = DatagramChannel.open();

            //Connect to TCP
            String packetString = playerName + ",1";
            ByteBuffer buffer = ByteBuffer.wrap(packetString.getBytes());
            tcp.write(buffer);
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
            searchString = ("Error connecting to server. IP adress is probably wrong.");
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
                String temp = buffer.array()).trim();
                System.out.println(new String(buffer.array()).trim());
                procesTCP(temp);
            }
            catch(Exception e){
                System.out.println(e);
                threadMade = false;
                break;
            }
        }
    }

    private void procesTCP(String packet){

    }
}
