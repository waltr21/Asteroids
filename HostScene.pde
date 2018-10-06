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
        hostBool = false;
        searchBool = true;
        sendSearchPacket();

        if (!threadMade){
            try{
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
    }

    public void setHost(){
        hostBool = true;
        searchBool = false;
        address = "127.0.0.1";
        sendInitPacket();
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

    private boolean sendInitPacket(){
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
            tcp = SocketChannel.open();
            tcp.connect(new InetSocketAddress(address, port));
            String packetString = "0," + playerName;
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
        searchString += "\n\nConnection successful!";
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
