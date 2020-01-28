// https://processing.org/tutorials/data/
// https://en.wikipedia.org/wiki/Web_Mercator_projection

PImage worldImg;
Table data;


void setup() {
  size(1028, 1024);

  // https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Web_maps_Mercator_projection_SW.jpg/1028px-Web_maps_Mercator_projection_SW.jpg
  worldImg = loadImage("web_mercator.jpg");
  background(worldImg);

  // https://earthquake.usgs.gov/earthquakes/feed/v1.0/csv.php
  // https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.csv
  data = loadTable("all_week.csv", "header");
  noLoop();
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
      fill(0, 255, 0);
    else if (mag < 5)
      fill(255, 255, 0);
    else
      fill(255, 0, 0);
    
    // scale magnitude for use as a radius of the circles
    mag = map(mag, 0, 9, 1, 20); 
    circle(x, y, mag);
  }
}
