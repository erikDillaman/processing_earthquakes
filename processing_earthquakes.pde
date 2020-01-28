// https://processing.org/tutorials/data/
// https://en.wikipedia.org/wiki/Web_Mercator_projection

PImage worldImg;
Table data;


void setup() {
  size(1028, 1024);

  // https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Web_maps_Mercator_projection_SW.jpg/1028px-Web_maps_Mercator_projection_SW.jpg
  worldImg = loadImage("web_mercator.jpg");
  worldImg.loadPixels();
  for(int i = 0; i < worldImg.pixels.length; i++){
    float avg = (red(worldImg.pixels[i])+green(worldImg.pixels[i])+blue(worldImg.pixels[i]))/3;
    worldImg.pixels[i] = color(avg);
  }
  worldImg.updatePixels();
  background(worldImg);

  // https://earthquake.usgs.gov/earthquakes/feed/v1.0/csv.php
  // https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.csv
  data = loadTable("all_week.csv", "header");
  noLoop();
  noStroke();
}

void draw() {

  for (int i = 0; i < data.getRowCount(); i++) {
    TableRow row = data.getRow(i); 
    float lat = row.getFloat("latitude");
    float lon = row.getFloat("longitude");
    float mag = row.getFloat("mag");

    lat = radians(lat);
    lon = radians(lon);
    float zoom = 2; // 256 * 2 * 2 = 1024 (zoom level = 2)

    // formulas from https://en.wikipedia.org/wiki/Web_Mercator_projection
    float x = (256 / (2 * PI)) * pow(2, zoom)*(lon + PI);
    float y = (256 / (2 * PI)) * pow(2, zoom)*(PI - log(tan(PI/4 + lat/2)));

    
    // set color according to magnitude:
    // < 2.0 = green
    // < 5.0 = yellow
    // >= 5.0 = red
    if (mag < 2)
      fill(0, 255, 0, 80);
    else if (mag < 5)
      fill(255, 255, 0, 80);
    else
      fill(255, 0, 0, 80);
    
    // scale magnitude for use as a radius of the circles
    mag = mapLog(mag, 0, 9, 1, 500); 
    ellipse(x, y, mag, mag);
  }
}

float mapLog(float value, float start1, float stop1, float start2, float stop2) {
  start2 = log(start2);
  stop2 = log(stop2);
 
  float outgoing =
    exp(start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1)));
 
  String badness = null;
  if (outgoing != outgoing) {
    badness = "NaN (not a number)";
 
  } else if (outgoing == Float.NEGATIVE_INFINITY ||
             outgoing == Float.POSITIVE_INFINITY) {
    badness = "infinity";
  }
  if (badness != null) {
    final String msg =
      String.format("map(%s, %s, %s, %s, %s) called, which returns %s",
                    nf(value), nf(start1), nf(stop1),
                    nf(start2), nf(stop2), badness);
    PGraphics.showWarning(msg);
  }
  return outgoing;
}
