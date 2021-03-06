import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

public class Server{
    private int port;
    private int numErrors;

    private final int BUFFER_SIZE;
    private DatagramChannel udp;
    private ServerSocketChannel tcp;
    private ArrayList<NameSocket> TCPclients;
    private ArrayList<NameSocket> UDPclients;

    //Static because processing is dumb.
    public static SocketChannel sc;

    public Server(){
        numErrors = 0;
        port = 8765;
        BUFFER_SIZE = 1024;
        TCPclients = new ArrayList<>();
        UDPclients = new ArrayList<>();

        try{
            tcp = ServerSocketChannel.open();
            tcp.bind(new InetSocketAddress(port));
        }
        catch(Exception e){
            System.out.println(e);
            numErrors++;
        }

        Thread threadUDP = new Thread(new Runnable() {
           public void run() {
               runUDP();
           }
        });
        System.out.println("Thread Created.");
        threadUDP.start();

        Thread keyThread = new Thread(new Runnable() {
           public void run() {
               keyListen();
           }
        });
        keyThread.start();

        while (true){
            try{
                sc = tcp.accept();

                Thread threadTCP = new Thread(new Runnable() {
                  public void run() {
                      runTCP(sc);
                  }
                });
                System.out.println("Thread Created.");
                threadTCP.start();
            }
            catch(Exception e){
                System.out.println(e);
                numErrors++;
            }
        }
    }

