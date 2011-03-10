/**
 * Checks if we can communicate with the chip
 * 2011-03-10 www.norduino.com http://opensource.org/licenses/mit-license.php
 * Uses the Mirf library
 */

#include <Spi.h>
#include <mirf.h>
#include <nRF24L01.h>

void setup() {
  Serial.begin(9600);
  Serial.println( "Starting wireless..." );

  // Setup
  Mirf.init();
  Mirf.setRADDR((byte *)"clie1");
  Mirf.payload = sizeof(unsigned long);
  Mirf.config();
  
  // Read and print RF_SETUP
  byte rf_setup = 0;
  Mirf.readRegister( RF_SETUP, &rf_setup, sizeof(rf_setup) );
  Serial.print( "rf_setup = " );
  Serial.println( rf_setup, BIN );

  Serial.println( "Wireless initialized!" );
}

void loop() {}
