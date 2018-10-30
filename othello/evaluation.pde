class evaluation {
  int[][] value;
  int[][] confirm_value;
  int[][] openness_value;
  int[][] board_value;
  int openness_count;
  final int NONE;
  final int BLACK;
  final int WHITE;

  evaluation(int get_none, int get_black, int get_white) {
    NONE = get_none;
    BLACK = get_black;
    WHITE = get_white;

    init();
  }

  void init() {
    value = new int [8][8];
    confirm_value = new int [8][8];
    openness_value = new int [8][8];
    board_value = new int [8][8];
    boardValue();
  }

  /*
  void confirmValue(int[][] field, int current_color) {
   for (int x=0; x<8; x++) {
   for (int y=0; y<8; y++) {
   if ((x==0 || x==7) &&  field[x][y]==NONE) {
   confirm_value[x][y] = confirmNextStone(field, current_color, x, y, 1, 0);
   } else if ((y==0 || y==7) &&  field[x][y]==NONE) {
   confirm_value[x][y] = confirmNextStone(field, current_color, x, y, 0, 1);
   } else {
   confirm_value[x][y] = 0;
   }
   }
   }
   }
   
   int confirmNextStone(int[][] field, int current_color, int x, int y, int next_x, int next_y) {
   int count;
   for (int i=0; i<2; i++) {
   if (!inside(x, y)) {
   
   if (field[x-((int)pow(-1, i)*next_x)][y-((int)pow(-1, i)+next_y)] == NONE) {
   } else if (field[x-((int)pow(-1, i)*next_x)][y-((int)pow(-1, i)+next_y)] != current_color) {
   }
   }
   }
   return count;
   }
   */

  void opennessValue(int[][] field, int current_color) {
    for (int x=0; x<8; x++) {
      for (int y=0; y<8; y++) {
        if (can_put_here(x, y)) {
          openness_count = 0;
          for (int i=-1; i<2; i++) {
            for (int j=-1; j<2; j++) {
              if (!(i==0 && j==0))
                if (direct[(i+1)*3+(j+1)]) {
                  checkNextStone(field, current_color, x, y, j, i);
                }
            }
          }
          openness_value[x][y] = openness_count;
        } else {
          openness_value[x][y] = 0;
        }
      }
    }
  }

  void checkNextStone(int[][] field, int current_color, int x, int y, int next_x, int next_y) {
    if (field[x + next_x][y + next_y] != current_color) {
      for (int i=-1; i<2; i++) {
        for (int j=-1; j<2; j++) {
          if (!(i==0 && j==0)) {
            if (inside(x + i, y + j)) {
              if (field[x + i][y + j] == NONE) {
                openness_count++;
              }
            }
          }
        }
      }
      checkNextStone(field, current_color, x + next_x, y + next_y, next_x, next_y);
    }
  }

  void boardValue() {
    for (int i=0; i<4; i++) {
      board_value[(7*(i%2))+((int)pow(-1, i%2)*0)][(7*(i/2))+((int)pow(-1, i/2)*0)] = 120;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*0)][(7*(i/2))+((int)pow(-1, i/2)*1)] = -20;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*0)][(7*(i/2))+((int)pow(-1, i/2)*2)] = 20;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*0)][(7*(i/2))+((int)pow(-1, i/2)*3)] = 5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*1)][(7*(i/2))+((int)pow(-1, i/2)*0)] = -20;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*1)][(7*(i/2))+((int)pow(-1, i/2)*1)] = -40;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*1)][(7*(i/2))+((int)pow(-1, i/2)*2)] = -5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*1)][(7*(i/2))+((int)pow(-1, i/2)*3)] = -5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*2)][(7*(i/2))+((int)pow(-1, i/2)*0)] = 20;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*2)][(7*(i/2))+((int)pow(-1, i/2)*1)] = -5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*2)][(7*(i/2))+((int)pow(-1, i/2)*2)] = 15;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*2)][(7*(i/2))+((int)pow(-1, i/2)*3)] = 3;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*3)][(7*(i/2))+((int)pow(-1, i/2)*0)] = 5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*3)][(7*(i/2))+((int)pow(-1, i/2)*1)] = -5;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*3)][(7*(i/2))+((int)pow(-1, i/2)*2)] = 3;
      board_value[(7*(i%2))+((int)pow(-1, i%2)*3)][(7*(i/2))+((int)pow(-1, i/2)*3)] = 3;
    }
  }

  void calculateValue(int[][] field, int current_color) {
    //confirmValue(field, current_color);
    opennessValue(field, current_color);
    for (int x=0; x<8; x++) {
      for (int y=0; y<8; y++) {
        value[x][y] = /*confirm_value[x][y]*/ - 10*openness_value[x][y] + board_value[x][y];
      }
    }
  }
}