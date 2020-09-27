#include <LiquidCrystal.h>
#include <RTClib.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <IRremote.h>
#include <math.h>





//code to convert analogRead of thermistor (in Digital Temperature sensor) to Celsius degrees
double Thermistor(int sensorValue) {
  double Temp;
  Temp = log(2000.0*((1024.0/sensorValue-1)));
  Temp = 1 / (0.001129148 + (0.000234125 + (0.0000000876741 * Temp * Temp ))* Temp );
  Temp = Temp - 273.15;            // Convert Kelvin to Celcius
  return Temp;
}





// PIN DIGITAL TEMPERATURE
#define digTempPin A0

// PIN ACTIVE BUZZER
#define buzzPin A1

// PIN DIGITAL TEMPERATURE LINEAR HALL KY-028
#define magnPin A2

// PIN PHOTORESISTOR KY-018
#define lightPin A3

// PIN IR RECEIVER
#define irPin 4

// PIN TEMPERATURE&HUMIDITY SENSOR
#define dhtPin 7

// PIN LCD
#define brightnessPin 6
#define rs 8
#define en 9
#define d4 10
#define d5 11
#define d6 12
#define d7 13




// KY-018 LIGHT
int lightValue = 0;
int avgLight_py;

// KY-028 DIGITAL TEMPERATURE
float digitalTemp = 0;

// DHT11 TEMPERATURE&UMIDITY
DHT dht = DHT(dhtPin, DHT11);
float temp = 0;
float hum = 0;

// IR RECEIVER
IRrecv irRec(irPin);
decode_results results;

// LCD
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

// RTC DS1307 TIME&DATE
RTC_DS1307 rtc;


// ROMOTE COMMANDS CONSTANTS
const long down = 0xFFE01F;
const long up = 0xFF906F;
const long ok = 0xFF02FD;
const long left = 0xFF22DD;
const long right = 0xFFC23D;
const long zero = 0xFF6897;
const long one = 0xFF30CF;
const long two = 0xFF18E7;
const long three = 0xFF7A85;
const long four = 0xFF10EF;
const long five = 0xFF38C7;
const long six = 0xFF5AA5;
const long seven = 0xFF42BD;
const long eight = 0xFF4AB5;
const long nine = 0xFF52AD;
const long turnoff = 0xFFA25D;
const long volPlus = 0xFF629D;
const long volMinus = 0xFFA857;

// MENU CONSTANTS
const char *sveglia = "Alarm clock";
const char *timer = "Timer";
const char *temperatura = "Digital temper.";
const char *luce = "Light sensor";
const char *umidita = "Humidity sensor";

// index of menu
int menu = 0;

// brightness of LCD
int brightn;

// VARIABLES FOR ALARM CLOCK
boolean setAlarm = false;
boolean alarmIsSet = false;
boolean buzzerSounding = false;
int indexAlarm = 0;
// Hours of alarm (two digits)
int hAlarm1 = 0;
int hAlarm2 = 0;
// Minutes of alarm (two digits)
int mAlarm1 = 0;
int mAlarm2 = 0;
// Seconds of alarm (two digits)
int sAlarm1 = 0;
int sAlarm2 = 0;

// VARIABLES FOR TIMER
boolean setTimer = false;
boolean timerIsSet = false;
int indexTimer = 0;
// Hours of timer (two digits)
int hTimer1 = 0;
int hTimer2 = 0;
// Minutes of timer (two digits)
int mTimer1 = 0;
int mTimer2 = 0;
// Seconds of timer (two digits)
int sTimer1 = 0;
int sTimer2 = 0;

// VOLUME OF BUZZER
boolean volume = true;





void setup() {
  Serial.begin(9600);
  pinMode(magnPin, INPUT);
  pinMode(lightPin, INPUT);
  pinMode(dhtPin, INPUT);
  pinMode(buzzPin, OUTPUT);
  pinMode(irPin, INPUT);
  pinMode(brightnessPin, OUTPUT);

  analogWrite(brightnessPin, 255);
  
  // Begin LCD
  lcd.begin(16, 2);

  // Set up time and date on RTC
  if (! rtc.begin()) {
    Serial.println("Error finding RTC");
    return;
  }
  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));

  // Begin IR receiver
  irRec.enableIRIn();
