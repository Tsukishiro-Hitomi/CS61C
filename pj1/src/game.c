#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  // TODO: Implement this function.
  game_t* default_game = (game_t*)malloc(sizeof(game_t));

  if(default_game == NULL) {
    printf("NO ENOUGH MEMORY!");
    return NULL;
  }

  // Initialize the board
  default_game->num_rows = 18;
  int row_len = 22;
  char* row_template1 = "####################\n";
  char* row_template2 = "#                  #\n";

  default_game->board = (char**)malloc(default_game->num_rows * sizeof(char*));
  if(default_game->board == NULL) {
    printf("NO ENOUGH MEMORY!");
    return NULL;
  }

  for(size_t i = 0; i < default_game->num_rows; i++) {
    default_game->board[i] = (char*)malloc(row_len * sizeof(char));
    if(default_game->board[i] == NULL) {
      printf("NO ENOUGH MEMORY!");
      return NULL;
    }
    if(i == 0 || i == default_game->num_rows - 1) {
      strcpy(default_game->board[i], row_template1);
    } else {
      strcpy(default_game->board[i], row_template2);
    }
  }

  strcpy(default_game->board[2], "# d>D    *         #\n");

  // Initialize the snake
  default_game->num_snakes = 1;
  default_game->snakes = (snake_t*)malloc(default_game->num_snakes * sizeof(snake_t));
  snake_t* snake = &default_game->snakes[0];
  snake->tail_row = 2;
  snake->tail_col = 2;
  snake->head_row = 2;
  snake->head_col = 4;
  snake->live = true;
  return default_game;
}

