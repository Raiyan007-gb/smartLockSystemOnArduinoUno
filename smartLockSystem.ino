#include <Adafruit_Fingerprint.h>
#include <SPI.h>
#include <MFRC522.h>
#include <AltSoftSerial.h>
#include <SoftwareSerial.h>

#define SS_PIN 10
#define RST_PIN 14
#define card "83 E9 DF A9"
#define tag "AC 34 F5 38"
#define password "879065"
#define meetingOn "67895"
#define meetingOff "23456"
#define removeFingerprints "-1"
#define unlock "0"
#define lock "1"
#define RELAY_PIN 4
#define ACCESS_DELAY 3500  // Keep lock unlocked for 3 seconds
#define buzzer 15

boolean authenticated = false;
boolean meetingMode = false;
uint8_t id;
boolean idFound = false;
MFRC522 mfrc522(SS_PIN, RST_PIN);
SoftwareSerial mySerial(2, 3);
AltSoftSerial BTSerial;
Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);


void setup() {
  // set the data rate for the sensor serial port
  Serial.begin(9600);  // Initiate a serial communication
  while (!Serial)
    ;
  BTSerial.begin(9600);
  SPI.begin();         // Initiate  SPI bus
  mfrc522.PCD_Init();  // Initiate MFRC522
  Serial.println("Approximate your card to the reader...");
  Serial.println();
  Serial.println("Bluetooth communication initialized.");
  finger.begin(57600);
  delay(5);
  if (finger.verifyPassword()) {
    Serial.println("Found fingerprint sensor!");
  } else {
    Serial.println("Did not find fingerprint sensor :(");
    while (1) { delay(1); }
  }

  pinMode(RELAY_PIN, OUTPUT);
  pinMode(7, OUTPUT);  //red led
  pinMode(6, OUTPUT);  //green led
  pinMode(buzzer, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH);
  //Switch off relay initially. Relay is LOW level triggered relay so we need to write HIGH.
  Serial.println(F("Reading sensor parameters"));
  finger.getParameters();
  finger.getTemplateCount();
  Serial.print(F("Status: 0x"));
  Serial.println(finger.status_reg, HEX);
  Serial.print(F("Sys ID: 0x"));
  Serial.println(finger.system_id, HEX);
  Serial.print(F("Capacity: "));
  Serial.println(finger.capacity);
  Serial.print(F("Security level: "));
  Serial.println(finger.security_level);
  Serial.print(F("Device address: "));
  Serial.println(finger.device_addr, HEX);
  Serial.print(F("Packet len: "));
  Serial.println(finger.packet_len);
  Serial.print(F("Baud rate: "));
  Serial.println(finger.baud_rate);
  Serial.print(F("Total finger prints stored: "));
  Serial.println(finger.templateCount);
}

uint8_t readnumber(void) {
  uint8_t num = 0;

  while (num == 0) {
    while (!Serial.available())
      ;
    num = Serial.parseInt();
  }
  return num;
}