//  irRec.blink13(true); //CREA PROBLEMI DI INTERFERENZA CON L'LCD
}

void loop() {

  // PRINT ON SERIAL FOR PROCESSING /e for Python script)
  lightValue = analogRead(lightPin);
  // Get temperature from Digital Temperature sensor
  digitalTemp = Thermistor(analogRead(digTempPin));
  // Get temperature and humidity from DHT11
  if (!isnan(dht.readTemperature()))
    temp = dht.readTemperature();
  if (!isnan(dht.readHumidity()))
    hum = dht.readHumidity();
  
  Serial.print(lightValue);
  Serial.print(",");
  Serial.print(digitalTemp);
  Serial.print(",");
  Serial.print(temp);
  Serial.print(",");
  Serial.println(hum);



  // ADJUST BRIGHTNESS OF LCD, READING (from serial) THE AVERAGE OF LIGHT VALUES OF LIGHT SENSOR 
  if (Serial.available() > 0) {
    // reading the average calculated by python script
    avgLight_py = Serial.readString().toInt();
    // the value of brightness has to be between 0 and 255.
    if (avgLight_py > 900)
      brightn = 20;
    else if (avgLight_py > 700)
      brightn = 70;
    else if (avgLight_py > 500)
      brightn = 120;
    else if (avgLight_py > 300)
      brightn = 170;
    else if (avgLight_py > 100)
      brightn = 220;
    else
      brightn = 255;
    
    analogWrite(brightnessPin, brightn);
  }




  // MENU AND VOLUME CONTROLLING
  if (irRec.decode(&results)) 
  {
    Serial.println(results.value, HEX);
    
    switch(results.value){
      case down:
        buzzerSound();
        menu++;
        updateMenu();
        break;
      case up:
        buzzerSound();
        menu--;
        updateMenu();
        break;
      case ok:
        buzzerSound();
        executeAction();
        break;
      case turnoff:
        buzzerSound();
        buzzerSounding = false;
        menu = 0;
        break;
      case volPlus:
        buzzerSound();
        volume = true;
        lcd.clear();
        lcd.print("Volume of");
        lcd.setCursor(0,1);
        lcd.print("buzzer on!");
        delay(500);
        break;
      case volMinus:
        buzzerSound();
        volume = false;
        lcd.clear();
        lcd.print("Volume of");
        lcd.setCursor(0,1);
        lcd.print("buzzer off!");
        delay(500);
        break;
    }
    
    irRec.resume();
  }
  


  // IF BUZZER IS RINGING
  if (buzzerSounding)
  {
    // switching off the alarm with on/off button of the romote
    if (irRec.decode(&results)) 
    {
      if (results.value == turnoff)
        buzzerSounding = false;
      irRec.resume();
    }
    
    // alarm sound
    digitalWrite(buzzPin, HIGH);
    delay(100);
    digitalWrite(buzzPin, LOW);
    delay(100);
    digitalWrite(buzzPin, HIGH);
    delay(100);
    digitalWrite(buzzPin, LOW);
    delay(100);
    digitalWrite(buzzPin, HIGH);
    delay(100);
    digitalWrite(buzzPin, LOW);
    delay(300);
  }





  // HOME
  else if (menu==0)
  {
    
    // Get time and date from RTC
    DateTime now = rtc.now();

    // If it is time of the alarm clock
    if(alarmIsSet && isTimeOfAlarm(now.hour(), now.minute(), now.second()))
    {
      buzzerSounding = true;      
      alarmIsSet = false;
      lcd.home();
      lcd.clear();
      lcd.print("ALARM CLOCK!");
      lcd.setCursor(0,1);
      // mettere indicazione su come spegnerla? (sulla seconda riga) 
    }
    // Otherwise, home screen with date, time and temperature
    else
    {
      // Write time on LCD
      lcd.home();
      lcdPrintNumber(now.hour());
      lcd.print(":");
      lcdPrintNumber(now.minute());
      lcd.print(":");
      lcdPrintNumber(now.second());
      //space
      lcd.print("    ");
      
      // Write digital temperature on LCD
      lcdPrintTemperature(digitalTemp);
      
      // Write date on LCD
      lcd.setCursor(0,1);
      lcdPrintNumber(now.day());
      lcd.print("-");
      lcdPrintNumber(now.month());
      lcd.print("-");
      lcd.print(now.year());
      // space
      lcd.print("      ");
      
      delay(100);
    }
  }







  // SETTING ALARM MODE
  else if (setAlarm)
  {   
    // if setting mode is on hours, hours flash
    if (indexAlarm==0 || indexAlarm==1)
    {
      lcd.setCursor(0, 1);
      lcd.print("  ");
      delay(300);
      lcd.setCursor(0, 1);
      lcd.print(hAlarm1);
      lcd.print(hAlarm2);
      lcd.print(":");
      lcd.print(mAlarm1);
      lcd.print(mAlarm2);
      lcd.print(":");
      lcd.print(sAlarm1);
      lcd.print(sAlarm1);
      delay(300);
    }
    // if setting mode is on minutes, minutes flash
    else if (indexAlarm==3 || indexAlarm==4)
    {
      lcd.setCursor(0,1);
      lcd.print(hAlarm1);
      lcd.print(hAlarm2);
      lcd.print(":");
      lcd.print("  ");
      delay(300);
      lcd.setCursor(3, 1);
      lcd.print(mAlarm1);
      lcd.print(mAlarm2);
      lcd.print(":");
      lcd.print(sAlarm1);
      lcd.print(sAlarm1);
      delay(300);
    }
    // if setting mode is on seconds, seconds flash
    else if (indexAlarm==6 || indexAlarm==7)
    {
      lcd.setCursor(0,1);
      lcd.print(hAlarm1);
      lcd.print(hAlarm2);
      lcd.print(":");
      lcd.print(mAlarm1);
      lcd.print(mAlarm2);
      lcd.print(":");
      lcd.print("  ");
      delay(300);
      lcd.setCursor(6, 1);
      lcd.print(sAlarm1);
      lcd.print(sAlarm2);
      delay(300);
    }

    // setting commands
    if (irRec.decode(&results)) 
    {
      
      switch(results.value){
        // left button switches the setting from minutes to hours or from seconds to minutes
        case left:
          buzzerSound();
          indexAlarm-=3;
          if (indexAlarm < 0)
            indexAlarm = 0;
          break;
        // right button switches the setting from hours to minutes or from minutes to seconds
        case right:
          buzzerSound();
          indexAlarm+=3;
          if (indexAlarm > 7)
            indexAlarm = 6;
          break;
        // updating the number corrispondent to indexAlarm with the value pressed
        case zero:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 0);
          indexAlarm++;
          break;
        case one:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 1);
          indexAlarm++;
          break;
        case two:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 2);
          indexAlarm++;
          break;
        case three:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 3);
          indexAlarm++;
          break;
        case four:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 4);
          indexAlarm++;
          break;
        case five:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 5);
          indexAlarm++;
          break;
        case six:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 6);
          indexAlarm++;
          break;
        case seven:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 7);
          indexAlarm++;
          break;
        case eight:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 8);
          indexAlarm++;
          break;
        case nine:
          buzzerSound();
          updateAlarmVariable(indexAlarm, 9);
          indexAlarm++;
          break;
      }
      // case when in indexAlarm there is : symbol
      if (indexAlarm==2 || indexAlarm==5)
        indexAlarm++;

      // Alarm clock set
      if (indexAlarm>7)
      {
        // if the time is not correct, print error on LCD
        if (hAlarm1*10 + hAlarm2 > 23 || mAlarm1*10 + mAlarm2 > 60 || sAlarm1*10 + sAlarm2 > 60)
        {
          lcd.clear();
          lcd.print("ERROR!");
          lcd.setCursor(0,1);
          lcd.print("Setting failed");
          cleanAlarmVariables();
        }
        // otherwise, the alarm is set correctly
        else
        {
          lcd.clear();
          lcd.print("Alarm clock set");
          lcd.setCursor(0,1);
          lcd.print("at ");
          lcd.print(hAlarm1);
          lcd.print(hAlarm2);
          lcd.print(":");
          lcd.print(mAlarm1);
          lcd.print(mAlarm2);
          lcd.print(":");
          lcd.print(sAlarm1);
          lcd.print(sAlarm2);
          alarmIsSet = true;
        }
        menu = 0;
        setAlarm = false;
        delay(4000);
      }
      
      irRec.resume();
    }
  }






  // SETTING TIMER
  else if (setTimer)
  {    
    // if setting mode is on hours, hours flash
    if (indexTimer==0 || indexTimer==1)
    {
      lcd.setCursor(0, 1);
      lcd.print("  ");
      delay(300);
      lcd.setCursor(0, 1);
      lcd.print(hTimer1);
      lcd.print(hTimer2);
      lcd.print(":");
      lcd.print(mTimer1);
      lcd.print(mTimer2);
      lcd.print(":");
      lcd.print(sTimer1);
      lcd.print(sTimer2);
      delay(300);
    }
    // if setting mode is on minutes, minutes flash
    else if (indexTimer==3 || indexTimer==4)
    {
      lcd.setCursor(0,1);
      lcd.print(hTimer1);
      lcd.print(hTimer2);
      lcd.print(":");
      lcd.print("  ");
      delay(300);
      lcd.setCursor(3, 1);
      lcd.print(mTimer1);
      lcd.print(mTimer2);
      lcd.print(":");
      lcd.print(sTimer1);
      lcd.print(sTimer2);
      delay(300);
    }
    // if setting mode is on seconds, seconds flash
    else if (indexTimer==6 || indexTimer==7)
    {
      lcd.setCursor(0,1);
      lcd.print(hTimer1);
      lcd.print(hTimer2);
      lcd.print(":");
      lcd.print(mTimer1);
      lcd.print(mTimer2);
      lcd.print(":");
      lcd.print("  ");
      delay(300);
      lcd.setCursor(6, 1);
      lcd.print(sTimer1);
      lcd.print(sTimer2);
      delay(300);
    }

    // setting commands
    if (irRec.decode(&results)) 
    {
      
      switch(results.value){
        // left button switches the setting from minutes to hours or from seconds to minutes
        case left:
          buzzerSound();
          indexTimer-=3;
          if (indexTimer < 0)
            indexTimer = 0;
          break;
        // right button switches the setting from hours to minutes or from minutes to seconds
        case right:
          buzzerSound();
          indexTimer+=3;
          if (indexTimer > 7)
            indexTimer = 6;
          break;
        // updating the number corrispondent to indexAlarm with the value pressed
        case zero:
          buzzerSound();
          updateTimerVariable(indexTimer, 0);
          indexTimer++;
          break;
        case one:
          buzzerSound();
          updateTimerVariable(indexTimer, 1);
          indexTimer++;
          break;
        case two:
          buzzerSound();
          updateTimerVariable(indexTimer, 2);
          indexTimer++;
          break;
        case three:
          buzzerSound();
          updateTimerVariable(indexTimer, 3);
          indexTimer++;
          break;
        case four:
          buzzerSound();
          updateTimerVariable(indexTimer, 4);
          indexTimer++;
          break;
        case five:
          buzzerSound();
          updateTimerVariable(indexTimer, 5);
          indexTimer++;
          break;
        case six:
          buzzerSound();
          updateTimerVariable(indexTimer, 6);
          indexTimer++;
          break;
        case seven:
          buzzerSound();
          updateTimerVariable(indexTimer, 7);
          indexTimer++;
          break;
        case eight:
          buzzerSound();
          updateTimerVariable(indexTimer, 8);
          indexTimer++;
          break;
        case nine:
          buzzerSound();
          updateTimerVariable(indexTimer, 9);
          indexTimer++;
          break;
      }
      
      // case when in indexAlarm there is : symbol
      if (indexTimer==2 || indexTimer==5)
        indexTimer++;

      // Timer set
      if (indexTimer>7)
      {
        // if the time is not correct, print error on LCD
        // in this case, I check only minutes and seconds (i.e. I let hours to be more than 23)
        if (mAlarm1*10 + mAlarm2 > 60 || sAlarm1*10 + sAlarm2 > 60)
        {
          lcd.clear();
          lcd.print("ERROR!");
          lcd.setCursor(0,1);
          lcd.print("Setting failed");
          cleanTimerVariables();
        }
        // otherwise, the timer is set correctly
        else
        {
          lcd.clear();
          lcd.print("Timer set!");
          delay(500);
          lcd.clear();
          setTimer = false;
          timerIsSet = true;
        }
      }
      
      irRec.resume();
    }
  }






  

  // TIMER SCREEN
  else if (timerIsSet)
  {
    // every second, I update the fields that have to be updated
    sTimer2--;
    if (sTimer2 < 0)
    {
      sTimer2 = 9;
      sTimer1--;
      if (sTimer1 < 0)
      {
        sTimer1 = 5;
        mTimer2--;
        if (mTimer2 < 0)
        {
          mTimer2 = 9;
          mTimer1--;
          if (mTimer1 < 0)
          {
            mTimer1 = 5;
            hTimer2--;
            if (hTimer2 < 0)
            {
              hTimer2 = 9;
              hTimer1--;
              // TIMER OVER
              if (hTimer1 < 0)
              {
                lcd.clear();
                lcd.print("Timer is over!");
                timerIsSet = false;
                menu = 0;
                buzzerSounding = true;
                return;
              }
            }
          }
        }
      }
    }

    lcd.home();
    lcd.print("TIMER");
    lcd.setCursor(0,1);
    lcd.print(hTimer1);
    lcd.print(hTimer2);
    lcd.print(":");
    lcd.print(mTimer1);
    lcd.print(mTimer2);
    lcd.print(":");
    lcd.print(sTimer1);
    lcd.print(sTimer2);
    
    delay(1000);
  }

}











