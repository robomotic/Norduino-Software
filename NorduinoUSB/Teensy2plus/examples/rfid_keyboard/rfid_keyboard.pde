/**
 * RFID keyboard emulator for the Teensy2++ board
 * On the Norduino board use rfid_tx sketch
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
  #ifdef SERIALDEBUG 
  Serial.begin(9600);
  #endif
  
  /*
   * Setup pins / SPI.
   */

  Mirf.init();
  
  /*
   * Configure reciving address.
   */
   
  Mirf.setRADDR((byte *)"serv1");
  
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

  #ifdef SERIALDEBUG 
  if (Mirf.config())
    Serial.println("Init oky ... "); 
  else
    Serial.println("Init failed ... "); 
  #endif
}

void loop(){
  /*
   * A buffer to store the data.
   */
   
  byte data[Mirf.payload];

  /*
   * If a packet has been recived.
   */
  if(Mirf.dataReady()){
    
    //do{
    
      /*
       * Get load the packet into the buffer.
       */
     
      Mirf.getData(data);
      
      for(int k=0;k<RFIDBUF;k++)
        Keyboard.print(data[k]);

      
    //}while(!Mirf.rxFifoEmpty());
  }
}
