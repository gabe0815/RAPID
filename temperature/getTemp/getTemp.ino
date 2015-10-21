 #include <OneWire.h>

// OneWire DS18S20, DS18B20, DS1822 Temperature Example
//
// http://www.pjrc.com/teensy/td_libs_OneWire.html
//
// The DallasTemperature library can do all this work for you!
// http://milesburton.com/Dallas_Temperature_Control_Library

OneWire  ds(2);  // on pin 2 (a 4.7K resistor is necessary)
byte sensor0[8] = {0x10,0x37,0x2C,0xBF,0x2,0x8,0x0,0x78}; //ROM = 10 37 2C BF 2 8 0 78
byte sensor1[8] = {0x10,0x35,0x8B,0xBF,0x2,0x8,0x0,0x74};
byte type_s;
double temp;
int incomingByte = 0; 

void setup(){

    Serial.begin(9600);

}

void loop(){
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    // get incoming byte:
    getTemp(sensor0);
    getTemp(sensor1);
  }
   

}
double getTemp(byte device[8]) {
    switch (device[0]) {
    case 0x10:
      type_s = 1;
      break;
    case 0x28:
      type_s = 0;
      break;
    case 0x22:
      type_s = 0;
      break;
    } 
  
  //Serial.println("measuring...");
  byte i;
  byte present = 0;
  byte data[12];

  float celsius;
  
  if (OneWire::crc8(device, 7) != device[7]) {
      Serial.println("CRC is not valid!");
  }
 

  ds.reset();
  ds.select(device);
  ds.write(0x44, 1);        // start conversion, with parasite power on at the end
  
  delay(1000);     // maybe 750ms is enough, maybe not
  // we might do a ds.depower() here, but the reset will take care of it.
  
  present = ds.reset();
  ds.select(device);    
  ds.write(0xBE);         // Read Scratchpad
    for ( i = 0; i < 9; i++) {           // we need 9 bytes
    data[i] = ds.read();
  }
    // Convert the data to actual temperature
  // because the result is a 16 bit signed integer, it should
  // be stored to an "int16_t" type, which is always 16 bits
  // even when compiled on a 32 bit processor.
  int16_t raw = (data[1] << 8) | data[0];
  if (type_s) {
    raw = raw << 3; // 9 bit resolution default
    if (data[7] == 0x10) {
      // "count remain" gives full 12 bit resolution
      raw = (raw & 0xFFF0) + 12 - data[6];
    }
  } else {
    byte cfg = (data[4] & 0x60);
    // at lower res, the low bits are undefined, so let's zero them
    if (cfg == 0x00) raw = raw & ~7;  // 9 bit resolution, 93.75 ms
    else if (cfg == 0x20) raw = raw & ~3; // 10 bit res, 187.5 ms
    else if (cfg == 0x40) raw = raw & ~1; // 11 bit res, 375 ms
    //// default is 12 bit resolution, 750 ms conversion time
  }
  celsius = (double)raw / 16.0;
  Serial.print(celsius);

  return celsius;
}