/*
 * Function to print a number always with two digits (for hours, minutes and seconds)
 */
void lcdPrintNumber(int num)
{
  if (num<10)
    lcd.print("0");
  lcd.print(num);
}

/*
 * Function to print temperature with one decimal digit and the unit of measure
 */
void lcdPrintTemperature(float temp)
{
  if (temp<10)
    lcd.print(" ");
  lcd.print((int)temp);
  lcd.print(" C");
}

/*
 * A short sound of buzzer.
 */
void buzzerSound()
{
  if (volume==false)
    return;

  digitalWrite(buzzPin, HIGH);
  delay(100);
  digitalWrite(buzzPin, LOW);
}







/*
 * Function to show the righ screen of the menu.
 */
void updateMenu() {
  lcd.clear();
  if (menu <= 0)
    menu = 0;
  else if (menu == 1)
  {
    lcd.print(">");
    lcd.print(sveglia);
    lcd.setCursor(0, 1);
    lcd.print(" ");
    lcd.print(timer);
  }
  else if (menu == 2)
  {
    lcd.print(" ");
    lcd.print(sveglia);
    lcd.setCursor(0, 1);
    lcd.print(">");
    lcd.print(timer);
  }
  else if (menu == 3)
  {
    lcd.print(">");
    lcd.print(temperatura);
    lcd.setCursor(0, 1);
    lcd.print(" ");
    lcd.print(luce);
  }
  else if (menu == 4)
  {
    lcd.print(" ");
    lcd.print(temperatura);
    lcd.setCursor(0, 1);
    lcd.print(">");
    lcd.print(luce);
  }
  else if (menu >= 5)
  {
    lcd.print(">");
    lcd.print(umidita);
    menu = 5;
  }
}

