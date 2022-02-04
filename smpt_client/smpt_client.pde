import processing.net.*;



Client client;
int commandBufferIndex = 0;
int mailBufferIndex = 0;
char[] commandBuffer = new char[100]; 
char[] mailBuffer = new char[1000];

String response = "";
boolean isDisconnect = false;
boolean mailMode = false;

void setup() {
  client = new Client(this, "127.0.0.1", 587);
  size(400, 400);
}

void draw() {
  background(255);
  textAlign(CENTER, CENTER);
  if(client.active()) {
    if(mailMode == false){
      fill(0);
      text("コマンド入力してください...", width / 2, height / 4);
      fill(0);
      text(commandBuffer, 0, commandBufferIndex, width / 2, height / 3);
      text("サーバーからの応答", width / 2, height / 2);
      //text(response, width / 2, height / 1.8);
      text(response, width / 2, height / 1.7);
    }else {
      fill(0);
      text("メール入力してください...", width / 2, height / 8);
      fill(0);
      text(mailBuffer, 0, mailBufferIndex, width / 2, height / 4);
    }
  } else {
    fill(0);
    if(isDisconnect == false){
      
      text("サーバーに接続してください", width / 2, height / 2);
    } else {
      text("サーバーとの接続が切れました", width / 2, height / 2);
    }
  }
  
}


void keyPressed() {
  if (key != CODED) {
    if(mailMode == false) {
    if(key == BACKSPACE) {
      if(commandBufferIndex > 0)
        commandBufferIndex--;
      //println(commbufferIndex);
    }else {
      commandBuffer[commandBufferIndex++] = key;
      if (key == '\n') {
        String tmp = "";
        for (int i = 0; i < commandBufferIndex-1; ++i) {
          tmp += commandBuffer[i];
        }
        client.write(tmp);
        commandBufferIndex = 0;
      }
    }
    
  } else {
    //println(key);
    if(key == BACKSPACE) {
      
      if(mailBufferIndex > 0) 
        mailBufferIndex--;
      
      } else {
        mailBuffer[mailBufferIndex++] = key;
        String tmp = "";
        if(key == '\n') {
          for(int i = 0; i < mailBufferIndex-1; i++) {
            tmp += mailBuffer[i];
          }
          //print("333333333333333333333");
          client.write(tmp);
          mailBufferIndex = 0;
        }
        
      }
  }
  }
}
  

void clientEvent(Client client) {
  
  while(client.available() > 0) {
    if(client.active()) {
      response = client.readString();
      
      if(mailMode == true && response.equals("250 Ok") == true) {
        mailMode = false;
        delay(2000);
      }
      
      if(response.substring(0, 1).equals("5") == true) {
        isDisconnect = true;
        delay(2000);
        client.stop();
      }
      
      if(response.equals("354 End data with <CR><LF>.<CR><LF>") == true) {
        delay(2000);
        mailMode = true;
      }
      
      println(client.readString());
    }
  }
}
