class userInterface {
  final int size;
  final int stone_size;
  final int NONE;
  final int BLACK;
  final int WHITE;
  final float reset_button_posX;
  final float reset_button_posY;
  final float vs_button_posX;
  final float vs_button_posY;
  final float com_button_posX;
  final float com_button_posY;
  final float button_width;
  final float button_height;
  final int VS_MODE;
  final int CPU_MODE;
  int gamemode;
  int[] count;

  boolean menuResized;
  boolean decide_color;

  userInterface(int get_size, int get_stone_size, int get_none, int get_black, int get_white) {
    size = get_size;
    stone_size = get_stone_size;
    NONE = get_none;
    BLACK = get_black;
    WHITE = get_white;
    reset_button_posX = size*8 + size*0.5;
    reset_button_posY = size*5;
    vs_button_posX = size*8 + size*0.5;
    vs_button_posY = size*6;
    com_button_posX = size*8 + size*0.5;
    com_button_posY = size*7;
    button_width = size*2;
    button_height = size*0.5;
    VS_MODE = 1;
    CPU_MODE = 2;
    gamemode = VS_MODE;
    count = new int [2];
    decide_color = false;

    init();
  }

  void init() {
    menuResized = false;
  }

  void drawMenu(int[][] field, int current_color) {
    if (!menuResized) {
      // resize the main window to the size fo the image.
      surface.setSize(8*size + 3*size, 8*size);
      menuResized = true;
      return;
    }

    noStroke();
    fill(150);
    rect(8*size, 0, 3*size, 8*size);

    stoneNumber(field);
    turnColor(current_color);
    drawButton();
  }

  void highlight(int x, int y, boolean highlight, int current_color) {
    int stroke_width = 4;

    if (highlight) {
      if (current_color == BLACK) {
        stroke(0, 200);
      } else {
        stroke(255, 200);
      }
      strokeWeight(stroke_width);
      noFill();
      rect(size*x + stroke_width/2, size*y + stroke_width/2, size - stroke_width, size - stroke_width);
    }
  }

  void putHighlight() {
    if (!decide_color) {
      if (mouseX <= 8*size) {
        noStroke();
        fill(200, 200, 0, 100);
        rect(mouseX/size*size+1, mouseY/size*size+1, size-1, size-1);
      }
    }
  }

  void putHighlight_CPU(int x, int y) {
    if (!decide_color) {
      noStroke();
      fill(200, 200, 255, 100);
      rect(x*size+1, y*size+1, size-1, size-1);
    }
  }

  void turnStone(int current_color) {
    if (!decide_color) {
      noStroke();
      if (mouseX < 8*size) {
        if (current_color == BLACK) {
          fill(0, 150);
        } else {
          fill(255, 150);
        }
        ellipse(mouseX, mouseY, stone_size, stone_size);
      }
    }
  }


  void stoneNumber(int[][] field) {
    textSize(size*0.4);
    for (int n=0; n<2; n++) {
      fill(n*255);
      ellipse(size*8 + n*size*1.6 + size*0.69, size, stone_size, stone_size);
    }

    fill(200);
    text("VS", size*8 + size*0.7 + size*0.55, size*2);

    for (int n=0; n<2; n++) {
      count[n] = 0;
      for (int i=0; i<8; i++) {
        for (int j=0; j<8; j++) {
          if (field[i][j] == n+1) {
            count[n]++;
          }
        }
      }
      fill(n*255);
      text(count[n], size*8 + n*size*1.6 + size*0.45, size*2);
    }
  }

  void turnColor(int current_color) {
    if (!decide_color) {
      textSize(size*0.4);
      if (current_color==BLACK) {
        fill(0);
        text("BLACK TURN", size*8 + size*0.3, size*3);
      } else {
        fill(255);
        text("WHITE TURN", size*8 + size*0.3, size*3);
      }
    }
  }