/*
 * According to the item of the menu that has been selected, execute one of the functions below.
 */
void executeAction() {
  switch (menu) {
    case 1:
      actionAlarmClock();
      break;
    case 2:
      Serial.println("Sto qui.");
      actionTimer();
      break;
    case 3:
      actionTemperature();
      break;
    case 4:
      actionLight();
      break;
    case 5:
      actionHumidity();
      break;
  }
}

// FUNCTIONS OF THE MENU
/*
 * ITEM 1: Alarm clock.
 * Function to set an alarm.
 */
void actionAlarmClock() {
  setAlarm = true;
  lcd.clear();
  lcd.print("ALARM CLOCK SET");
  lcd.setCursor(0,1);
  lcd.print("00:00:00");
}

/*
 * ITEM 2: Timer.
 * Function to set a timer.
 */
void actionTimer() {
  setTimer = true;
  lcd.clear();
  lcd.print("TIMER SETTING");
  lcd.setCursor(0,1);
  lcd.print("00:00:00");
}

/*
 * ITEM 3: Digital Temperature
 * Function to see the values of the Digital Temperature sensor.
 */
void actionTemperature() {
  lcd.clear();
  // read digital temperature from the sensor and convert the value to Celsius degrees.
  digitalTemp = Thermistor(analogRead(digTempPin));
  // write value on lcd
  lcd.print("Digital temperature:");
  lcd.setCursor(0,1);
  lcd.print(digitalTemp);
  lcd.print(" C");
}


