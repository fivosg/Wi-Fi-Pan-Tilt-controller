#include <Servo.h>
#include <PCD8544.h>
static PCD8544 lcd;
const int steppin = 7;  //stepstick step pin
const int dirpin = 8;    //stepstick direction pin
const int enable = 6;   //stepstick enable pin
const int servopin = 5;  //servo pin
int posValue = 0;        // position (steps)
int current = 0;         // current position
Servo myservo;
int pos = 90;

void setup()
{
  // PCD8544-compatible displays may have a different resolution...
  lcd.begin(84, 48);
  
  Serial.begin(9600);
  Serial.println("Starting pan/tilt controller");
 
  pinMode(steppin, OUTPUT);
  pinMode(dirpin, OUTPUT);
  pinMode(enable, OUTPUT);
 
  digitalWrite(dirpin, HIGH);
  digitalWrite(steppin, LOW);
  digitalWrite(enable, HIGH);
  myservo.attach(servopin, 771-6, 1798-6);   //attach servo to pin
  myservo.write(pos);              //starting servo possition
  Serial.println ("To rotate axis x enter: 0-360x");
  Serial.println ("To rotate axis y enter: 0-180y");
}

void loop() 
{
   int i, j, steps;
   static int possition = 0; // position (degrees)
   i = 2000;                 //Set start speed
   char ch;
  lcd.setCursor(0, 0);
  lcd.println("*  Pan/Tilt  *");
  lcd.print("Controller");

   if ( Serial.available()) {   
    char ch = Serial.read();
    
     switch(ch) {
      case '0'...'9':
        possition = possition * 10 + ch - '0';
        break;
      case 'x':                                          //stepping routine
        {
         possition = constrain(possition, 0, 360);
         digitalWrite(enable, LOW);                      //enabling stepper
         Serial.print ("Moving x axis to: ");
         Serial.println(possition); 
         lcd.setCursor(0, 3);
         lcd.print("X axis : ");
         lcd.print(possition);
         lcd.print("  ");
         int posValue = map(possition, 0, 360, 0, 4320); //map position from degrees to steps
 
        // moving to possition
  
          if (posValue > current){
          steps = posValue - current; 
          current =current + steps;
          digitalWrite(dirpin, HIGH);
      
             for (j=0; j<steps; j++)
             {
             digitalWrite(steppin, HIGH);
             delayMicroseconds(2);
             digitalWrite(steppin, LOW);
             delayMicroseconds(i);
             if (i > 550){i=i-10;}       // accelerating stepper motor   
              }
         } 
         else if (posValue < current){
         steps = current - posValue;
         current =current - steps;
         digitalWrite(dirpin, LOW);
      
             for (j=0; j<steps; j++)
             {
             digitalWrite(steppin, HIGH);
             delayMicroseconds(2);
             digitalWrite(steppin, LOW);
             delayMicroseconds(i);
             if (i > 550){i=i-10;}     
             }        
         }
        digitalWrite(enable, HIGH);      //disabling stepper  
        delay(10);  
        possition = 0;
        }
        break;
        case 'y':
        {
        possition = constrain(possition, 0, 180);  
        Serial.print ("moving y axis to: ");
        Serial.println (possition);
        lcd.setCursor(0, 4);
        lcd.print("Y axis : ");
        lcd.print(possition);
        lcd.print("  ");
        if (pos < possition)
         {
         for(pos = pos; pos < possition; pos +=1)
          {
        myservo.write(pos);
        delay(5);
          }
         }
        if (pos > possition)
         {
         for(pos = pos; pos > possition; pos -=1)
          {
        myservo.write(pos);
        delay(5);
          }
         }
        pos = possition;
        possition = 0;  
        }        
        break;        
    }
}
}