  void drawDecideColor() {
    if (decide_color) {
      stroke(0);
      fill(180, 200, 255);
      rect(size*2 - size*0.5, size*3 - size*0.5, size*5, size*3);
      for (int i=0; i<2; i++) {
        noStroke();
        fill(i*255);
        ellipse(size*4 + size*pow(-1, i+1), size*4, stone_size, stone_size);
      }
      textSize(size*0.4);
      fill(100);
      text("Touch Stone", size*2.9, size*4 - size*0.8);
      text("You are", size*2.5, size*4 + size*1.1);
      if (dist(mouseX, mouseY, size*4 - size, size*4) <= stone_size/2) {
        fill(0);
        text("'BLACK'", size*4.2, size*4 + size*1.1);
      } else if (dist(mouseX, mouseY, size*4 + size, size*4) <= stone_size/2) {
        fill(255);
        text("'WHITE'", size*4.2, size*4 + size*1.1);
      }
    }
  }

  boolean userColor(int current_color) {
    boolean decide = true;
    if (decide_color) {
      if (dist(mouseX, mouseY, size*4 - size, size*4) <= stone_size/2) {
        decide_color = false;
        decide = true;
      } else if (dist(mouseX, mouseY, size*4 + size, size*4) <= stone_size/2) {
        decide_color = false;
        decide = false;
      }
    } else {
      if (current_color==BLACK) {
        decide = true;
      } else {
        decide = false;
      }
    }
    return decide;
  }

  void drawButton() {
    stroke(0);
    fill(180);
    rect(reset_button_posX, reset_button_posY, button_width, button_height);
    rect(vs_button_posX, vs_button_posY, button_width, button_height);
    rect(com_button_posX, com_button_posY, button_width, button_height);
    fill(0);
    textSize(size*0.3);
    text("Reset", size*8 + size*1.1, size*5.4);
    text("VS", size*8 + size*1.3, size*6.4);
    text("CPU", size*8 + size*1.2, size*7.4);
  }

  boolean pressedButton() {
    if (mouseX >= reset_button_posX && mouseX <= reset_button_posX + button_width && mouseY >= reset_button_posY && mouseY <= reset_button_posY + button_height) {
      return true;
    } else if (mouseX >= vs_button_posX && mouseX <= vs_button_posX + button_width && mouseY >= vs_button_posY && mouseY <= vs_button_posY + button_height && gamemode != VS_MODE) {
      return true;
    } else if (mouseX >= com_button_posX && mouseX <= com_button_posX + button_width && mouseY >= com_button_posY && mouseY <= com_button_posY + button_height && gamemode != CPU_MODE) {
      return true;
    } else {
      return false;
    }
  }

  void pressedEvent(int[][] field) {
    if (mouseX >= reset_button_posX && mouseX <= reset_button_posX + button_width && mouseY >= reset_button_posY && mouseY <= reset_button_posY + button_height) {
      reset(field);
      if (gamemode == CPU_MODE) {
        decide_color = true;
      }
    } else if (mouseX >= vs_button_posX && mouseX <= vs_button_posX + button_width && mouseY >= vs_button_posY && mouseY <= vs_button_posY + button_height) {
      gamemode = VS_MODE;
      reset(field);
    } else if (mouseX >= com_button_posX && mouseX <= com_button_posX + button_width && mouseY >= com_button_posY && mouseY <= com_button_posY + button_height) {
      gamemode = CPU_MODE;
      reset(field);
      decide_color = true;
    }
  }

  void reset(int[][] field) {
    for (int i=0; i<8; ++i) {
      for (int j=0; j<8; ++j) {
        field[i][j] = NONE;
      }
    }

    field[3][3] = BLACK;
    field[4][4] = BLACK;
    field[3][4] = WHITE;
    field[4][3] = WHITE;

    if (check_pass()) {
      for (int i=0; i<8; i++) {
        for (int j=0; j<8; j++) {
          highlight(i, j, highlight[i][j], BLACK);
        }
      }
    }
  }

  boolean cpu() {
    if (gamemode == CPU_MODE) {
      return true;
    } else {
      return false;
    }
  }

  void drawResult() {
    textSize(size*0.5);
    if (count[0] > count[1]) {
      fill(0);
      text("BLACK WIN", size*8 + size*0.2, size*4);
    } else if (count[0] < count[1]) {
      fill(255);
      text("WHITE WIN", size*8 + size*0.2, size*4);
    } else {
      fill(128);
      text("DRAW", size*8 + size*0.75, size*4);
    }
  }
}