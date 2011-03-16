/**
 * Emulates the nordic interface serial board from sparkfun http://www.sparkfun.com/products/9019
 * Use the nordic fob to send key strokes!
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */


#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>
byte tx_addr[5] = {0xE7, 0xE7, 0xE7, 0xE7, 0xE7};

void setup(){
  Serial.begin(9600);
  
  /*
   * Setup pins / SPI.
   */

  Mirf.init();
  
  /*
   * Configure reciving address.
   */
   
  Mirf.setRADDR(rx_addr);
  
  /*
   * Set the payload length to sizeof(unsigned long) the
   * return type of millis().
   *
   * NB: payload on client and server must be the same.
   */
  Mirf.configRegister(RF_SETUP, 0x07); //Air data rate 1Mbit, 0dBm, Setup LNA
  Mirf.configRegister(EN_AA, 0x00); //Disable auto-acknowledge 
  Mirf.payload = 4;
  Mirf.channel=2;
  
  /*
   * Write channel and payload config then power up reciver.
   */
   
  Mirf.config();
  
  Serial.println("Listening..."); 
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
    
    do{
      Serial.println("Got packet");
    
      /*
       * Get load the packet into the buffer.
       */
     
      Mirf.getData(data);
    
      /*
       * Set the send address.
       */
     
     
      switch (data[0]) {
  	case 0x1D: Serial.println("UP"); break;
  	case 0x1E: Serial.println("DOWN"); break;
  	case 0x17: Serial.println("LEFT"); break;
  	case 0x1B: Serial.println("RIGHT"); break;
  	case 0x0F: Serial.println("CENTER"); break;
  	default: break;
      }
    
    }while(!Mirf.rxFifoEmpty());
  }
}
