/**
 * Ping demo, ping between 2 norduinos: send and wait for reply
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */

#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>

void setup(){
  Serial.begin(9600);
  /*
   * Setup pins / SPI.
   */
   

  Mirf.init();
  
  /*
   * Configure reciving address.
   */
   
  Mirf.setRADDR((byte *)"clie1");
  
  /*
   * Set the payload length to sizeof(unsigned long) the
   * return type of millis().
   *
   * NB: payload on client and server must be the same.
   */
   
  Mirf.payload = sizeof(unsigned long);
  
  /*
   * Write channel and payload config then power up reciver.
   */
   
  /*
   * To change channel:
   * 
   * Mirf.channel = 10;
   *
   * NB: Make sure channel is legal in your area.
   */
   
  Mirf.config();
  
  Serial.println("Beginning ... "); 
}

void loop(){
  unsigned long time = millis();
  
  Mirf.setTADDR((byte *)"serv1");
  
  Mirf.send((byte *)&time);
  
  while(Mirf.isSending()){
  }
  Serial.println("Finished sending");
  delay(10);
  while(!Mirf.dataReady()){
    //Serial.println("Waiting");
    if ( ( millis() - time ) > 1000 ) {
      Serial.println("Timeout on response from server!");
      return;
    }
  }
  
  Mirf.getData((byte *) &time);
  
  Serial.print("Ping: ");
  Serial.println((millis() - time));
  
  delay(1000);
} 
  
  
  
