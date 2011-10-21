/*
  Teensy2 Mouse Host sketch- Computer host code for the Norduino mouse board
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

#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>

//#define SERIALDEBUG

#define TEENSY2

typedef struct{
 int x;
 int y;
 int z;   
 byte event;
}Mousegrav;

Mousegrav sample;
boolean mouseEnabled=false;
int mouseX,mouseY;
//button status
enum { ALL_OFF, ON1, OFF1, ON2, OFF2, SOME_ON, ALL_ON };

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
   
  Mirf.setRADDR((byte *)"host1");
  
  /*
   * Set the payload length to sizeof(unsigned long) the
   * return type of millis().
   *
   * NB: payload on client and server must be the same.
   */
   
  Mirf.payload = sizeof(Mousegrav);
  #ifdef SERIALDEBUG
  Serial.print("Packet size is: ");
  Serial.println(Mirf.payload,DEC);
  #endif
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
  
  Mirf.setTADDR((byte *)"mouse");
  
  Mirf.send((byte *)&data);
  
  while(Mirf.isSending()){
  }
  #ifdef SERIALDEBUG 
  Serial.println("Sample request");
  #endif
  delay(10);
  while(!Mirf.dataReady()){
    //Serial.println("Waiting");
    /*
    if ( ( millis() - time ) > 1000 ) {
      Serial.println("No response from mouse!");
      return;
    }*/
  }
  
  Mirf.getData(data);
  if(Mirf.payload==sizeof(Mousegrav))
  {
    sample=*(Mousegrav*) data;
    mouseX = map(sample.x, -240, 240, -127, 127);
    mouseY = map(sample.y, -240, 240, -127, 127);
    #ifndef SERIALDEBUG
    if(mouseEnabled)
    {
    Mouse.move(mouseX/2, -mouseY/2);

    }
    if(sample.event==OFF1)
        Mouse.click();
    if(sample.event==OFF2)
        mouseEnabled=!mouseEnabled;
    delay(25);
    #endif
    #ifdef SERIALDEBUG 
    /*
    Serial.print("X: ");
    Serial.print(sample.x);
    Serial.print(" Y: ");
    Serial.print(sample.y);
    Serial.print(" Z: ");
    Serial.print(sample.z);
    Serial.print(" DeltaX: ");
    Serial.print(mouseX/2);
    Serial.print(" DeltaY: ");
    Serial.println(mouseY/2);
*/
    switch (sample.event) {
        
          case ON1:

              Serial.println("Button 1 pressed"); 

              break;
          
          case OFF1:
 
              Serial.println("Button 1 released"); 
   
              break;
          
          case ON2:
  
              Serial.println("Button 2 pressed");
    
              break;
          
          case OFF2:

              mouseEnabled=!mouseEnabled;
              Serial.print("Mouse is "); 
              Serial.println(mouseEnabled,DEC); 
              break;
     }
     delay(25);
     #endif
  }
  
} 
  
  
  