    private void runUDP(){
        try{
            //Bind to the port number.
            udp = DatagramChannel.open();
            udp.bind(new InetSocketAddress(port));
            //System.out.println("UDP Connection successful.");

            //Continue to loop and search for packets.
            while(true){
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE);
                SocketAddress currentAddress = udp.receive(buffer);
                //buffer.flip();
                String message = new String(buffer.array()).trim();
                //System.out.println(message);
                String[] splitMessage = message.split(",");

                ByteBuffer buffer2 = ByteBuffer.wrap(message.getBytes());

                if (message.length() > 1){
                    if (UDPclients.size() != TCPclients.size())
                        addClient(splitMessage[0], currentAddress);

                    sendAllUDP(splitMessage[0], buffer2);
                }
                else{
                    System.out.println("Lost connection to client. Breaking...");
                    removeClient(sc);
                    break;
                }


                //System.out.println(new String(buffer.array()).trim());

            }
        }
        catch(Exception e){
            System.out.println("UDP fail: ");
            System.out.println(e);
            numErrors++;
        }
    }

    private void splitPackets(String message, SocketChannel sc){
        String[] splitMessage = message.split("~");
        boolean pause = false;
        if (splitMessage.length > 1)
            pause = true;

        for (int i = 0; i < splitMessage.length; i++){
            parseTCP(splitMessage[i], sc);
            try{
                Thread.sleep(20);
            }
            catch(Exception e){
                System.out.println("Error in splitPackets: " + e);
                numErrors++;
            }
        }

    }

    private void runTCP(SocketChannel sc){
        try{
            //Continue to loop and search for packets.
            while(true){
                //SocketChannel sc = tcp.accept();
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE);
                sc.read(buffer);
                //Thread.sleep(30);
                String tempMessage = new String(buffer.array()).trim();
                if (tempMessage.length() < 1){
                    System.out.println("Lost connection to client. Breaking...");
                    removeClient(sc);
                    break;
                }

                splitPackets(tempMessage, sc);
            }
        }
        //Exceptions.
        catch(Exception e){
            System.out.println("TCP Fail: ");
            numErrors++;
            System.out.println(e);
        }
    }

    private void parseTCP(String message, SocketChannel sc){
        //Split message
        String[] splitMessage = message.split(",");
        if (splitMessage.length > 1){
            String name = splitMessage[0];
            addClient(name, sc);
            //If we are working with an init connect packet.
            // if (splitMessage[1].equals("0") || splitMessage[1].equals("2") || splitMessage[1].equals("3")){
            //     ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
            //     System.out.println(message);
            //
            //     sendAllTCP(name, buffer);
            // }
            if(splitMessage[1].equals("-1")){
                ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
                sendSelf(name, buffer);
            }
            else{
                ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
                //System.out.println(message);

                sendAllTCP(name, buffer);
            }
        }

    }

    private void addClient(String name, SocketChannel sc){
        boolean found = false;
        for (NameSocket ns : TCPclients){
            if (ns.name.equals(name)){
                found = true;
                break;
            }
        }
        if (!found){
            TCPclients.add(new NameSocket(name, sc));
            System.out.println("TCP client added: " + name);
        }
    }

    private void addClient(String name, SocketAddress sa){
        boolean found = false;
        for (NameSocket ns : UDPclients){
            if (ns.name.equals(name)){
                found = true;
                break;
            }
        }
        if (!found){
            UDPclients.add(new NameSocket(name, sa));
            System.out.println("UDP client added: " + name);
        }
    }

    private void sendAllTCP(String name, ByteBuffer buffer){
        for (NameSocket ns : TCPclients){
            if (!ns.name.equals(name)){
                try{
                    //System.out.println("Sent packet");
                    //Thread.sleep(50);
                    ns.socketC.write(buffer);
                    buffer.flip();
                }
                catch(Exception e){
                    System.out.println(e);
                    numErrors++;
                }
            }
        }
    }

    private void sendAllUDP(String name, ByteBuffer buffer){
        for (int i = 0; i < UDPclients.size(); i++){
            NameSocket ns = UDPclients.get(i);
            if (!ns.name.equals(name)){
                try{
                    //System.out.println("Sent packet");
                    // buffer.position(0);
                    udp.send(buffer, ns.socketA);
                    buffer.flip();
                    //System.out.println(String.format("Sender: %s    receiver: %s", name, ns.name));
                    //System.out.println("Sent to: " + i);
                    // ns.socketA.send(buffer);
                }
                catch(Exception e){
                    System.out.println(e);
                    numErrors++;
                }
            }
        }
    }

    private void removeClient(SocketChannel sc){
        String name = "";
        for (int i = 0; i < TCPclients.size(); i++){
            NameSocket ns = TCPclients.get(i);
            if (ns.socketC.equals(sc)){
                //System.out.println("Removed: " + ns.name);
                TCPclients.remove(i);
                name = ns.name;
                System.out.println("Removed TCP: " + ns.name);
                break;
            }
        }
        //Remove UDP as well.
        for (NameSocket ns : UDPclients){
            if (ns.name.equals(name)){
                System.out.println("Removed UDP: " + ns.name);
                UDPclients.remove(ns);
                break;
            }
        }
    }

    private void removeClient(SocketAddress sa){
        for (int i = 0; i < UDPclients.size(); i++){
            NameSocket ns = UDPclients.get(i);
            if (ns.socketA.equals(sa)){
                //System.out.println("Removed: " + ns.name);
                TCPclients.remove(i);
                System.out.println("Removed: " + ns.name + "\nClients Size: " + UDPclients.size());
                break;
            }
        }
    }

    private void sendSelf(String name, ByteBuffer buffer){
        for (NameSocket ns : TCPclients){
            if (ns.name.equals(name)){
                try{
                    //Thread.sleep(100);
                    //System.out.println("Sent packet");
                    ns.socketC.write(buffer);
                    break;
                }
                catch(Exception e){
                    System.out.println(e);
                    numErrors++;
                }
            }
        }
    }

    private void keyListen(){
        Scanner listener = new Scanner(System.in);
        String ip;
        try{
            InetAddress localhost = InetAddress.getLocalHost();
            ip = localhost.getHostAddress().trim();
        }
        catch(Exception e){
            ip = "Error";
            numErrors++;
        }
        while(true){
            // String tempIP = "";
            // if (sc)
            String x = listener.nextLine();
            if (x.equals("c")){
                UDPclients.clear();
                TCPclients.clear();
                System.out.println("Clients cleared");
            }
            else{
                System.out.println("----------------------- Stats -----------------------");
                System.out.println("Port: " + port);
                System.out.println("IP: " + ip);
                System.out.println("Errors: " + numErrors);
                printArrays();
                System.out.println("----------------------- Stats -----------------------");
            }
        }
    }

    private void printArrays(){
        System.out.print("TCP clients: ");
        for (NameSocket ns : TCPclients){
            System.out.print(ns.name + ", ");
        }
        System.out.println("");

        System.out.print("UDP clients: ");
        for (NameSocket ns : UDPclients){
            System.out.print(ns.name + ", ");
        }
        System.out.println("");
    }

    public static void main(String args[]){
        Server s = new Server();
    }


}

class NameSocket{
    public String name;
    public SocketAddress socketA;
    public SocketChannel socketC;
    public boolean host;

    public NameSocket(String name, SocketAddress socketA){
        this.name = name;
        this.socketA = socketA;
        this.host = false;
    }

    public NameSocket(String name, SocketChannel socketC){
        this.name = name;
        this.socketC = socketC;
        this.host = false;
    }
}