/* Task 2 */
void free_game(game_t *game) {
  // TODO: Implement this function.
  for(size_t i = 0; i < game->num_rows; i++) {
    free(game->board[i]);
    game->board[i] = NULL;
  }
  free(game->board);
  game->board = NULL;

  free(game->snakes);
  game->snakes = NULL;

  free(game);
  game = NULL;
  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  // TODO: Implement this function.
  for(size_t i = 0; i < game->num_rows; i++) {
    fprintf(fp, "%s", game->board[i]);
  }
  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if(c == 'w' || c == 'a' || c == 's' || c == 'd') {
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if(c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x') {
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  if(is_head(c) || is_tail(c) || c == '^' || c == 'v' || c == '<' || c == '>') {
    return true;
  } else {
    return false;
  }
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if(c == '^') {
    return 'w';
  } else if(c == 'v') {
    return 's';
  } else if(c == '<') {
    return 'a';
  } else if(c == '>') {
    return 'd';
  }
  return '?';
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if(c == 'W') {
    return '^';
  } else if(c == 'S') {
    return 'v';
  } else if(c == 'A') {
    return '<';
  } else if(c == 'D') {
    return '>';
  }
  return '?';
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if(c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  }
  if(c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if(c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  }
  if(c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  if(snum >= game->num_snakes) {
      return '?';
  }
  snake_t* snake = &game->snakes[snum];
  unsigned int cur_col = snake->head_col;
  unsigned int cur_row = snake->head_row;

  char cur_char = get_board_at(game, cur_row, cur_col);

  unsigned int next_col = get_next_col(cur_col, cur_char);
  unsigned int next_row = get_next_row(cur_row, cur_char);

  return get_board_at(game, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  if(snum >= game->num_snakes) {
    return;
  }

  snake_t* snake = &game->snakes[snum];
  unsigned int cur_col = snake->head_col;
  unsigned int cur_row = snake->head_row;

  char head_char = get_board_at(game, cur_row, cur_col);
  char body_char = head_to_body(head_char);

  unsigned int next_col = get_next_col(cur_col, head_char);
  unsigned int next_row = get_next_row(cur_row, head_char);

  set_board_at(game, next_row, next_col, head_char);
  set_board_at(game, cur_row, cur_col, body_char);

  snake->head_row = next_row;
  snake->head_col = next_col;

  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  if(snum >= game->num_snakes) {
    return;
  }

  snake_t* snake = &game->snakes[snum];
  unsigned int cur_col = snake->tail_col;
  unsigned int cur_row = snake->tail_row;

  char cur_tail_char = get_board_at(game, cur_row, cur_col);

  unsigned int next_col = get_next_col(cur_col, cur_tail_char);
  unsigned int next_row = get_next_row(cur_row, cur_tail_char);

  char cur_body_char = get_board_at(game, next_row, next_col);
  char next_tail_char = body_to_tail(cur_body_char);

  set_board_at(game, next_row, next_col, next_tail_char);
  set_board_at(game, cur_row, cur_col, ' ');

  snake->tail_row = next_row;
  snake->tail_col = next_col;
  return;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  // TODO: Implement this function.
  for(size_t i = 0; i < game->num_snakes; i++) {
    snake_t* snake = &game->snakes[i];
    if(snake->live == false) {
      continue;
    }

    char next_char = next_square(game, i);
    unsigned int cur_row = snake->head_row;
    unsigned int cur_col = snake->head_col;

    // check head
    if(next_char == '#' || is_snake(next_char)) {
      snake->live = false;
      set_board_at(game, cur_row, cur_col, 'x');
      continue;
    }
    
    // check fruit 
    if(next_char == '*') {
      update_head(game, i);
      add_food(game);
      continue;
    }
    update_head(game, i);
    update_tail(game, i);
  }

  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  // TODO: Implement this function.
  size_t max_len = 100;
  char* newline = (char*)malloc(max_len * sizeof(char));

  if(newline == NULL) {
    printf("NO ENOUGH MEMORY!");
    return NULL;
  }

  if(fgets(newline, max_len, fp) == NULL) {
    free(newline); // important!
    return NULL;
  }

  size_t line_len = strlen(newline);
  newline = realloc(newline, line_len + 1);
  return newline;
}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  game_t* cur_game = (game_t*)malloc(sizeof(game_t));
  if(cur_game == NULL) {
    printf("NO ENOUGH MEMORY!");
    return NULL;
  }

  cur_game->num_snakes = 0;
  cur_game->snakes = NULL;

  cur_game->num_rows = 0;
  cur_game->board = NULL;
  char* line;

  while((line = read_line(fp)) != NULL) {
    cur_game->num_rows++;
    cur_game->board = realloc(cur_game->board, sizeof(char*) * cur_game->num_rows);

    if(cur_game->board == NULL) {
      printf("NO ENOUGH MEMORY!");
      return NULL;
    }

    size_t line_index = cur_game->num_rows - 1;
    cur_game->board[line_index] = line;
  }

  return cur_game;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  snake_t* snake = &game->snakes[snum];
  unsigned int tail_row = snake->tail_row;
  unsigned int tail_col = snake->tail_col;
  char tail_char = get_board_at(game, tail_row, tail_col);

  unsigned int next_row = tail_row, next_col = tail_col;

  while(!is_head(tail_char)) {
    next_row = get_next_row(next_row, tail_char);
    next_col = get_next_col(next_col, tail_char);
    tail_char = get_board_at(game, next_row, next_col);
  }
  snake->head_row = next_row;
  snake->head_col = next_col;
  return;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  // TODO: Implement this function.
  game->num_snakes = 0;
  game->snakes = NULL;

  for(size_t i = 0; i < game->num_rows; i++) {
    for(size_t j = 0; j < strlen(game->board[i]); j++) {
      char cur_char = get_board_at(game, i, j);
      if(is_tail(cur_char)) {
        game->snakes = realloc(game->snakes, (game->num_snakes + 1) * sizeof(snake_t));
        snake_t* snake = &game->snakes[game->num_snakes];
        snake->live = true;
        snake->tail_row = i;
        snake->tail_col = j;
        find_head(game, game->num_snakes);
        game->num_snakes++;
      }
    }
  }

  return game;
}
