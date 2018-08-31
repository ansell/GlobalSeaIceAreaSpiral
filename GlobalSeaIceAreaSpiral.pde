import java.time.*;
import com.hamoid.*;

VideoExport videoExport;

StringList _seaIceData;
StringDict _tempData = new StringDict();
int _frameCount = 0;
int _lineCount = 0;
PFont _font;
color purple = color(127, 0, 127);
color red = color(255, 255, 0);
int _width = 1000;
int _height = 1000;
int _halfWidth = _width/2;
int _halfHeight = _height/2;


boolean _drawLine = false;
boolean _drawRecordLow = false;
int _lastX = 0;
int _lastY = 0;
int _lastXNH = 0;
int _lastYNH = 0;
int _lastXSH = 0;
int _lastYSH = 0;
int _skip = 10;
float _currentLow = Float.MAX_VALUE;


color _coolColor = color(0, 0,255);
color _warmColor = color(255,0,0);


void setup() { //<>//
	size(1000, 1000);
  strokeWeight(4);
  loadTempData();
  
  frameRate(30);
    
	_seaIceData = filterFile();

    
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(30);
  videoExport.startMovie();
}

void drawBackground()
{
  background(100);
  
  
  strokeCap(SQUARE);
  
  noStroke();
  fill(70,0,70);
  ellipse(_halfWidth, _halfHeight, 850, 850);
  
  
  fill(60,0,60);
  noStroke();
  ellipse(_halfWidth, _halfHeight, 17.8 * 20 * 2, 17.8 * 20 * 2);
  fill(70,0,70);
  ellipse(_halfWidth, _halfHeight, 17.8 * 15 * 2, 17.8 * 15 * 2);
  fill(60,0,60);
  ellipse(_halfWidth, _halfHeight, 17.8 * 10 * 2, 17.8 * 10 * 2);
  fill(70,0,70);
  ellipse(_halfWidth, _halfHeight, 17.8 *  5 * 2, 17.8 *  5 * 2);
  
  fill(255,255,255);
  ellipse(_halfWidth, _halfHeight, 17.8 * .2 * 2, 17.8 * .2 * 2);
  
  fill(255);
  textSize(15);
  text("20M Km²",_halfWidth - 30, _halfHeight - 17.8 * 20 + 20);
  text("15M Km²",_halfWidth - 30, _halfHeight - 17.8 * 15 + 20);
  text("10M Km²",_halfWidth - 30, _halfHeight - 17.8 * 10 + 20);
  
  text("Arctic", 600, 400);
  text("Antarctic", 300, 600);
  
  pushStyle();
    textSize(30);
    text("Global Sea Ice Area\n1978 - 2018", 10, 40);
    textAlign(RIGHT);
    text("@kevpluck", width-15, height-65);
    textSize(20);
    text("PixelMoversAndMakers.com", width-15, height - 35);
    textAlign(CENTER);
    textSize(11);
    text("Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS Passive Microwave Data (NSIDC-0051), Near-Real-Time DMSP SSMIS Daily Polar Gridded Sea Ice Concentrations", width/2, _height - 12);
  popStyle();
  
  textSize(32);
  makeClock();
  
  pushStyle();
    textAlign(RIGHT);
    textSize(15);
    text("Global temperature anomaly\n(NASA GISS)", width-90,20);
    //text("-0.09", width-25, 210);
    text(" 0.0°C", width-15, 210-200*(0.00+0.09)/(1.34+0.09));
    text(" 0.5°C", width-15, 210-200*(0.50+0.09)/(1.34+0.09));
    text(" 1.0°C", width-15, 210-200*(1.00+0.09)/(1.34+0.09));
  popStyle();
  for(int i=0; i < 200; i++){
    color lerpColor = lerpColor(_coolColor, _warmColor, ((float)i)/200);
    stroke(lerpColor);
    line(width-80, 210-i, width-60, 210-i);
  }
  
}

  
int _end = 0;
int _year = 0;
float _angleOfRecord = 0.0;
int _yearOfRecord = 1979;
int _endPauseFrameCount = 0;
void draw(){ //<>//
  drawBackground();
  
  if(_frameCount < _lineCount) {
    _end = (_frameCount++ * _skip) + _skip;
    _year = 0;
  }
  else
  {
    _endPauseFrameCount++;
  };
  
  
  for(int c = 2; c < _end; c++)
  {
    String[] seaIceDatum = split(_seaIceData.get(c), ',');
    
    String[] dateTime = split(seaIceDatum[0], '-');
    
    
    _year = int(dateTime[0]);
    int yearDay = int(trim(split(seaIceDatum[1],'.')[0]));
    
    if(_year>2015 && yearDay > 250 && _skip>1) 
    {
      _frameCount = _end;
      _skip = 1;
    }
    
    int daysInYear = 365;
        
    float area = float(seaIceDatum[3]) + float(seaIceDatum[5]);
    float areaNH = float(seaIceDatum[3]);
    float areaSH = float(seaIceDatum[5]);
    
    
    if(_year % 4 == 0) daysInYear = 366;
    
    int x = int(18 * area * cos(TWO_PI *  yearDay/daysInYear - HALF_PI));
    int y = int(18 * area * sin(TWO_PI *  yearDay/daysInYear - HALF_PI));
    
    int xNH = int(18 * areaNH * cos(TWO_PI *  yearDay/daysInYear - HALF_PI));
    int yNH = int(18 * areaNH * sin(TWO_PI *  yearDay/daysInYear - HALF_PI));
    
    int xSH = int(18 * areaSH * cos(TWO_PI *  yearDay/daysInYear - HALF_PI));
    int ySH = int(18 * areaSH * sin(TWO_PI *  yearDay/daysInYear - HALF_PI));
    
    if(x==0 && y==0)
    {
      _drawLine = false;
      continue;
    }
    
    if(_drawLine)
    {
      
      float temp = getTempData(_year, yearDay);
      color lerpColor = lerpColor(_coolColor, _warmColor, (temp+0.09)/(1.34+0.09));
            
      stroke(lerpColor);
      drawGlobal(x,y);
      
      stroke(255,255,255,16);
      drawNH(xNH,yNH);
      drawSH(xSH,ySH);
      
      int distanceFromEnd = _end - c;
      if(distanceFromEnd < 25)
      {  
        for(int count = 0; count < (25 - distanceFromEnd); count++)
        {
          drawGlobal(x,y);
          drawNH(xNH,yNH);
          drawSH(xSH,ySH);
        }
      } //<>//
    }
    
    _lastX = x;
    _lastY = y;
    _lastXNH = xNH;
    _lastYNH = yNH;
    _lastXSH = xSH;
    _lastYSH = ySH;
    _drawLine = true;
    
    
    if(area < _currentLow)
    {
      _currentLow = area;
      _angleOfRecord = TWO_PI *  yearDay/daysInYear;
      _yearOfRecord = _year;
      if(yearDay > 30 && yearDay < 180)
      {        
        _drawRecordLow = true;
      }
    }
  }
    
  
  if(_drawRecordLow)
  {
    pushStyle();
      textAlign(CENTER);
      noFill();
      stroke(90,0,90);
      strokeWeight(4);
      //ellipse(_halfWidth, _halfHeight, 17.7 * _currentLow * 2, 17.7 * _currentLow * 2);
      fill(255);
      textSize(15);
      
      translate(_halfWidth, _halfHeight);
      rotate(_angleOfRecord);
      stroke(255);
      line(0, - 16 * _currentLow - 15, 0, - 16 * _currentLow - 25);
      text(String.format("%.1fM Km²\n%d", _currentLow, _yearOfRecord), 0 , - 16 * _currentLow);
      rotate(-_angleOfRecord);
        
      translate(-_halfWidth, -_halfHeight);
    popStyle();
  }
  
  stroke(255,255,255,48);
  strokeWeight(1);
  line(500,500,_lastX+500,_lastY+500);
  
  textSize(32);
  stroke(255);
  fill(255);
  text(_year, 460, 120);
  _drawLine = false;
  videoExport.saveFrame();
  
  if(_endPauseFrameCount > 210){
    videoExport.endMovie();
    exit();
  }
    
}

