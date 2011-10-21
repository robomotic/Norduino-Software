/**
 * Emulates the nordic key fob from sparkfun http://www.sparkfun.com/products/8602
 * Use the nordic fob to send key strokes!
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */


#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>
byte tx_addr[5] = {0xE7, 0xE7, 0xE7, 0xE7, 0xE7};
byte rx_addr[5]={0xD7, 0xD7, 0xD7, 0xD7, 0xD7};
uint8_t data_array[4];

#define DOWN 0x1E
#define LEFT 0x17
#define RIGHT 0x1B
#define CENTER 0x0F
	
void setup(){
  Serial.begin(9600);
  
  /*
   * Setup pins / SPI.
   */

  Mirf.init();
  
  /*
   * Configure reciving address.
   * it doesn't matter as the receiver will not reply!
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
  
  Mirf.setTADDR(tx_addr);
  
  for(int btpress=0;btpress<10;btpress++)
  {
    data_array[0]=LEFT;
    data_array[1] = btpress >> 8;
    data_array[2] = btpress & 0xFF;
    data_array[3] = 0;  
    Mirf.send(data_array);
    while(Mirf.isSending()){
    }
    Serial.println("Sent");
    delay(10);

  }

} 

