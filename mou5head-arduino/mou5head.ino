#include <SoftwareSerial.h>
#include "FastLED.h"

int brightness           = 96;  // デフォルトの明るさ
#define NUM_LEDS           38   // LEDの数
#define DATA_PIN           3
#define CLK_PIN            2
#define BLTSERIAL_RX       10
#define BLTSERIAL_TX       11
#define LED_TYPE           WS2801
#define COLOR_ORDER        GRB
#define FRAMES_PER_SECOND  120

SoftwareSerial bltSerial(BLTSERIAL_RX, BLTSERIAL_TX); // RX, TXポート
CRGB leds[NUM_LEDS];

void setup()
{
  delay(1000);
  
  // FastLEDの設定
  FastLED.addLeds<WS2801, DATA_PIN, CLK_PIN, RGB>(leds, NUM_LEDS);
  FastLED.setBrightness(brightness);
  
  // Arduino-PC間用シリアルポートの設定
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  // Bluetooth送受信用シリアルポートの設定
  bltSerial.begin(9600);
  bltSerial.println("Hello, world?");
}

// アニメーションパターンリスト
typedef void (*SimplePatternList[])();
SimplePatternList gPatterns = { rainbow, rainbowWithGlitter, confetti, sinelon, juggle, bpm };

uint8_t gCurrentPatternNumber = 0; // Index number of which pattern is current
uint8_t gHue = 0;                  // rotating "base color" used by many of the patterns
int     animation = 1;

void loop()
{
  if (bltSerial.available() > 0) {
    int inByte = bltSerial.read();

    switch (inByte) {
      case '1':
        flashOn();
        break;
      case '2':
        flashOff();
        break;
      case '3':
        animation = 1;
        break;
      case '4':
        animation = 1;
        nextPattern();
        break;
      case '5':
        animation = 0;
        setBlue();
        break;
      case '6':
        animation = 0;
        setRed();
        break;
      case '7':
        animation = 0;
        setGreen();
        break;
      case '8':
        animation = 0;
        setPurple();
        break;
      default:
        Serial.print(inByte);
        Serial.print('\n');
    }
  }

  if (animation == 1){
    gPatterns[gCurrentPatternNumber]();
    FastLED.show();
    FastLED.delay(1000/FRAMES_PER_SECOND);
    EVERY_N_MILLISECONDS( 20 ) { gHue++; } // slowly cycle the "base color" through the rainbow
  }
}

#define ARRAY_SIZE(A) (sizeof(A) / sizeof((A)[0]))

void nextPattern()
{
  // add one to the current pattern number, and wrap around at the end
  gCurrentPatternNumber = (gCurrentPatternNumber + 1) % ARRAY_SIZE( gPatterns);
}

void flashOn(){
  // アニメーションを止める
  animation = 0;
  // 明るくする
  for( int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CRGB(255,255,255);
  }
  FastLED.show();
}

void flashOff(){
  // アニメーションを止める
  animation = 0;
  // 暗くする
  fadeToBlackBy( leds, NUM_LEDS, 255);
  FastLED.show();
}

void setBlue(){
  // 青色をセット
  for( int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CRGB::Red;
  }
  FastLED.show();
}

void setRed(){
  // 赤色をセット
  for( int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CRGB::Blue;
  }
  FastLED.show();
}

void setGreen(){
  // 緑色をセット
  for( int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CHSV( HUE_GREEN, 255, 255);
  }
  FastLED.show();
}

void setPurple(){
  // 紫色をセット
  for( int i = 0; i < NUM_LEDS; i++) {
      leds[i] = CHSV( HUE_PURPLE, 255, 255);
  }
  FastLED.show();
}

void rainbow() 
{
  // FastLED's built-in rainbow generator
  fill_rainbow( leds, NUM_LEDS, gHue, 7);
}

void rainbowWithGlitter() 
{
  // built-in FastLED rainbow, plus some random sparkly glitter
  rainbow();
  addGlitter(80);
}

void addGlitter( fract8 chanceOfGlitter) 
{
  if( random8() < chanceOfGlitter) {
    leds[ random16(NUM_LEDS) ] += CRGB::White;
  }
}

void confetti() 
{
  // random colored speckles that blink in and fade smoothly
  fadeToBlackBy( leds, NUM_LEDS, 10);
  int pos = random16(NUM_LEDS);
  leds[pos] += CHSV( gHue + random8(64), 200, 255);
}

void sinelon()
{
  // a colored dot sweeping back and forth, with fading trails
  fadeToBlackBy( leds, NUM_LEDS, 20);
  int pos = beatsin16(13,0,NUM_LEDS);
  leds[pos] += CHSV( gHue, 255, 192);
}

void bpm()
{
  // colored stripes pulsing at a defined Beats-Per-Minute (BPM)
  uint8_t BeatsPerMinute = 62;
  CRGBPalette16 palette = PartyColors_p;
  uint8_t beat = beatsin8( BeatsPerMinute, 64, 255);
  for( int i = 0; i < NUM_LEDS; i++) { //9948
    leds[i] = ColorFromPalette(palette, gHue+(i*2), beat-gHue+(i*10));
  }
}

void juggle() {
  // eight colored dots, weaving in and out of sync with each other
  fadeToBlackBy( leds, NUM_LEDS, 20);
  byte dothue = 0;
  for( int i = 0; i < 8; i++) {
    leds[beatsin16(i+7,0,NUM_LEDS)] |= CHSV(dothue, 200, 255);
    dothue += 32;
  }
}
