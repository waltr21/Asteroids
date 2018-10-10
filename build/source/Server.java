import java.io.*;
import java.net.*;
import java.nio.*;
import java.nio.channels.*;
import java.util.ArrayList;
import java.util.Random;

public class Server{
    private int port;
    private final int BUFFER_SIZE;
    private DatagramChannel udp;
    private ServerSocketChannel tcp;
    private ArrayList<NameSocket> TCPclients;
    private ArrayList<NameSocket> UDPclients;

    //Static because processing is dumb.
    public static SocketChannel sc;

    public Server(){
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
        }

        Thread threadUDP = new Thread(new Runnable() {
           public void run() {
               runUDP();
           }
        });
        System.out.println("Thread Created.");
        threadUDP.start();

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
            }
        }
    }

    private void connectThread(){

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
                buffer.flip();

                //System.out.println(new String(buffer.array()).trim());

            }
        }
        catch(Exception e){
            System.out.println("UDP fail: ");
            System.out.println(e);
        }
    }

    private void runTCP(SocketChannel sc){
        try{
            //Continue to loop and search for packets.
            while(true){
                //SocketChannel sc = tcp.accept();
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE);
                sc.read(buffer);
                String tempMessage = new String(buffer.array()).trim();
                parseTCP(tempMessage, sc);
                if (tempMessage.length() < 1){
                    System.out.println("Lost connection to client. Breaking...");
                    removeClient(sc);
                    break;
                }
            }
        }
        //Exceptions.
        catch(Exception e){
            System.out.println("TCP Fail: ");

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
            if (splitMessage[1].equals("0") || splitMessage[1].equals("2")){
                ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
                sendAllTCP(name, buffer);
            }
            if(splitMessage[1].equals("-1")){
                ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
                sendSelf(name, buffer);
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
                    ns.socketC.write(buffer);
                }
                catch(Exception e){
                    System.out.println(e);
                }
            }
        }
    }

    private void removeClient(SocketChannel sc){
        for (int i = 0; i < TCPclients.size(); i++){
            NameSocket ns = TCPclients.get(i);
            if (ns.socketC.equals(sc)){
                //System.out.println("Removed: " + ns.name);
                TCPclients.remove(i);
                System.out.println("Removed: " + ns.name + "\nClients Size: " + TCPclients.size());
                break;
            }
        }
    }

    private void sendSelf(String name, ByteBuffer buffer){
        for (NameSocket ns : TCPclients){
            if (ns.name.equals(name)){
                try{
                    //System.out.println("Sent packet");
                    ns.socketC.write(buffer);
                }
                catch(Exception e){
                    System.out.println(e);
                }
            }
        }
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