void loop() {
  if (Serial.available() > 0) {
    String input_password = Serial.readStringUntil('\n');
    input_password.trim();
    if (input_password == meetingOn) {
      meetingMode = true;
      Serial.println("Meeting Mode Is On");
    } else if (input_password == password) {
      authenticated = true;
      Serial.println("Password is correct.");
    } else if (input_password == meetingOff) {
      meetingMode = false;
      Serial.println("Meeting Mode Is Of You Can Enter The ROOM!!");
    } else if(input_password == removeFingerprints) {
      Serial.println("Cleared all finger prints from database");
      finger.emptyDatabase();
      return;
    }else {
      Serial.println("Incorrect Attemt!!I am watching You");
    }
  }
  if (BTSerial.available() > 0) {
    String bt_password = BTSerial.readStringUntil('\n');
    bt_password.trim();

    Serial.println();
    if (bt_password == meetingOn) {
      digitalWrite(buzzer, HIGH);
      delay(1000);
      digitalWrite(buzzer, LOW);
      meetingMode = true;
      Serial.println("Meeting Mode Is On");
    } else if (bt_password == password) {
      authenticated = true;
      Serial.println("Password is correct.");
    } else if (bt_password == meetingOff) {
      tone(buzzer, 31, 700);
      meetingMode = false;
      Serial.println("Meeting Mode Is Off You Can Enter The ROOM!!");
    } else if (bt_password == unlock) {
      digitalWrite(RELAY_PIN, LOW);
      tone(buzzer, 31, 700);
      digitalWrite(6, HIGH);
      Serial.println("You can enter the room!!!");
    } else if (bt_password == lock) {
      digitalWrite(RELAY_PIN, HIGH);
      digitalWrite(6, LOW);
      Serial.println("The door is locked");
    } else if(bt_password == removeFingerprints) {
      Serial.println("Cleared all finger prints from database");
      finger.emptyDatabase();
      return;
    } else {
      Serial.println();
      Serial.println("Inavalid request.");
      BTSerial.println("!!I am watching You");
    }
  }


  if (!meetingMode) {

    if (authenticated) {
      Serial.println("\n\nReady to enroll a fingerprint!");
      Serial.println("Please type in -1 to delete all the stored finger prints...");
      Serial.println("Please type in the ID # (from 1 to 127) you want to save the finger as...");
      id = random(1, 128);
      if (id == 0)  // ID #0 not allowed, try again!
      {
        return;
      }
      if (id == uint8_t(-1)) {
        Serial.print("Cleared all finger prints from database");
        finger.emptyDatabase();
        return;
      }

      Serial.print("Enrolling ID #");
      Serial.println(id);
      while (!getFingerprintEnroll())
        ;
      authenticated = false;
    } else {

      digitalWrite(7, HIGH);  // turn the LED on (HIGH is the voltage level)
      delay(10);              // wait for a second
      digitalWrite(7, LOW);   // turn the LED off by making the voltage LOW
                              // wait for a second
                              // Bluetooth communication
      // if (BTSerial.available() >0) {
      //   char c = BTSerial.read();
      //   Serial.write(c);
      //   Serial.println();
      //   if (c == '1') {
      //     digitalWrite(RELAY_PIN, LOW);
      //     tone(buzzer, 31, 700);
      //     digitalWrite(6, HIGH);
      //   } else if (c == '0') {
      //     digitalWrite(RELAY_PIN, HIGH);
      //     digitalWrite(6, LOW);
      //   } else {
      //     Serial.println();
      //     Serial.println("Inavalid request.");
      //   }
      // }
      if (getFingerPrint() != -1) {
        Serial.println("Authorized access");
        tone(buzzer, 31, 700);
        digitalWrite(6, HIGH);
        digitalWrite(RELAY_PIN, LOW);
        delay(ACCESS_DELAY);
        digitalWrite(RELAY_PIN, HIGH);
        noTone(buzzer);
        digitalWrite(6, LOW);
      }

      //Add some delay before next scan.
      // Look for new cards
      if (!mfrc522.PICC_IsNewCardPresent()) {
        return;
      }
      // Select one of the cards
      if (!mfrc522.PICC_ReadCardSerial()) {
        return;
      }
      //Show UID on serial monitor
      Serial.print("UID tag :");
      String content = "";
      byte letter;
      for (byte i = 0; i < mfrc522.uid.size; i++) {
        Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
        Serial.print(mfrc522.uid.uidByte[i], HEX);
        content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
        content.concat(String(mfrc522.uid.uidByte[i], HEX));
      }
      Serial.println();
      Serial.print("Message : ");
      content.toUpperCase();
      if (content.substring(1) == card)  //change here the UID of the card/cards that you want to give access
      {
        Serial.println("Authorized access to this card");
        Serial.println();
        tone(buzzer, 31, 700);
        digitalWrite(6, HIGH);
        digitalWrite(RELAY_PIN, LOW);
        delay(ACCESS_DELAY);
        digitalWrite(RELAY_PIN, HIGH);
        noTone(buzzer);
        digitalWrite(6, LOW);
      } else if (content.substring(1) == tag) {
        Serial.println("Authorized access to this tag");
        Serial.println();
        tone(buzzer, 31, 700);
        digitalWrite(6, HIGH);
        digitalWrite(RELAY_PIN, LOW);
        delay(ACCESS_DELAY);
        digitalWrite(RELAY_PIN, HIGH);
        noTone(buzzer);
        digitalWrite(6, LOW);
      } else {
        Serial.println(" Access denied");
        delay(100);
      }
      delay(35);
    }
  }
}


