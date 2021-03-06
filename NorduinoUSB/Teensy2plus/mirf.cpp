/**
 * Mirf
 *
 * Additional bug fixes and improvements
 *  07/13/2010:
 *   Added example to read a register
 *  11/12/2009:
 *   Fix dataReady() to work correctly
 *   Renamed keywords to keywords.txt ( for IDE ) and updated keyword list
 *   Fixed client example code to timeout after one second and try again
 *    when no response received from server
 * By: Nathan Isburgh <nathan@mrroot.net>
 * $Id: mirf.cpp 67 2010-07-13 13:25:53Z nisburgh $
 *
 *
 * An Ardunio port of:
 * http://www.tinkerer.eu/AVRLib/nRF24L01
 *
 * Significant changes to remove depencence on interupts and auto ack support.
 *
 * Aaron Shrimpton <aaronds@gmail.com>
 *
 */

/*
    Copyright (c) 2007 Stefan Engelke <mbox@stefanengelke.de>

    Permission is hereby granted, free of charge, to any person 
    obtaining a copy of this software and associated documentation 
    files (the "Software"), to deal in the Software without 
    restriction, including without limitation the rights to use, copy, 
    modify, merge, publish, distribute, sublicense, and/or sell copies 
    of the Software, and to permit persons to whom the Software is 
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be 
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
    DEALINGS IN THE SOFTWARE.

    $Id: mirf.cpp 67 2010-07-13 13:25:53Z nisburgh $
*/

#include "mirf.h"

// Defines for setting the MiRF registers for transmitting or receiving mode

Nrf24l Mirf = Nrf24l();

Nrf24l::Nrf24l(){
  #ifdef TEENSY2
	cePin = 24;
	csnPin = 20;
	channel = 1;
	payload = 16;
	irqPin=19;
  #else
	cePin = 15;
	csnPin = 0;
	channel = 1;
	payload = 16;
	irqPin=5;
	
  #endif
	  
	  
}

void Nrf24l::transferSync(uint8_t *dataout,uint8_t *datain,uint8_t len){
	uint8_t i;
	for(i = 0;i < len;i++){
		datain[i] = Spi.transfer(dataout[i]);
	}
}

void Nrf24l::transmitSync(uint8_t *dataout,uint8_t len){
	uint8_t i;
	for(i = 0;i < len;i++){
		Spi.transfer(dataout[i]);
	}
}

void Nrf24l::init() 
// Initializes pins to communicate with the MiRF module
// Should be called in the early initializing phase at startup.
{   
    pinMode(cePin,OUTPUT);
    pinMode(csnPin,OUTPUT);
    pinMode(irqPin,INPUT);
    ceLow();
    csnHi();

    // Initialize spi module
    Spi.mode((1 << SPR0));

    /*
     * Set double clock rate.
     */

    //SPSR = (1 << SPI2X);
}


bool Nrf24l::config() 
// Sets the important registers in the MiRF module and powers the module
// in receiving mode
// NB: channel and payload must be set now.
{
       // Check the status flag
    // Check
    byte status=checkDevice();
    
    // Set RF channel
	configRegister(RF_CH,channel);

    // Set length of incoming payload 
	configRegister(RX_PW_P0, payload);
	configRegister(RX_PW_P1, payload);

    // Start receiver 
    powerUpRx();
    flushRx();
    
    if (status==0x0E) 
      return true;
    else 
      return false;
}

void Nrf24l::configUSB(uint8_t * adr)
// Sets the important registers in the MiRF module and powers the module
// in receiving mode
// NB: channel and payload must be set now.
{

    configRegister(CONFIG, 0x0C); //16 bit CRC enabled, be a transmitter
    configRegister(EN_AA, 0x00); //Enable auto acknowledge on pipes 0
    configRegister(EN_RXADDR, 0x01); // Enable data pipe 0
    configRegister(SETUP_AW, 0x03); //Setup address with 5 bytes
    configRegister(SETUP_RETR,0x0F); //Setup 4 retransmits
    configRegister(RF_SETUP, 0x0E); //Air data rate 1Mbit, 0dBm, Setup LNA
    configRegister(RF_CH, channel); //Select channel

    // Set length of incoming payload
    configRegister(RX_PW_P0, payload);
    configRegister(RX_PW_P1, payload);
    setTADDR(adr);
    setRADDR(adr);
    // Start receiver
    powerUpTxUsb();
    Spi.transfer(0xFF);
    //flushTx();

}
byte Nrf24l::checkDevice()
// For the 24L01 the status register after a nop should be F
{
    csnLow();
    byte status=Spi.transfer(NOP);
    csnHi();
    
    return(status);

}

void Nrf24l::setRADDR(uint8_t * adr) 
// Sets the receiving address
{
	ceLow();
	writeRegister(RX_ADDR_P1,adr,mirf_ADDR_LEN);
	ceHi();
}

void Nrf24l::setTADDR(uint8_t * adr)
// Sets the transmitting address
{
	/*
	 * RX_ADDR_P0 must be set to the sending addr for auto ack to work.
	 */

	writeRegister(RX_ADDR_P0,adr,mirf_ADDR_LEN);
	writeRegister(TX_ADDR,adr,mirf_ADDR_LEN);
}

extern bool Nrf24l::dataReady() 
// Checks if data is available for reading
{
    // See note in getData() function - just checking RX_DR isn't good enough
	uint8_t status = getStatus();

    // We can short circuit on RX_DR, but if it's not set, we still need
    // to check the FIFO for any pending packets
    if ( status & (1 << RX_DR) ) return 1;
    return !rxFifoEmpty();
}

