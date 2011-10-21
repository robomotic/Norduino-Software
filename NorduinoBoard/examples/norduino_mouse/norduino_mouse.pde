/*
  Norduino_mouse.pde - Norduino board code for mouse transmitter
  Copyright (c) 2011 Robomotic ltd.  All right reserved.
  
  This sketch is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
*/
#include <Ports.h>
#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>
#include <Ports.h>

PortI2C myBus (1);
//Gravity plug on Port 1
GravityPlug sensor (myBus);
//Blink plug on Port 2
BlinkPlug blink (2);
typedef struct{
 int x;
 int y;
 int z;   
 byte event;
}Mousegrav;

Mousegrav sample;

void setup(){
    Serial.begin(57600);
    Serial.println("\n[gravity_demo]");
    sensor.begin();
  
  /*
   * Setup pins / SPI.
   */

  Mirf.init();
  
  /*
   * Configure reciving address.
   */
   
  Mirf.setRADDR((byte *)"mouse");
  
  /*
   * Set the payload length to sizeof(unsigned long) the
   * return type of millis().
   *
   * NB: payload on client and server must be the same.
   */
   
  Mirf.payload = sizeof(Mousegrav);
  
  Serial.print("Packet size is: ");
  Serial.println(Mirf.payload,DEC);
  
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
      #ifdef SERIALDEBUG 
      Serial.println("Sample request");
      #endif
      /*
       * Get load the packet into the buffer.
       */
     
      Mirf.getData(data);
      
      //Determine the request
      const int* p = sensor.getAxes();

      sample.x=p[0];
      sample.y=p[1];
      sample.z=p[2];
      sample.event=blink.buttonCheck();
      
      #ifdef SERIALDEBUG
      Serial.print("GRAV ");
      Serial.print(p[0]); 
      Serial.print(' ');
      Serial.print(p[1]);
      Serial.print(' ');
      Serial.println(p[2]);
      switch (sample.event) {
        
          case BlinkPlug::ON1:
              Serial.println("  Button 1 pressed"); 
              break;
          
          case BlinkPlug::OFF1:
              Serial.println("  Button 1 released"); 
              break;
          
          case BlinkPlug::ON2:
              Serial.println("  Button 2 pressed"); 
              break;
          
          case BlinkPlug::OFF2:
              Serial.println("  Button 2 released"); 
              break;
       }
       #endif
      /*
       * Set the send address.
       */
     
     
      Mirf.setTADDR((byte *)"host1");
    
      /*
       * Send the data back to the client.
       */
     
      Mirf.send((byte *)&sample);
    
      /*
       * Wait untill sending has finished
       *
       * NB: isSending returns the chip to receving after returning true.
       */
     
      while(Mirf.isSending()){
        //delay(100);
      }
      #ifdef SERIALDEBUG
      Serial.println("Sample sent.");
      #endif
    }while(!Mirf.rxFifoEmpty());
  }
}
