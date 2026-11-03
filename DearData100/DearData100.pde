ArrayList<Pass> passes = new ArrayList<Pass>();
int successfulCount = 0;
int unsuccessfulCount = 0;

float graphX = 80;
float graphY = 110;
float graphW = 480;
float graphH = 480;


void setup() {
  size(1100, 660);
  loadData();
  noLoop();   // the picture never changes so draw once
}


void draw() {
  background(255);

  drawTitle();
  drawGraph();

  // Draw the green arrows first, then the red ones on top so they are easy to see
  for (int i = 0; i < passes.size(); i++) {
    if (passes.get(i).successful) {
      passes.get(i).display();
    }
  }
  for (int i = 0; i < passes.size(); i++) {
    if (!passes.get(i).successful) {
      passes.get(i).display();
    }
  }

  drawExplanation();
}


// Go through the data rows at the bottom of the file and make one Pass object for each
void loadData() {
  for (int i = 0; i < dataRows.length; i++) {
    // Each row looks like:  pass number, start x, start y, end x, end y, outcome
    String[] parts = split(dataRows[i], ',');

    int number = parseInt(parts[0]);
    float sx = parseFloat(parts[1]);
    float sy = parseFloat(parts[2]);
    float ex = parseFloat(parts[3]);
    float ey = parseFloat(parts[4]);
    boolean ok = parts[5].equals("Successful");

    passes.add(new Pass(number, sx, sy, ex, ey, ok));

    if (ok) {
      successfulCount++;
    } else {
      unsuccessfulCount++;
    }
  }
}


// On a graph, Y = 0 is at the BOTTOM, so the Y calculation counts upwards.
float toScreenX(float x) {
  return graphX + x / 100.0 * graphW;
}

float toScreenY(float y) {
  return graphY + graphH - y / 100.0 * graphH;
}


// Draw ONE arrow from (x1, y1) to (x2, y2).
// Green if the pass was successful, red if not.
void drawArrow(float x1, float y1, float x2, float y2, boolean successful) {
  if (successful) {
    stroke(40, 160, 60);
    fill(40, 160, 60);
  } else {
    stroke(220, 50, 50);
    fill(220, 50, 50);
  }

  float length = dist(x1, y1, x2, y2);

  // A pass that ended exactly where it started has no direction,
  // so draw a small ring instead of an arrow
  if (length < 3) {
    noFill();
    strokeWeight(2);
    ellipse(x1, y1, 12, 12);
    return;
  }

  // The line
  strokeWeight(1.5);
  line(x1, y1, x2, y2);

  // The dot at the start
  noStroke();
  ellipse(x1, y1, 5, 5);

  // The arrow head: a small triangle at the end, turned to face along the line
  float angle = atan2(y2 - y1, x2 - x1);
  float head = min(10, length);
  pushMatrix();
  translate(x2, y2);
  rotate(angle);
  triangle(0, 0, -head, -head * 0.45, -head, head * 0.45);
  popMatrix();
}


void drawTitle() {
  fill(0);
  noStroke();
  textAlign(LEFT, TOP);
  textSize(28);
  text("Direction of my 100 football passes", 80, 20);
  textSize(15);
  text("Each arrow starts where a pass started and points to where it ended.", 80, 62);
}


// The gri the axis numbers and the axis names
void drawGraph() {
  // Light grid lines and numbers at 0, 25, 50, 75, 100
  for (int v = 0; v <= 100; v += 25) {
    stroke(220);
    strokeWeight(1);
    line(toScreenX(v), graphY, toScreenX(v), graphY + graphH);   // up-and-down line
    line(graphX, toScreenY(v), graphX + graphW, toScreenY(v));   // across line

    fill(0);
    noStroke();
    textSize(13);
    textAlign(CENTER, TOP);
    text(v, toScreenX(v), graphY + graphH + 8);
    textAlign(RIGHT, CENTER);
    text(v, graphX - 10, toScreenY(v));
  }

  // The border of the graph
  noFill();
  stroke(0);
  strokeWeight(2);
  rect(graphX, graphY, graphW, graphH);

  // Axis names
  fill(0);
  noStroke();
  textSize(15);
  textAlign(CENTER, TOP);
  text("X (0 - 100): along the length of the pitch", graphX + graphW / 2, graphY + graphH + 30);
  textAlign(LEFT, BOTTOM);
  text("Y (0 - 100): across the width of the pitch", graphX - 40, graphY - 12);
}


// The text on the right that explains the data
void drawExplanation() {
  float x = 620;
  float y = 110;

  fill(0);
  noStroke();
  textAlign(LEFT, CENTER);

  textSize(20);
  text("About this data", x, y);
  y += 32;

  textSize(15);
  text("The data has 100 football passes.", x, y);
  y += 22;
  text("For each pass I have its start and end position on", x, y);
  y += 22;
  text("a 0 - 100 grid of the pitch, and whether it worked.", x, y);
  y += 34;

  textSize(20);
  text("How to read the graph", x, y);
  y += 32;

  textSize(15);
  text("One arrow = one pass.", x, y);
  y += 22;
  text("The dot at the tail is where the pass started.", x, y);
  y += 22;
  text("The arrow head points to where the pass ended.", x, y);
  y += 22;
  text("A longer arrow = a longer pass.", x, y);
  y += 34;

  textSize(20);
  text("Key", x, y);
  y += 34;

  textSize(15);
  drawArrow(x, y, x + 60, y, true);
  fill(0);
  text("Green arrow = successful pass", x + 80, y);
  y += 32;

  drawArrow(x, y, x + 60, y, false);
  fill(0);
  text("Red arrow = unsuccessful pass", x + 80, y);
  y += 32;

  drawArrow(x + 30, y, x + 30, y, true);
  fill(0);
  text("Small ring = pass that ended where it started", x + 80, y);
  y += 44;

  // Numbers (the success rate is worked out here)
  float rate = 100.0 * successfulCount / passes.size();

  textSize(20);
  text("Totals", x, y);
  y += 32;

  textSize(15);
  text("Total passes: " + passes.size(), x, y);
  y += 22;
  text("Successful: " + successfulCount, x, y);
  y += 22;
  text("Unsuccessful: " + unsuccessfulCount, x, y);
  y += 22;
  text("Success rate: " + nf(rate, 0, 1) + "%", x, y);
}