extern bool Nrf24l::rxFifoEmpty(){
	uint8_t fifoStatus;

	readRegister(FIFO_STATUS,&fifoStatus,sizeof(fifoStatus));
	return (fifoStatus & (1 << RX_EMPTY));
}



extern void Nrf24l::getData(uint8_t * data) 
// Reads payload bytes into data array
{
    csnLow();                               // Pull down chip select
    Spi.transfer( R_RX_PAYLOAD );            // Send cmd to read rx payload
    transferSync(data,data,payload); // Read payload
    csnHi();                               // Pull up chip select
    // NVI: per product spec, p 67, note c:
    //  "The RX_DR IRQ is asserted by a new packet arrival event. The procedure
    //  for handling this interrupt should be: 1) read payload through SPI,
    //  2) clear RX_DR IRQ, 3) read FIFO_STATUS to check if there are more 
    //  payloads available in RX FIFO, 4) if there are more data in RX FIFO,
    //  repeat from step 1)."
    // So if we're going to clear RX_DR here, we need to check the RX FIFO
    // in the dataReady() function
    configRegister(STATUS,(1<<RX_DR));   // Reset status register
}

void Nrf24l::configRegister(uint8_t reg, uint8_t value)
// Clocks only one byte into the given MiRF register
{
    csnLow();
    Spi.transfer(W_REGISTER | (REGISTER_MASK & reg));
    Spi.transfer(value);
    csnHi();
}

void Nrf24l::readRegister(uint8_t reg, uint8_t * value, uint8_t len)
// Reads an array of bytes from the given start position in the MiRF registers.
{
    csnLow();
    Spi.transfer(R_REGISTER | (REGISTER_MASK & reg));
    transferSync(value,value,len);
    csnHi();
}

void Nrf24l::writeRegister(uint8_t reg, uint8_t * value, uint8_t len) 
// Writes an array of bytes into inte the MiRF registers.
{
    csnLow();
    Spi.transfer(W_REGISTER | (REGISTER_MASK & reg));
    transmitSync(value,len);
    csnHi();
}


void Nrf24l::sendUsb(uint8_t * value)
// Sends a data package to the default address. Be sure to send the correct
// amount of bytes as configured as payload on the receiver.
{
    uint8_t status;
    status = getStatus();

    while (PTX) {
            status = getStatus();

            if((status & ((1 << TX_DS)  | (1 << MAX_RT)))){
                    PTX = 0;
                    break;
            }
    }                  // Wait until last paket is send

    ceLow();

    powerUpTxUsb();       // Set to transmitter mode , Power up

    csnLow();                    // Pull down chip select
    Spi.transfer( FLUSH_TX );     // Write cmd to flush tx fifo
    csnHi();                    // Pull up chip select

    csnLow();                    // Pull down chip select
    Spi.transfer( W_TX_PAYLOAD ); // Write cmd to write payload
    transmitSync(value,payload);   // Write payload
    csnHi();                    // Pull up chip select

    ceHi();                     // Start transmission
}

void Nrf24l::send(uint8_t * value) 
// Sends a data package to the default address. Be sure to send the correct
// amount of bytes as configured as payload on the receiver.
{
    uint8_t status;
    status = getStatus();

    while (PTX) {
	    status = getStatus();

	    if((status & ((1 << TX_DS)  | (1 << MAX_RT)))){
		    PTX = 0;
		    break;
	    }
    }                  // Wait until last paket is send

    ceLow();
    
    powerUpTx();       // Set to transmitter mode , Power up
    
    csnLow();                    // Pull down chip select
    Spi.transfer( FLUSH_TX );     // Write cmd to flush tx fifo
    csnHi();                    // Pull up chip select
    
    csnLow();                    // Pull down chip select
    Spi.transfer( W_TX_PAYLOAD ); // Write cmd to write payload
    transmitSync(value,payload);   // Write payload
    csnHi();                    // Pull up chip select

    ceHi();                     // Start transmission
}

/**
 * isSending.
 *
 * Test if chip is still sending.
 * When sending has finished return chip to listening.
 *
 */

bool Nrf24l::isSending(){
	uint8_t status;
	if(PTX){
		status = getStatus();
	    	
		/*
		 *  if sending successful (TX_DS) or max retries exceded (MAX_RT).
		 */

		if((status & ((1 << TX_DS)  | (1 << MAX_RT)))){
			powerUpRx();
			return false; 
		}

		return true;
	}
	return false;
}

uint8_t Nrf24l::getStatus(){
	uint8_t rv;
	readRegister(STATUS,&rv,1);
	return rv;
}

void Nrf24l::powerUpRx(){
	PTX = 0;
	ceLow();
	configRegister(CONFIG, mirf_CONFIG | ( (1<<PWR_UP) | (1<<PRIM_RX) ) );
	ceHi();
	configRegister(STATUS,(1 << TX_DS) | (1 << MAX_RT)); 
}

void Nrf24l::flushRx(){
    csnLow();
    Spi.transfer( FLUSH_RX );
    csnHi();
}

void Nrf24l::powerUpTx(){
	PTX = 1;
	configRegister(CONFIG, mirf_CONFIG | ( (1<<PWR_UP) | (0<<PRIM_RX) ) );
}

void Nrf24l::powerUpTxUsb(){
        PTX = 1;
        configRegister(CONFIG, 0x0E );
}

void Nrf24l::powerUpRxUsb(){
        PTX = 1;
        configRegister(CONFIG, 0x0F );
}

void Nrf24l::ceHi(){
	digitalWrite(cePin,HIGH);
}

void Nrf24l::ceLow(){
	digitalWrite(cePin,LOW);
}

void Nrf24l::csnHi(){
	digitalWrite(csnPin,HIGH);
}

void Nrf24l::csnLow(){
	digitalWrite(csnPin,LOW);
}
