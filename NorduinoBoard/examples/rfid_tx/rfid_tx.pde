/**
 * Parse the RFID tag data and sends to the Norduino Teensy USB
 * Sketch is rfid_keyboard
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */

#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>
#define SERIALDEBUG 1
#define RFIDBUF 14
char rfidbuffer[RFIDBUF];

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
   
  Mirf.payload = RFIDBUF;
  
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
  
  #ifdef SERIALDEBUG 
  if (Mirf.config())
    Serial.println("Init oky ... "); 
  else
    Serial.println("Init failed ... "); 
  #endif
}

void loop(){


  if(Serial.available()){
     int i=0;    
     delay(100);
     while( Serial.available() && i< RFIDBUF) {
        char symbol=Serial.read();
        if(symbol==0x0D || symbol==0x0A)
          i=RFIDBUF;
        else rfidbuffer[i++] = symbol;
     }

    if(i>0)
    {
      Mirf.setTADDR((byte *)"serv1");
      byte data[Mirf.payload];
      Mirf.send((byte *)&rfidbuffer);
      
      while(Mirf.isSending()){
      }
      delay(1000);
    }
  }
  

  
} 
  
  
  
