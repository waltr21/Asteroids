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
    private ArrayList<NameSocket> clients;

    public Server(){
        port = 8765;
        BUFFER_SIZE = 1024;
        clients = new ArrayList<>();

        Thread threadUDP = new Thread(new Runnable() {
           public void run() {
               runUDP();
           }
        });
        threadUDP.start();

        Thread threadTCP = new Thread(new Runnable() {
          public void run() {
              runTCP();
          }
        });
        threadTCP.start();
    }

    private void runUDP(){
        try{
            //Bind to the port number.
            udp = DatagramChannel.open();
            udp.bind(new InetSocketAddress(port));
            System.out.println("UDP Connection successful.");

            //Continue to loop and search for packets.
            while(true){
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE);
                SocketAddress currentAddress = udp.receive(buffer);
                buffer.flip();

                //System.out.println(new String(buffer.array()).trim());

            }
        }
        catch(Exception e){
            System.out.println(e);
        }
    }

    // private void addClient(ByteBuffer b, SocketAddress ca){
    //     String temp = new String(b.array().trim());
    //     String[] tempArr = temp.split("|");
    //     String name = tempArr[0];
    //     boolean found = false;
    //
    //     for (NameSocket ns : clients){
    //         if (ns.name.equals(name))
    //             found = true;
    //     }
    //     if (!found){
    //         return;
    //     }
    // }

    private void runTCP(){
        try{
            //Bind to the port number.
            tcp = ServerSocketChannel.open();
            tcp.bind(new InetSocketAddress(port));
            System.out.println("TCP Connection successful.");
            SocketChannel sc = tcp.accept();

            //Continue to loop and search for packets.
            while(true){
                //SocketChannel sc = tcp.accept();
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_SIZE);
                sc.read(buffer);
                String tempMessage = new String(buffer.array()).trim();
                parseTCP(tempMessage, sc);
                //System.out.println(tempMessage);


            }
        }
        //Exceptions.
        catch(Exception e){
            System.out.println(e);
        }
    }

    public void parseTCP(String message, SocketChannel sc){
        //Split message
        String[] splitMessage = message.split(",");
        //If we are working with an init connect packet.
        if (splitMessage[0].equals("0")){
            ByteBuffer buffer = ByteBuffer.wrap(message.getBytes());
            buffer.position(0);
            try{
                System.out.println("Sent packet");
                sc.write(buffer);
            }
            catch(Exception e){
                System.out.println("bleg");
            }
        }


    }

    public static void main(String args[]){
        Server s = new Server();
    }
}

class NameSocket{
    public String name;
    public SocketAddress socket;

    public NameSocket(String name, SocketAddress socket){
        this.name = name;
        this.socket = socket;
    }
}