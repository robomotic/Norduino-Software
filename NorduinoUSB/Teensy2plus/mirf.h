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

    $Id$
*/

#ifndef _MIRF_H_
#define _MIRF_H_

#include <WProgram.h>
#include <Spi.h>

#include "nRF24L01.h"
// Nrf24l settings

#define mirf_ADDR_LEN	5
#define mirf_CONFIG     ( (1 << MASK_TX_DS) | (1<<EN_CRC) | (0<<CRCO) )

class Nrf24l {
	public:
		Nrf24l();

		void init();
		bool config();
                void configUSB(uint8_t * adr);
		void send(uint8_t *value);
                void sendUsb(uint8_t *value);
		void setRADDR(uint8_t * adr);
		void setTADDR(uint8_t * adr);
		bool dataReady();
		bool isSending();
		bool rxFifoEmpty();
		bool txFifoEmpty();
		void getData(uint8_t * data);
		uint8_t getStatus();
		byte checkDevice();
		void transmitSync(uint8_t *dataout,uint8_t len);
		void transferSync(uint8_t *dataout,uint8_t *datain,uint8_t len);
		void configRegister(uint8_t reg, uint8_t value);
		void readRegister(uint8_t reg, uint8_t * value, uint8_t len);
		void writeRegister(uint8_t reg, uint8_t * value, uint8_t len);
		void powerUpRx();
                void powerUpRxUsb();
		void powerUpTx();
                void powerUpTxUsb();
		
		void csnHi();
		void csnLow();

		void ceHi();
		void ceLow();
		void flushRx();

		/*
		 * In sending mode.
		 */

		uint8_t PTX;

		/*
		 * CE Pin controls RX / TX, default 8.
		 */

		uint8_t cePin;

		/*
		 * CSN Pin Chip Select Not, default 7.
		 */

		uint8_t csnPin;

		/*
		 * Interrupt pin for the Nordic module
		 */
		uint8_t irqPin;
		/*
		 * Channel 0 - 127 or 0 - 84 in the US.
		 */
		uint8_t channel;

		/*
		 * Payload width in bytes default 16 max 32.
		 */

		uint8_t payload;
};

extern Nrf24l Mirf;

#endif /* _MIRF_H_ */