/*
 * ITEM 4: Light sensor
 * Function to see the values of the Light sensor.
 */
void actionLight() {
  lcd.clear();
  // read light from the sensor
  lightValue = analogRead(lightPin);
  // write value on lcd
  if (lightValue < 70)
    lcd.print("Very bright!");
  else if (lightValue >= 70 and lightValue < 300)
    lcd.print("Bright light!");
  else if (lightValue >= 300 and lightValue < 500)
    lcd.print("Medium light!");
  else if (lightValue >= 500 and lightValue < 800)
    lcd.print("Low light!");
  else
    lcd.print("No light!");

  lcd.setCursor(0,1);
  lcd.print("Value: ");
  lcd.print(lightValue);
}

/*
 * ITEM 5: Humidity and Temperature sensor
 * Function to see the values of the Humidity and Temperature sensor.
 */
void actionHumidity() {
  lcd.clear();
  lcd.print("Humidity ");
  lcd.print(hum);
  lcd.setCursor(14,0);
  lcd.print(" %");
  
  lcd.setCursor(0,1);
  lcd.print("Temperat. ");
  lcd.print(temp);
  lcd.setCursor(14,1);
  lcd.print(" C");
}











/*
 * According to the indexVariable, the function updates a variable of the alarm with the parameter value.
 */