// One Pass object = one pass from the spreadsheet
class Pass {
  int number;
  float startX, startY;
  float endX, endY;
  boolean successful;

  Pass(int number, float startX, float startY, float endX, float endY, boolean successful) {
    this.number = number;
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    this.successful = successful;
  }

  // Draw this pass as an arrow from its start to its end
  void display() {
    drawArrow(toScreenX(startX), toScreenY(startY), toScreenX(endX), toScreenY(endY), successful);
  }
}



String[] dataRows = {
  "1,86,19,79,14,Successful",
  "2,18,91,22,71,Successful",
  "3,9,8,2,12,Successful",
  "4,76,30,90,39,Successful",
  "5,62,80,74,68,Successful",
  "6,25,94,18,86,Successful",
  "7,48,18,36,17,Unsuccessful",
  "8,82,38,98,42,Successful",
  "9,53,15,76,30,Successful",
  "10,51,78,38,67,Successful",
  "11,42,15,4,23,Successful",
  "12,86,51,82,45,Successful",
  "13,94,92,98,98,Successful",
  "14,36,25,29,33,Successful",
  "15,33,92,42,98,Successful",
  "16,9,45,2,39,Unsuccessful",
  "17,77,45,77,45,Unsuccessful",
  "18,87,63,76,58,Successful",
  "19,73,38,70,50,Successful",
  "20,33,22,8,45,Successful",
  "21,19,24,39,42,Successful",
  "22,13,54,12,58,Successful",
  "23,75,6,52,24,Unsuccessful",
  "24,39,87,33,88,Successful",
  "25,5,38,52,20,Successful",
  "26,18,85,23,89,Successful",
  "27,24,52,28,76,Unsuccessful",
  "28,5,81,2,72,Unsuccessful",
  "29,44,35,57,41,Unsuccessful",
  "30,15,67,33,76,Successful",
  "31,21,89,23,82,Successful",
  "32,82,59,98,44,Successful",
  "33,56,90,54,98,Successful",
  "34,36,33,21,39,Successful",
  "35,80,33,87,41,Successful",
  "36,13,9,2,34,Successful",
  "37,90,67,79,78,Unsuccessful",
  "38,78,78,88,81,Unsuccessful",
  "39,29,17,27,16,Successful",
  "40,64,11,75,2,Successful",
  "41,48,18,39,23,Successful",
  "42,59,28,51,18,Successful",
  "43,75,17,77,5,Unsuccessful",
  "44,35,26,35,20,Unsuccessful",
  "45,12,26,9,22,Unsuccessful",
  "46,63,41,78,52,Unsuccessful",
  "47,76,89,55,76,Successful",
  "48,12,79,2,98,Successful",
  "49,11,79,25,83,Successful",
  "50,70,15,28,51,Successful",
  "51,35,56,48,62,Successful",
  "52,81,10,77,27,Successful",
  "53,71,45,47,45,Successful",
  "54,55,21,44,25,Successful",
  "55,14,6,17,2,Successful",
  "56,32,69,46,68,Unsuccessful",
  "57,36,52,35,57,Successful",
  "58,83,88,95,98,Successful",
  "59,89,18,56,11,Successful",
  "60,18,75,12,82,Successful",
  "61,48,31,72,22,Successful",
  "62,37,11,35,7,Successful",
  "63,47,21,33,6,Successful",
  "64,75,95,60,86,Successful",
  "65,93,24,98,22,Successful",
  "66,23,60,17,59,Unsuccessful",
  "67,10,50,2,59,Successful",
  "68,76,57,98,36,Unsuccessful",
  "69,35,25,7,37,Successful",
  "70,47,57,72,79,Unsuccessful",
  "71,39,25,15,24,Unsuccessful",
  "72,65,33,79,35,Successful",
  "73,34,33,25,33,Successful",
  "74,13,40,14,40,Successful",
  "75,73,47,37,40,Successful",
  "76,38,9,36,8,Successful",
  "77,45,60,47,42,Successful",
  "78,78,29,85,30,Successful",
  "79,73,92,90,98,Successful",
  "80,51,60,57,58,Successful",
  "81,89,20,78,27,Successful",
  "82,57,46,51,51,Successful",
  "83,58,90,94,72,Successful",
  "84,43,56,13,50,Successful",
  "85,60,79,50,83,Successful",
  "86,91,32,98,57,Successful",
  "87,89,15,95,23,Successful",
  "88,16,35,2,22,Successful",
  "89,10,36,38,5,Successful",
  "90,85,78,92,78,Successful",
  "91,36,23,6,46,Unsuccessful",
  "92,18,59,28,69,Successful",
  "93,11,76,23,67,Successful",
  "94,64,90,69,98,Successful",
  "95,61,83,88,90,Successful",
  "96,75,62,98,82,Successful",
  "97,36,86,45,90,Successful",
  "98,35,40,42,37,Successful",
  "99,47,45,7,22,Successful",
  "100,54,93,45,83,Successful"
};
