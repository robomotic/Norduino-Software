// Demo for the Dimmer plug
// 2010-03-18 <jcw@equi4.com> http://opensource.org/licenses/mit-license.php
// $Id: dimmer_demo.pde 6238 2010-11-22 20:04:44Z jcw $

#include <Ports.h>
#include <RF12.h> // needed to avoid a linker error :(

PortI2C myBus (1);
DimmerPlug dimmer (myBus, 0x40);

int level = 0x1FF;

static void set4(byte reg, byte a1, byte a2, byte a3, byte a4) {
    dimmer.send();
    dimmer.write(0xE0 | reg);
    dimmer.write(a1);
    dimmer.write(a2);
    dimmer.write(a3);
    dimmer.write(a4);
    dimmer.stop();
}

static void initRGBW() {
    dimmer.setReg(DimmerPlug::MODE1, 0x00);     // normal
    dimmer.setReg(DimmerPlug::MODE2, 0x14);     // inverted, totem-pole
    dimmer.setReg(DimmerPlug::GRPPWM, 0xFF);    // max brightness
    set4(DimmerPlug::LEDOUT0, ~0, ~0, ~0, ~0);  // all LEDs group-dimmable
}

void setup () {
    initRGBW();
}

void loop () {
    ++level;
    
    byte brightness = level;
    if (level & 0x100)
        brightness = ~ brightness;

    byte r = (level >> 9) & 1 ? brightness : 0;
    byte g = (level >> 10) & 1 ? brightness : 0;
    byte b = (level >> 11) & 1 ? brightness : 0;
    byte w = (level >> 12) & 1 ? brightness : 0;

    // treat each group of 4 LEDS as RGBW combinations
    set4(DimmerPlug::PWM0, w, b, g, r);
    set4(DimmerPlug::PWM4, w, b, g, r);
    set4(DimmerPlug::PWM8, w, b, g, r);
    set4(DimmerPlug::PWM12, w, b, g, r);
}