void updateAlarmVariable(int indexVariable, int value)
{
  switch(indexVariable)
  {
    case 0:
      hAlarm1 = value;
      break;
    case 1:
      hAlarm2 = value;
      break;
    // in indexVariable=2 there is : symbol
    case 3:
      mAlarm1 = value;
      break;
    case 4:
      mAlarm2 = value;
      break;
    // in indexVariable=5 there is : symbol
    case 6:
      sAlarm1 = value;
      break;
    case 7:
      sAlarm2 = value;
  }
}

void cleanAlarmVariables()
{
  setAlarm = false;
  alarmIsSet = false;
  buzzerSounding = false;
  indexAlarm = 0;
  hAlarm1 = 0;
  hAlarm2 = 0;
  mAlarm1 = 0;
  mAlarm2 = 0;
  sAlarm1 = 0;
  sAlarm2 = 0;
}

/*
 * Check if the actual time is the time of the alarm.
 */
int isTimeOfAlarm(int h, int m, int s)
{
  if (hAlarm1*10 + hAlarm2 == h && mAlarm1*10 + mAlarm2 == m && sAlarm1*10 + sAlarm2 <= s )
    return 1;
  else
    return 0;
}

/*
 * According to the indexVariable, the function updates a variable of the timer with the parameter value.
 */
void updateTimerVariable(int indexVariable, int value)
{
  switch(indexVariable)
  {
    case 0:
      hTimer1 = value;
      break;
    case 1:
      hTimer2 = value;
      break;
    // in indexVariable=2 there is :
    case 3:
      mTimer1 = value;
      break;
    case 4:
      mTimer2 = value;
      break;
    // in indexVariable=5 there is :
    case 6:
      sTimer1 = value;
      break;
    case 7:
      sTimer2 = value;
  }
}

void cleanTimerVariables()
{
  setTimer = false;
  timerIsSet = false;
  indexTimer = 0;
  hTimer1 = 0;
  hTimer2 = 0;
  mTimer1 = 0;
  mTimer2 = 0;
  sTimer1 = 0;
  sTimer2 = 0;
}
