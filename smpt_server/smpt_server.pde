import processing.net.*;
import java.util.UUID;  


Server server;
String myDomain = "127.0.0.1";
HashMap<String, Boolean> commandSeq = new HashMap();
String from, to = "";
boolean mailMode = false;
int mailIndex = 0;
String[] mailStrings = new String[200];

void setup() {
  server = new Server(this, 587);
  commandSeq.put("EHLO", false);
  commandSeq.put("MAIL", false);
  commandSeq.put("RCRT", false);
  commandSeq.put("DATA", false);
  commandSeq.put("QUIT", false);
}

void draw() {
}




//コネクションからデータを受信したとき
void clientEvent(Client client) {
  
  while(client.available() > 0) {
    if(client.active()) {
      if(mailMode == false) {
      String data = client.readString();
      
      
      if(data.length() < 4 || data.length()> 50) {
        server.write("500 Syntax error, command unrecognized ");
      }
      
      String command = data.substring(0,4).toUpperCase();
      String clientDomain, arg;
      /*
      println("###");
      println(data);
      println(command);
      println("$$$");
      */
      String response = "";
      switch(command) {
        case "EHLO":
          if(commandSeq.get("EHLO") == false) {
            commandSeq.put("EHLO", true);
            clientDomain = data.substring(5, data.length());
            response = "250 Ok \n" + myDomain + " greets " + clientDomain;
          } else {
            response = "503  Bad sequence of commands";
          }
          break;
          
        case "MAIL":
          if(
          commandSeq.get("EHLO") == true && 
          commandSeq.get("MAIL") == false 
          ){
            commandSeq.put("MAIL", true);
            response = "250 Ok";
            
            arg = data.substring(5, 10).toUpperCase();
            
            if(arg.equals("FROM:") == false) {
              response = "501  Syntax error in parameters or arguments";
            } else {
              from = data.substring(11, data.length());
              mailStrings[mailIndex++] = from;
            }
            
          } else {
            response = "503  Bad sequence of commands";
          }
          break;
          
        case "RCPT":
          if(
          commandSeq.get("EHLO") == true && 
          commandSeq.get("MAIL") == true 
          ){
            commandSeq.put("RCPT", true);
            response = "250 Ok";
            
            arg = data.substring(5, 8).toUpperCase();
            
            if(arg.equals("TO:") == false) {
              response = "501  Syntax error in parameters or arguments";
            } else {
              to += data.substring(9, data.length()) + "\n";
              mailStrings[mailIndex++] = to;
            }
            
          } else {
            response = "503  Bad sequence of commands";
          }
          break;
          
          
        case "DATA":
          if(
          commandSeq.get("EHLO") == true && 
          commandSeq.get("MAIL") == true &&
          commandSeq.get("RCPT") == true &&
          commandSeq.get("DATA") == false
          ){
            commandSeq.put("DATA", true);
            response = "354 End data with <CR><LF>.<CR><LF>";
            mailMode = true;
            
            if(data.toUpperCase().equals("DATA") == false) {
              response = "501  Syntax error in parameters or arguments";
            }
            
          } else {
            response = "503  Bad sequence of commands";
          }
          break;
          
        case "QUIT":
          if(
          commandSeq.get("EHLO") == true && 
          commandSeq.get("MAIL") == true && 
          commandSeq.get("RCRT")  == true && 
          commandSeq.get("DATA") == true &&
          commandSeq.get("QUIT") == false
          ){
            commandSeq.put("QUIT", true);
            response = "221 Bye";
          } else {
            response = "503  Bad sequence of commands";
          }
          break;
         
         
        default:
          response = "502  Command not implemented";
          break;
      }
      
      server.write(response);
      
      } else {
        
        String mailData = client.readString();
        
        if(mailData.equals(".") == true) {
          saveStrings(UUID.randomUUID().toString() + ".txt", mailStrings);
          mailIndex = 0;
          mailMode = false;
          server.write("250 Ok");
        } else {
          mailStrings[mailIndex++] = mailData; 
        }
      }
      
    }
  }

  
    
}


//コネクションが確立されたとき
void serverEvent(Server server, Client client) {
  server.write("220 127.0.0.1 Service ready");
}


//コネクションが切断されたとき
void disconnectEvent(Client client) {
  println("disconnect");
}
