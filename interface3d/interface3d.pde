boolean click=false;
boolean move=false;
boolean bar=false;
float conX, conY, moveX, moveY, rotX, rotY, barY, chY, sca;

void setup() {
  size(400, 300, P3D);
  conX = 110;
  conY = 220;
  rotX = 230;
  rotY = 120;
  barY = 25;
}

void draw() {
  background(240);

  perspective();
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateY(rotX);
  rotateX(rotY);
  scale( sca );
  if ( click == false ) {
    fill(255, 190, 0);
    box(80);
  } else {
    fill( 150, 255, 100 );
    sphere( 60 );
  }
  popMatrix();

  ortho();
  pushMatrix();

  if ( move == false ) {
    fill( 0 );
    text( "return the controller : R", 250, 20 );
  }

  stroke( 0 );
  fill( 220 );
  rect( conX, conY, 180, 60 );
  if ( click == false ) {
    fill(255, 0, 0);
  } else {
    fill(120);
  }
  ellipse(conX+40, conY+30, 50, 50);
  stroke( 255 );
  noFill();
  rect( conX+30, conY+20, 20, 20 );
  
  stroke( 0 );
  if ( click == false ) {
    fill(120);
  } else {
    fill(255, 0, 0);
  }
  ellipse(conX+140, conY+30, 50, 50);
  stroke( 255 );
  noFill();
  ellipse( conX+140, conY+30, 25, 25 );

  stroke( 0 );
  line( conX+90, conY+10, conX+90, conY+50 );
  fill( 200 );
  rect( conX+80, conY+barY, 20, 10 );
  popMatrix();

  if ( move == true ) {
    conX = mouseX + moveX;
    conY = mouseY + moveY;
  }
  if ( bar == true ) {
    barY = mouseY+chY;
  }

  if ( barY < 5 ) {
    barY = 5;
  } else if ( barY > 45 ) {
    barY = 45;
  }
  sca = barY/25;
}

void mousePressed() {
  if ( mouseX >= conX && mouseX <= conX+180 && mouseY >= conY && mouseY <= conY+60 ) {
    if ( mouseX >= conX+80 && mouseX <= conX+100 && mouseY >= conY+barY && mouseY <= conY+barY+10 ) {
      bar = true;
      chY = barY-mouseY;
    } else {
      move = true;
      moveX = conX-mouseX;
      moveY = conY-mouseY;
    }
    if ( dist( mouseX, mouseY, conX+40, conY+30 ) <= 25 ) {
      click = false;
    } else if ( dist( mouseX, mouseY, conX+140, conY+30 ) <= 25 ) {
      click = true;
    }
  }
}

void mouseReleased() {
  move = false;
  bar = false;
}

void mouseMoved() {
  if ( ( mouseX >= conX && mouseX <= conX+180 && mouseY >= conY && mouseY <= conY+60 ) == false ) {
    rotX += ( mouseX - pmouseX )*0.01;
    rotY -= ( mouseY - pmouseY )*0.01;
  }
}

void keyPressed() {
  if ( key == 'r' || key == 'R' ) {
    conX = 110;
    conY = 220;
  }
}