// returns -1 if failed, otherwise returns ID #
int getFingerPrint() {
  int p = finger.getImage();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.image2Tz();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.fingerFastSearch();
  if (p != FINGERPRINT_OK) {
    digitalWrite(buzzer, HIGH);  // turn on the buzzer
    digitalWrite(7, HIGH);
    delay(1500);                // wait for half a second
    digitalWrite(buzzer, LOW);  // turn off the buzzer
    digitalWrite(7, LOW);
    Serial.println("Fingerprint not found");
    return -1;
  }


  // found a match!
  return finger.fingerID;
}

// from here below codes are only for enrolling new fingerprint
uint8_t getFingerprintEnroll() {

  int p = -1;
  Serial.print("Waiting for valid finger to enroll as #");
  Serial.println(id);
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
        Serial.println("Image taken");
        break;
      case FINGERPRINT_NOFINGER:
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        Serial.println("Communication error");
        break;
      case FINGERPRINT_IMAGEFAIL:
        Serial.println("Imaging error");
        break;
      default:
        Serial.println("Unknown error");
        break;
    }
  }

  // OK success!

  p = finger.image2Tz(1);
  switch (p) {
    case FINGERPRINT_OK:
      Serial.println("Image converted");
      break;
    case FINGERPRINT_IMAGEMESS:
      Serial.println("Image too messy");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      Serial.println("Communication error");
      return p;
    case FINGERPRINT_FEATUREFAIL:
      Serial.println("Could not find fingerprint features");
      return p;
    case FINGERPRINT_INVALIDIMAGE:
      Serial.println("Could not find fingerprint features");
      return p;
    default:
      Serial.println("Unknown error");
      return p;
  }

  Serial.println("Remove finger");
  digitalWrite(6, HIGH);
  delay(2000);
  digitalWrite(6, LOW);
  p = 0;
  while (p != FINGERPRINT_NOFINGER) {
    p = finger.getImage();
  }
  Serial.print("ID ");
  Serial.println(id);
  p = -1;
  Serial.println("Place same finger again");
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
        Serial.println("Image taken");
        break;
      case FINGERPRINT_NOFINGER:
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        Serial.println("Communication error");
        break;
      case FINGERPRINT_IMAGEFAIL:
        Serial.println("Imaging error");
        break;
      default:
        Serial.println("Unknown error");
        break;
    }
  }

  // OK success!

  p = finger.image2Tz(2);
  switch (p) {
    case FINGERPRINT_OK:
      Serial.println("Image converted");
      break;
    case FINGERPRINT_IMAGEMESS:
      Serial.println("Image too messy");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      Serial.println("Communication error");
      return p;
    case FINGERPRINT_FEATUREFAIL:
      Serial.println("Could not find fingerprint features");
      return p;
    case FINGERPRINT_INVALIDIMAGE:
      Serial.println("Could not find fingerprint features");
      return p;
    default:
      Serial.println("Unknown error");
      return p;
  }

  // OK converted!
  Serial.print("Creating model for #");
  Serial.println(id);

  p = finger.createModel();
  if (p == FINGERPRINT_OK) {
    Serial.println("Prints matched!");
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
    Serial.println("Communication error");
    return p;
  } else if (p == FINGERPRINT_ENROLLMISMATCH) {
    Serial.println("Fingerprints did not match");
    return p;
  } else {
    Serial.println("Unknown error");
    return p;
  }

  Serial.print("ID ");
  Serial.println(id);
  p = finger.storeModel(id);
  if (p == FINGERPRINT_OK) {
    Serial.println("Stored!");
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
    Serial.println("Communication error");
    return p;
  } else if (p == FINGERPRINT_BADLOCATION) {
    Serial.println("Could not store in that location");
    return p;
  } else if (p == FINGERPRINT_FLASHERR) {
    Serial.println("Error writing to flash");
    return p;
  } else {
    Serial.println("Unknown error");
    return p;
  }

  return true;
}
//there will be app which will be protected via passcode
//there will be a option to enroll fingerpint with passcode then 1-7 user option
// if matches fingerpint door auto unlock else locked and beep also same for rfid
//with valid passcode we will able to unlock and lock the door
//meeting mode on and off