void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
}

void drawGlobal(int x, int y){
  strokeCap(ROUND);
  strokeWeight(4);
  line(500 + _lastX, 500 + _lastY, 500 + x, 500 + y);
}

void drawNH(int xNH, int yNH){
  strokeCap(SQUARE);
  strokeWeight(2);
  line(500 + _lastXNH, 500 + _lastYNH, 500 + xNH, 500 + yNH);
}

void drawSH(int xSH, int ySH){
  strokeCap(SQUARE);
  strokeWeight(2);
  line(500 + _lastXSH, 500 + _lastYSH, 500 + xSH, 500 + ySH);
}

StringList filterFile()
{
	StringList toReturn = new StringList();
  String[] lines = loadStrings("nsidc_NH_SH_nt_final_and_nrt.txt");
  
	for (String line : lines) {
	  if(line.charAt(0) == '#' || line.charAt(0) == ' ') continue;
    _lineCount++;
	  toReturn.append(line);
	}

	return toReturn;
}

public static LocalDate GetNonLeapYear()
{
  return LocalDate.of(2001,1,1);
}

public float getTempData(int year, int dayOfYear)
{
  if(dayOfYear>365) dayOfYear = 365;
  LocalDate dt = GetNonLeapYear().withDayOfYear(dayOfYear);
  int month = dt.getMonthValue();
  if(year>=2018) 
  {
    year = 2017;
    month = 12;
  }
  return parseFloat(_tempData.get(year + "/" + month));
}

void loadTempData()
{
  String[] lines = loadStrings("GLB.Ts+dSST.csv");
  
  for (String line : lines) {
    if(line.charAt(0) == 'L' || line.charAt(0) == 'Y') continue;
    
    String[] values = split(line, ',');
    String year = values[0];
    for(int month = 1;month<=12;month++)
    {
      _tempData.set(year + "/" +month, values[month]);
    }
    
    
  }
}

void makeClock(){
  
  translate(_halfWidth, _halfHeight);
  
  text("Jan", -25, -450);
  rotate(PI/6);
  text("Feb", -25, -450);
  rotate(PI/6);
  text("Mar", -25, -450);
  rotate(PI/6);
  text("Apr", -25, -450);
  rotate(PI/6);
  text("May", -25, -450);
  rotate(PI/6);
  text("Jun", -25, -450);
  rotate(PI/6);
  text("Jul", -25, -450);
  rotate(PI/6);
  text("Aug", -25, -450);
  rotate(PI/6);
  text("Sep", -25, -450);
  rotate(PI/6);
  text("Oct", -25, -450);
  rotate(PI/6);
  text("Nov", -25, -450);
  rotate(PI/6);
  text("Dec", -25, -450);
  rotate(PI/6);
  
  translate(-_halfWidth, -_halfHeight);
}