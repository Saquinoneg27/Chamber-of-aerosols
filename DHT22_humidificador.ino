#include "DHT.h"
#define DHTPIN 10     // Pin donde está conectado el sensor
#define DHTTYPE DHT22   // Sensor DHT22
int waterPump = 12; // Digital pin to which the water pump motor is connected
bool humidify = true; // False if one wants to dehumidify the chamber
int rhSetpoint1 = 44;
int rhSetpoint01 = 0;
float RHsetpoint;
int cont;

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  pinMode(waterPump, OUTPUT);
  Serial.begin(9600);0
  //Serial.setTimeout(1500);    //set the Timeout to 1500ms, longer than the data transmission periodic time of the sensor
  dht.begin();
  digitalWrite(waterPump, LOW); // Enciende el pin 13 (envía un 1)

}


// Function to check if the RH value is between a desired range
bool inRange(float RH_val, float RH_lowerBound, float RH_upperBound)
{
  return ((RH_lowerBound <= RH_val) && (RH_val <= RH_upperBound));
}

float readingRH() {

  float rh = dht.readHumidity();
  char rhC[3];
  //delay(200);
  //Serial.print(F("Relative humidity (%): "));  // Se debe comentar cuando se trabaja en Nextion
  Serial.println(rh);
    
  return rh;

}

float readingT() {

  float t = dht.readTemperature();
  char rhC[3];
  delay(1000);
    //Serial.print(F("Relative humidity (%): "));  // Se debe comentar cuando se trabaja en Nextion
  Serial.print(t);
  Serial.print(",");
  return t;

}

void loop()
{
  delay(10);

  //nexLoop(nex_listen_list);

  //OPC();

  // We start reading temp the value from the light sensor. Analog input : 0 to 1024. We map is to a value from 0 to 255 as it's used for our PWM function.
  float tempValue = readingT();
  float rh = readingRH();
  delay(500);
  RHsetpoint = 100;
  humidify = true;
  cont =0;
  int cont2 = 0;

  if (rh < (RHsetpoint+2)) {  // Si la humedad es menor que el setpoint
    //Serial.println("Humedad por debajo del setpoint, encendiendo");
    digitalWrite(waterPump, HIGH); // Enciende el pin 13 (envía un 1)
    delay(1000);  // Espera 500 milisegundos
    digitalWrite(waterPump, LOW);  // Apaga el pin 13 (envía un 0)
    //Serial.println("Pin 13 apagado.");

    
    while (cont2==0) {
      tempValue = readingT();
      rh = readingRH();
      delay(500);
      if (rh< RHsetpoint){
        cont2 = 1;
      }
      delay(10);
    }

    while (rh< RHsetpoint)
    {
      tempValue = readingT();
      rh = readingRH();
      delay(500);
    }
    cont = 1;
    //Serial.println("Conteo 1");
    delay(10);

  }
  if (cont == 1) {  // Si la humedad es mayor que el setpoint
    //Serial.println("Humedad por encima del setpoint, apagando");
    digitalWrite(waterPump, HIGH); // Enciende el pin 13 (envía un 1)
    delay(1000);  // Espera 500 milisegundos
    digitalWrite(waterPump, LOW);  // Apaga el pin 13 (envía un 0)
    //Serial.println(" apagado tras el primer parpadeo.");

    delay(500);

    digitalWrite(waterPump, HIGH); // Enciende el pin 13 (envía un 1)
    delay(1000);  // Espera 500 milisegundos
    digitalWrite(waterPump, LOW);  // Apaga el pin 13 (envía un 0)
   //
   //Serial.println("Pin 13 apagado tras el segundo parpadeo.");

  }
 

}


