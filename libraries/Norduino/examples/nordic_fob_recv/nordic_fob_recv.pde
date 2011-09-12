/**
 * Emulates the nordic interface serial board from sparkfun http://www.sparkfun.com/products/9019
 * Use the nordic fob to send key strokes!
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */

//This inlcudes are for the Nordic interface
#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>
//This includes are for the Norduino ports 
// uses the same as the jeenode
#include <Ports.h>

Port one (1);
Port four (4);

//set the address as equal to the keyfob 
// it's 5 bytes
byte tx_addr[5] = {0xE7, 0xE7, 0xE7, 0xE7, 0xE7};
byte rx_addr[5] = {0xE7, 0xE7, 0xE7, 0xE7, 0xE7};

//button status
byte buttons[4]={0,0,0,0};

void setup(){
  
  //set the ports first
  one.mode(OUTPUT);
  four.mode(OUTPUT);
  
  // setup the serial port for debugging
  Serial.begin(9600);
  
  /*
   * Setup pins / SPI.
   */

  Mirf.init();
  
  /*
   * Configure receiving address.
   */
   
  Mirf.setRADDR(rx_addr);
  
  //Air data rate 1Mbit, 0dBm, Setup LNA
  Mirf.configRegister(RF_SETUP, 0x07); 
  //Disable auto-acknowledge 
  Mirf.configRegister(EN_AA, 0x00);
  //The button presses are stored in a 4 byte payload
  Mirf.payload = 4;
  //The Nordic Keyfobs are setup on channel 2
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
       * Get the paylod into the buffer.
       */
     
      Mirf.getData(data);
      
      /* 
      * Decode the button press with a switch case
      */
      switch (data[0]) {
  	case 0x1D: Serial.println("DOWN"); break;
  	case 0x1E: Serial.println("UP"); break;
  	case 0x17: 
          Serial.println("RIGHT");
          //swap the button status
          buttons[0]=buttons[0] ^ 1; 
          one.digiWrite(buttons[0]);
          break;
  	case 0x1B: 
          Serial.println("LEFT"); 
          //swap the button status
          buttons[1]=buttons[1] ^ 1; 
	  four.digiWrite(buttons[1]);
          break;
  	case 0x0F: Serial.println("CENTER"); break;
  	default: break;
      }
    
    }while(!Mirf.rxFifoEmpty());
  }
}
