// Robotics with the BOE Shield - RoamingWithWhiskers
// Go forward.  Back up and turn if whiskers indicate BOE Shield bot bumped
// into something.
//////////// Parameters  //////////////////////////////////////////////////
const int speedZero=1500;           //servo speed for zero
const int speedMax=200;             //The servo number for max
const int speedLeftIsMax=1;        //if left is higher, set to 1, else -1
const int minePin=A3;
const int debugPins[]= {5, 6, 7, 8};
//dt=1;//miliseconds
///////////////////////////////////////////////////////////////////////////
#include <Servo.h>                           // Include servo library
 
Servo servoLeft;                             // Declare left and right servos
Servo servoRight;
int currState = 1;
unsigned long time;
unsigned long dt;
unsigned long startTime;
int mineSensor;
int minePrevSensor;
unsigned long timer(boolean set = false);

void setup(){                                 // Built-in initialization block
  pinMode(7, INPUT);                         // Set right sensor pin to input
  pinMode(5, INPUT);                         // Set left sensor pin to input 
  pinMode(debugPins[0], OUTPUT); // sets up binary output one as a digital output
  pinMode(debugPins[1], OUTPUT); //and so on...
  pinMode(debugPins[2], OUTPUT);
  pinMode(debugPins[3], OUTPUT); 

  //tone(4, 3000, 1000);                       // Play tone for 1 second
  //delay(1000);                               // Delay to finish tone

  servoLeft.attach(13);                      // Attach left signal to pin 13
  servoRight.attach(12);                     // Attach right signal to pin 12
  Serial.begin(9600); 
}  
 
void loop(){
  delay(100);
  debugWrite(currState);
  //Serial.print("state = ");                     // Display "A3 = "
  Serial.println(currState);                    // Display measured A3 volts
  dt=millis()-time;
  time = millis();

  // Stuff to do everyloop
  int irLeft = irDetect(9, 10, 38000);       // Check for objects on left
  int irRight = irDetect(2, 3, 38000);       // Check for objects on right
  
  //Start of statemachine
  switch (currState){
      case 0:
        //Some init that we may need to redo here
        // for now, keep empty
        currState=1;
        break;
      case 1: 
        forward();
        currState=2;
        break;
      case 2: //idle state
          if ((irLeft == 0) && (irRight == 0)){        // If both sensors have input
            //Serial.println("both");
            backward();
            timer(true);
            currState=3;
          }else if (irLeft == 0){                        // If only left whisker contact
            //Serial.println("left");
            turnRight();
            //timer(true);
            currState=5;
          }else if (irRight == 0){                       // If only right whisker contact
            //Serial.println("right");
            turnLeft();
            //timer(true);
            currState=5;
          }else if (mineSens()){
            //Serial.println("MINE!!!");
            tone(4, 3000, 1000);
            backward();
            timer(true);
            currState=3;
          }
          break;
       case 3:
         if (timer() > 500){     // If both sensors have no input
           timer(true);
           turnLeft();
           currState=4;
         }
         break;  
      case 4:
         if (timer() > 400){     // If both sensors have no input
           currState=1;
         }
         break;  
      case 5:
         if ((irLeft == 1) && (irRight == 1)){     // If both sensors have no input
           currState=1;
         }
         break;  
    }   
}     
      
      
      

//Sets the spped, input is the speed and should be between -1 and 1
void leftWheel(int sp){ 
  servoLeft.writeMicroseconds(speedZero+(speedMax*sp)*speedLeftIsMax);
}

void rightWheel(int sp){ 
  servoRight.writeMicroseconds(speedZero-(speedMax*sp)*speedLeftIsMax);
}


void forward(){
  leftWheel(1);
  rightWheel(1);
}

void turnLeft(){
  leftWheel(-1);
  rightWheel(1);
}

void turnRight(){
  leftWheel(1);
  rightWheel(-1);                            
}

void backward(){
  leftWheel(-1);
  rightWheel(-1);
}


//If arg1 is true, the timer will be reset. else, return time in ms since last reset
              
unsigned long timer(boolean set){
  if (set) {
    startTime=time;
    return 0;
  }else{
    return time-startTime;
  }
}

int irDetect(int irLedPin, int irReceiverPin, long frequency){
  int ir;
  for(int i=0;i<10;i++){
    tone(irLedPin, frequency, 8);              
    delay(1);                                  
    ir = digitalRead(irReceiverPin);       
    delay(1);
    if(ir) break;    
  }
  return ir;   
}

boolean mineSens(){
  mineSensor=analogRead(minePin);
  if (minePrevSensor - mineSensor > 10){
    minePrevSensor=mineSensor;
    return true;
  }else{
    minePrevSensor=mineSensor;
    return false;
  }
}

void debugWrite(int n){
  
  digitalWrite(debugPins[0],(n==1 || n==3 || n==5 || n==7 || n==9)); //Write "0" to the display
  digitalWrite(debugPins[1],(n==2 || n==3 || n==6 || n==7));
  digitalWrite(debugPins[2],(n==4 || n==5 || n==6 || n==7));
  digitalWrite(debugPins[3],(n==8 || n==7));
}

