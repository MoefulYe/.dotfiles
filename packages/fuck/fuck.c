#define _XOPEN_SOURCE_EXTENDED 1

#include <locale.h>
#include <math.h>
#include <ncursesw/curses.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wchar.h>

enum {
  PAL_BLACK = 0,
  PAL_WHITE,
  PAL_YELLOW,
  PAL_RED,
  PAL_MAGENTA,
  PAL_BLUE,
  PAL_CYAN,
  PAL_GREEN,
  PAL_COUNT
};

#define GLYPH_FULL L'\u2588'
#define GLYPH_DARK L'\u2593'
#define GLYPH_MEDIUM L'\u2592'
#define GLYPH_LIGHT L'\u2591'
#define GLYPH_UPPER L'\u2580'
#define GLYPH_LOWER L'\u2584'

typedef struct {
  unsigned char color;
} Pixel;

typedef struct {
  wchar_t glyph;
  unsigned char color;
} NoiseCell;

typedef struct {
  float y;
  float speed;
  int length;
  int color;
} Stream;

typedef struct {
  bool active;
  float x;
  float y;
  float vx;
  float vy;
  int ttl;
  int age;
  int scale;
  int color;
} GlitchTag;

typedef struct {
  char ch;
  uint8_t rows[7];
} FontGlyph;

static Pixel *g_pixels = NULL;
static size_t g_pixels_cap = 0;
static int g_fb_w = 0;
static int g_fb_h = 0;

static NoiseCell *g_noise = NULL;
static size_t g_noise_cap = 0;
static int g_noise_w = 0;
static int g_noise_h = 0;

static short g_pairs[PAL_COUNT][PAL_COUNT];
static short g_next_pair = 1;
static volatile sig_atomic_t g_stop = 0;

static wchar_t pick_noise_glyph(float intensity);

static const short kPaletteMap[PAL_COUNT] = {
    COLOR_BLACK, COLOR_WHITE, COLOR_YELLOW, COLOR_RED,
    COLOR_MAGENTA, COLOR_BLUE, COLOR_CYAN, COLOR_GREEN,
};

static const FontGlyph kFont[] = {
    {' ', {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}},
    {'A', {0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11}},
    {'B', {0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E}},
    {'C', {0x0F, 0x10, 0x10, 0x10, 0x10, 0x10, 0x0F}},
    {'D', {0x1E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1E}},
    {'E', {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F}},
    {'F', {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10}},
    {'K', {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11}},
    {'L', {0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F}},
    {'M', {0x11, 0x1B, 0x15, 0x15, 0x11, 0x11, 0x11}},
    {'N', {0x11, 0x19, 0x15, 0x13, 0x11, 0x11, 0x11}},
    {'O', {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E}},
    {'P', {0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10}},
    {'R', {0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11}},
    {'S', {0x0F, 0x10, 0x10, 0x0E, 0x01, 0x01, 0x1E}},
    {'T', {0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04}},
    {'U', {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E}},
    {'Y', {0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04}},
    {'[', {0x1C, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1C}},
    {']', {0x07, 0x01, 0x01, 0x01, 0x01, 0x01, 0x07}},
};

static void cleanup_terminal(void) {
  if (stdscr != NULL && !isendwin()) {
    endwin();
  }

  free(g_pixels);
  free(g_noise);
  g_pixels = NULL;
  g_noise = NULL;
}

static void die(const char *message) {
  cleanup_terminal();
  fprintf(stderr, "%s\n", message);
  exit(EXIT_FAILURE);
}

static void *xrealloc(void *ptr, size_t size) {
  void *next = realloc(ptr, size);
  if (next == NULL) {
    die("allocation failed");
  }
  return next;
}

static void handle_signal(int signum) {
  (void)signum;
  g_stop = 1;
}

static float clampf(float value, float lo, float hi) {
  if (value < lo) {
    return lo;
  }
  if (value > hi) {
    return hi;
  }
  return value;
}

static int min_int(int a, int b) {
  return a < b ? a : b;
}

static int max_int(int a, int b) {
  return a > b ? a : b;
}

static float frand01(void) {
  return (float)rand() / (float)RAND_MAX;
}

static int random_palette(void) {
  return 1 + rand() % (PAL_COUNT - 1);
}

static short pair_for(int fg, int bg) {
  if (fg == PAL_BLACK && bg != PAL_BLACK) {
    return pair_for(bg, PAL_BLACK);
  }

  if (g_pairs[fg][bg] >= 0) {
    return g_pairs[fg][bg];
  }

  if (g_next_pair < COLOR_PAIRS &&
      init_pair(g_next_pair, kPaletteMap[fg], kPaletteMap[bg]) != ERR) {
    g_pairs[fg][bg] = g_next_pair;
    ++g_next_pair;
    return g_pairs[fg][bg];
  }

  if (bg != PAL_BLACK) {
    g_pairs[fg][bg] = pair_for(fg, PAL_BLACK);
    return g_pairs[fg][bg];
  }

  g_pairs[fg][bg] = 0;
  return 0;
}

static void init_color_pairs(void) {
  for (int fg = 0; fg < PAL_COUNT; ++fg) {
    for (int bg = 0; bg < PAL_COUNT; ++bg) {
      g_pairs[fg][bg] = -1;
    }
  }
  g_next_pair = 1;

  if (!has_colors()) {
    die("terminal does not support colors");
  }

  start_color();
  pair_for(PAL_BLACK, PAL_BLACK);
  for (int fg = 1; fg < PAL_COUNT; ++fg) {
    pair_for(fg, PAL_BLACK);
  }
}

static void draw_glyph(int y, int x, wchar_t glyph, int fg, int bg, attr_t attr) {
  wchar_t text[2] = {glyph, L'\0'};
  cchar_t cch;
  short pair = pair_for(fg, bg);

  if (y < 0 || y >= LINES || x < 0 || x >= COLS) {
    return;
  }

  if (setcchar(&cch, text, attr, pair, NULL) == ERR) {
    return;
  }

  mvadd_wch(y, x, &cch);
}

static void ensure_pixel_buffer(void) {
  int rows = 0;
  int cols = 0;
  getmaxyx(stdscr, rows, cols);

  g_fb_w = cols;
  g_fb_h = rows * 2;

  size_t need = (size_t)g_fb_w * (size_t)g_fb_h;
  if (need > g_pixels_cap) {
    g_pixels = xrealloc(g_pixels, need * sizeof(*g_pixels));
    g_pixels_cap = need;
  }
}

static void ensure_noise_buffer(void) {
  int rows = 0;
  int cols = 0;
  getmaxyx(stdscr, rows, cols);

  g_noise_w = cols;
  g_noise_h = rows;

  size_t need = (size_t)g_noise_w * (size_t)g_noise_h;
  if (need > g_noise_cap) {
    g_noise = xrealloc(g_noise, need * sizeof(*g_noise));
    g_noise_cap = need;
  }
}

static void clear_pixels(int color) {
  size_t count = (size_t)g_fb_w * (size_t)g_fb_h;
  for (size_t i = 0; i < count; ++i) {
    g_pixels[i].color = (unsigned char)color;
  }
}

static void clear_noise(void) {
  size_t count = (size_t)g_noise_w * (size_t)g_noise_h;
  memset(g_noise, 0, count * sizeof(*g_noise));
}

static void set_pixel(int x, int y, int color) {
  if (x < 0 || x >= g_fb_w || y < 0 || y >= g_fb_h) {
    return;
  }
  g_pixels[(size_t)y * (size_t)g_fb_w + (size_t)x].color = (unsigned char)color;
}

static int get_pixel(int x, int y) {
  if (x < 0 || x >= g_fb_w || y < 0 || y >= g_fb_h) {
    return PAL_BLACK;
  }
  return g_pixels[(size_t)y * (size_t)g_fb_w + (size_t)x].color;
}

static void fill_rect_px(int x, int y, int w, int h, int color) {
  int x0 = max_int(0, x);
  int y0 = max_int(0, y);
  int x1 = min_int(g_fb_w, x + w);
  int y1 = min_int(g_fb_h, y + h);

  for (int py = y0; py < y1; ++py) {
    for (int px = x0; px < x1; ++px) {
      set_pixel(px, py, color);
    }
  }
}

static void draw_logical_span(int ox, int oy, int scale, int y, int x0, int x1,
                              int color) {
  if (x1 < x0) {
    return;
  }

  fill_rect_px(ox + x0 * scale, oy + y * scale, (x1 - x0 + 1) * scale, scale,
               color);
}

static void draw_logical_rect(int ox, int oy, int scale, int x, int y, int w,
                              int h, int color) {
  fill_rect_px(ox + x * scale, oy + y * scale, w * scale, h * scale, color);
}

static float lerpf(float a, float b, float t) {
  return a + (b - a) * t;
}

static void fill_logical_cell(int ox, int oy, int scale, int x, int y,
                              int color) {
  fill_rect_px(ox + x * scale, oy + y * scale, scale, scale, color);
}

static void draw_logical_line(int ox, int oy, int scale, float x0, float y0,
                              float x1, float y1, int color) {
  float dx = x1 - x0;
  float dy = y1 - y0;
  int steps = max_int(1, (int)(fmaxf(fabsf(dx), fabsf(dy)) * 2.4f));

  for (int i = 0; i <= steps; ++i) {
    float u = (float)i / (float)steps;
    fill_logical_cell(ox, oy, scale, (int)lroundf(lerpf(x0, x1, u)),
                      (int)lroundf(lerpf(y0, y1, u)), color);
  }
}

static float skull_crack_center(float y, float t) {
  return 27.0f + sinf((y - 4.0f) * 0.62f + t * 0.9f) * 1.6f +
         cosf(y * 0.21f) * 0.8f;
}

static float skull_crack_gap(float y) {
  return 0.9f + (y > 18.0f ? 0.35f : 0.0f) + (y > 26.0f ? 0.40f : 0.0f);
}

static bool is_enter_key(int ch) {
  return ch == '\n' || ch == '\r' || ch == KEY_ENTER || ch == 13;
}

static const FontGlyph *font_glyph_for(char ch) {
  for (size_t i = 0; i < sizeof(kFont) / sizeof(kFont[0]); ++i) {
    if (kFont[i].ch == ch) {
      return &kFont[i];
    }
  }

  return &kFont[0];
}

static void draw_text_pixels(const char *text, int x, int y, int scale,
                             int color) {
  int cursor = 0;

  for (const char *p = text; *p != '\0'; ++p) {
    const FontGlyph *glyph = font_glyph_for(*p);

    for (int row = 0; row < 7; ++row) {
      for (int col = 0; col < 5; ++col) {
        if ((glyph->rows[row] >> (4 - col)) & 0x01u) {
          fill_rect_px(x + cursor + col * scale, y + row * scale, scale, scale,
                       color);
        }
      }
    }

    cursor += 6 * scale;
  }
}

static void stamp_noise_text(const char *text, int x, int y, int scale, int color,
                             float intensity) {
  int cursor = 0;

  for (const char *p = text; *p != '\0'; ++p) {
    const FontGlyph *glyph = font_glyph_for(*p);

    for (int row = 0; row < 7; ++row) {
      for (int col = 0; col < 5; ++col) {
        if (((glyph->rows[row] >> (4 - col)) & 0x01u) == 0) {
          continue;
        }

        for (int sy = 0; sy < scale; ++sy) {
          for (int sx = 0; sx < scale; ++sx) {
            int nx = x + cursor + col * scale + sx;
            int ny = y + row * scale + sy;

            if (nx < 0 || nx >= g_noise_w || ny < 0 || ny >= g_noise_h) {
              continue;
            }

            size_t idx = (size_t)ny * (size_t)g_noise_w + (size_t)nx;
            g_noise[idx].glyph = frand01() < 0.7f ? GLYPH_FULL
                                                  : pick_noise_glyph(intensity);
            g_noise[idx].color =
                (unsigned char)(frand01() < 0.14f ? random_palette() : color);
          }
        }
      }
    }

    cursor += 6 * scale;
  }
}

static int text_width_pixels(const char *text, int scale) {
  size_t len = strlen(text);
  if (len == 0) {
    return 0;
  }
  return (int)((len * 6 - 1) * (size_t)scale);
}

static int heat_color(float heat) {
  if (heat > 0.92f) {
    return PAL_WHITE;
  }
  if (heat > 0.74f) {
    return PAL_YELLOW;
  }
  if (heat > 0.52f) {
    return PAL_RED;
  }
  return PAL_MAGENTA;
}

static float ellipse_field(float x, float y, float cx, float cy, float rx,
                           float ry) {
  float dx = (x - cx) / rx;
  float dy = (y - cy) / ry;
  return 1.0f - sqrtf(dx * dx + dy * dy);
}

static wchar_t pick_noise_glyph(float intensity) {
  float sample = frand01() + intensity * 0.35f;
  if (sample > 1.00f) {
    return GLYPH_FULL;
  }
  if (sample > 0.80f) {
    return GLYPH_DARK;
  }
  if (sample > 0.58f) {
    return GLYPH_MEDIUM;
  }
  return GLYPH_LIGHT;
}

static void render_noise(void) {
  erase();

  for (int y = 0; y < g_noise_h; ++y) {
    for (int x = 0; x < g_noise_w; ++x) {
      NoiseCell cell = g_noise[(size_t)y * (size_t)g_noise_w + (size_t)x];
      if (cell.glyph == 0) {
        draw_glyph(y, x, GLYPH_FULL, PAL_BLACK, PAL_BLACK, A_NORMAL);
      } else {
        draw_glyph(y, x, cell.glyph, cell.color, PAL_BLACK, A_BOLD);
      }
    }
  }

  refresh();
}

static void render_pixels(void) {
  int rows = g_fb_h / 2;

  erase();

  for (int y = 0; y < rows; ++y) {
    for (int x = 0; x < g_fb_w; ++x) {
      int top = get_pixel(x, y * 2);
      int bottom = get_pixel(x, y * 2 + 1);
      wchar_t glyph = GLYPH_FULL;
      int fg = PAL_BLACK;
      int bg = PAL_BLACK;
      attr_t attr = A_NORMAL;

      if (top == PAL_BLACK && bottom == PAL_BLACK) {
        glyph = GLYPH_FULL;
        fg = PAL_BLACK;
        bg = PAL_BLACK;
      } else if (top == bottom) {
        glyph = GLYPH_FULL;
        fg = top;
      } else if (bottom == PAL_BLACK) {
        glyph = GLYPH_UPPER;
        fg = top;
      } else if (top == PAL_BLACK) {
        glyph = GLYPH_LOWER;
        fg = bottom;
      } else {
        glyph = GLYPH_UPPER;
        fg = top;
        bg = bottom;
      }

      if (fg != PAL_BLACK || bg != PAL_BLACK) {
        attr = A_BOLD;
      }

      draw_glyph(y, x, glyph, fg, bg, attr);
    }
  }

  refresh();
}

static void act_glitch_rain(void) {
  ensure_noise_buffer();
  clear_noise();

  int rows = g_noise_h;
  int cols = g_noise_w;
  int total_frames = rows * 2 + 72;
  Stream *streams = calloc((size_t)cols, sizeof(*streams));
  const int tag_slots = 5;
  GlitchTag *tags = calloc((size_t)tag_slots, sizeof(*tags));

  if (streams == NULL || tags == NULL) {
    die("allocation failed");
  }

  for (int frame = 0; frame < total_frames && !g_stop; ++frame) {
    float progress = (float)frame / (float)(max_int(total_frames - 1, 1));
    int additions = max_int(1, (int)(cols * (0.45f + progress * 2.35f)));
    int flood_rows = 0;
    int delay = 72 - (int)(progress * 58.0f);

    for (int i = 0; i < additions; ++i) {
      size_t idx = (size_t)(rand() % (rows * cols));
      if (g_noise[idx].glyph == 0 || progress > 0.72f ||
          frand01() < progress * 0.35f) {
        g_noise[idx].glyph = pick_noise_glyph(progress);
        g_noise[idx].color = (unsigned char)random_palette();
      }
    }

    for (int x = 0; x < cols; ++x) {
      if (streams[x].speed <= 0.0f && frand01() < 0.035f + progress * 0.24f) {
        streams[x].y = -(float)(rand() % max_int(rows / 2, 1));
        streams[x].speed = 0.45f + frand01() * 0.75f + progress * 1.10f;
        streams[x].length = 4 + rand() % 6;
        streams[x].color = random_palette();
      }

      if (streams[x].speed <= 0.0f) {
        continue;
      }

      streams[x].y += streams[x].speed;
      streams[x].speed += 0.02f + progress * 0.05f;

      int base_y = (int)streams[x].y;
      for (int t = 0; t < streams[x].length; ++t) {
        int y = base_y - t;
        if (y < 0 || y >= rows) {
          continue;
        }

        size_t idx = (size_t)y * (size_t)cols + (size_t)x;
        g_noise[idx].glyph = t == 0 ? GLYPH_FULL
                            : t == 1 ? GLYPH_DARK
                            : t == 2 ? GLYPH_MEDIUM
                                     : GLYPH_LIGHT;
        g_noise[idx].color = (unsigned char)(frand01() < 0.18f
                                                 ? random_palette()
                                                 : streams[x].color);
      }

      if (streams[x].y - streams[x].length > rows + 3) {
        streams[x].speed = 0.0f;
      }
    }

    if (progress > 0.56f) {
      flood_rows = (int)(((progress - 0.56f) / 0.44f) * rows);
      flood_rows = (int)clampf((float)flood_rows, 0.0f, (float)rows);

      for (int y = 0; y < flood_rows; ++y) {
        for (int x = 0; x < cols; ++x) {
          size_t idx = (size_t)y * (size_t)cols + (size_t)x;
          if (g_noise[idx].glyph == 0 || frand01() < 0.65f) {
            g_noise[idx].glyph = pick_noise_glyph(progress + 0.2f);
            g_noise[idx].color = (unsigned char)random_palette();
          }
        }
      }
    }

    if (progress > 0.10f) {
      for (int i = 0; i < tag_slots; ++i) {
        GlitchTag *tag = &tags[i];

        if (!tag->active &&
            frand01() < 0.03f + progress * 0.12f + (i == 0 ? 0.02f : 0.0f)) {
          tag->active = true;
          tag->scale = progress > 0.54f && frand01() < 0.36f ? 2 : 1;
          tag->x = (float)(rand() % max_int(1, cols - text_width_pixels("FUCK", tag->scale)));
          tag->y = (float)(rand() % max_int(1, rows - 7 * tag->scale));
          tag->vx = (frand01() - 0.5f) * (1.8f + progress * 2.8f);
          tag->vy = (frand01() - 0.5f) * (0.9f + progress * 1.8f);
          tag->ttl = 7 + rand() % 10;
          tag->age = 0;
          tag->color = frand01() < 0.24f ? PAL_WHITE
                       : frand01() < 0.60f ? PAL_RED
                                           : PAL_MAGENTA;
        }

        if (!tag->active) {
          continue;
        }

        int width = text_width_pixels("FUCK", tag->scale);
        int height = 7 * tag->scale;

        if (tag->age > 0 &&
            (frand01() < 0.08f + progress * 0.12f || tag->age > tag->ttl)) {
          stamp_noise_text("FUCK", (int)lroundf(tag->x), (int)lroundf(tag->y),
                           tag->scale, PAL_CYAN, 1.00f);
          tag->x = (float)(rand() % max_int(1, cols - width));
          tag->y = (float)(rand() % max_int(1, rows - height));
          tag->vx = (frand01() - 0.5f) * (2.3f + progress * 3.2f);
          tag->vy = (frand01() - 0.5f) * (1.2f + progress * 2.0f);
          tag->ttl = 5 + rand() % 7;
          tag->age = 0;
          tag->color = frand01() < 0.20f ? PAL_WHITE
                       : frand01() < 0.50f ? PAL_RED
                                           : PAL_MAGENTA;
          stamp_noise_text("FUCK", (int)lroundf(tag->x), (int)lroundf(tag->y),
                           tag->scale, PAL_WHITE, 1.15f);
        }

        tag->x += tag->vx;
        tag->y += tag->vy;
        tag->vx += (frand01() - 0.5f) * 0.16f;
        tag->vy += (frand01() - 0.5f) * 0.10f;
        tag->age += 1;

        if (tag->x < -width || tag->x > cols + 2 || tag->y < -height ||
            tag->y > rows + 2 || tag->age > tag->ttl + 7) {
          tag->active = false;
          continue;
        }

        for (int tail = 3; tail >= 1; --tail) {
          float tail_x = tag->x - tag->vx * (float)(tail * 2);
          float tail_y = tag->y - tag->vy * (float)(tail * 2);
          int tail_color = tail == 3 ? PAL_BLUE : tail == 2 ? PAL_MAGENTA : PAL_RED;
          stamp_noise_text("FUCK", (int)lroundf(tail_x + (frand01() - 0.5f) * tail),
                           (int)lroundf(tail_y), tag->scale, tail_color,
                           0.72f + progress * 0.20f);
        }

        stamp_noise_text("FUCK", (int)lroundf(tag->x), (int)lroundf(tag->y),
                         tag->scale, tag->color, 0.96f + progress * 0.26f);
        if (frand01() < 0.22f) {
          stamp_noise_text("FUCK", (int)lroundf(tag->x + (frand01() < 0.5f ? -1 : 1)),
                           (int)lroundf(tag->y), tag->scale,
                           frand01() < 0.5f ? PAL_WHITE : PAL_CYAN, 1.05f);
        }
      }
    }

    render_noise();
    napms(max_int(delay, 12));
  }

  for (int burst = 0; burst < 7 && !g_stop; ++burst) {
    for (int y = 0; y < rows; ++y) {
      for (int x = 0; x < cols; ++x) {
        size_t idx = (size_t)y * (size_t)cols + (size_t)x;
        g_noise[idx].glyph = pick_noise_glyph(0.8f + frand01() * 0.4f);
        g_noise[idx].color = (unsigned char)random_palette();
      }
    }
    render_noise();
    napms(22);
  }

  free(streams);
  free(tags);
}

static void white_flash(int frames, int delay_ms) {
  int rows = 0;
  int cols = 0;
  getmaxyx(stdscr, rows, cols);

  for (int frame = 0; frame < frames && !g_stop; ++frame) {
    erase();
    for (int y = 0; y < rows; ++y) {
      for (int x = 0; x < cols; ++x) {
        draw_glyph(y, x, GLYPH_FULL, PAL_WHITE, PAL_BLACK, A_BOLD);
      }
    }
    refresh();
    napms(delay_ms);
  }
}

static void draw_nuke_frame(float progress, float t) {
  ensure_pixel_buffer();
  clear_pixels(PAL_BLACK);

  float base = fminf((float)g_fb_w * 0.52f, (float)g_fb_h * 0.46f);
  float size = base * (0.82f + progress * 0.42f);
  float jitter_x = sinf(t * 13.0f) * 2.6f + (frand01() - 0.5f) * 5.8f;
  float jitter_y = cosf(t * 15.5f) * 1.8f + (frand01() - 0.5f) * 4.6f;
  float cx = (float)g_fb_w * 0.5f + jitter_x;
  float cy = (float)g_fb_h * 0.68f + jitter_y - progress * size * 0.12f;

  for (int y = 0; y < g_fb_h; ++y) {
    for (int x = 0; x < g_fb_w; ++x) {
      float nx = ((float)x - cx) / size;
      float ny = ((float)y - cy) / size;
      float density = -1.0f;

      density = fmaxf(density, ellipse_field(nx, ny, 0.00f, -0.62f, 0.18f, 0.13f));
      density = fmaxf(density, ellipse_field(nx, ny, 0.00f, -0.46f, 0.48f, 0.20f));
      density = fmaxf(density, ellipse_field(nx, ny, -0.34f, -0.30f, 0.28f, 0.20f));
      density = fmaxf(density, ellipse_field(nx, ny, 0.34f, -0.30f, 0.28f, 0.20f));
      density = fmaxf(density, ellipse_field(nx, ny, -0.52f, -0.16f, 0.19f, 0.14f));
      density = fmaxf(density, ellipse_field(nx, ny, 0.52f, -0.16f, 0.19f, 0.14f));
      density = fmaxf(density, ellipse_field(nx, ny, 0.00f, -0.04f, 0.62f, 0.24f));

      if (ny > -0.05f && ny < 0.95f) {
        float stem_t = clampf((ny + 0.05f) / 1.00f, 0.0f, 1.0f);
        float stem_half = 0.11f + 0.12f * fabsf(stem_t - 0.25f) + 0.10f * stem_t;
        float stem = 1.0f - fabsf(nx) / stem_half - fabsf(stem_t - 0.45f) * 0.68f;
        density = fmaxf(density, stem);
      }

      density = fmaxf(density, ellipse_field(nx, ny, 0.00f, 0.62f, 0.34f, 0.10f));
      density = fmaxf(density, ellipse_field(nx, ny, 0.00f, 0.82f, 0.20f, 0.06f));

      if (density > 0.0f) {
        float heat = density;
        heat += 0.16f * sinf(nx * 14.0f + t * 7.0f);
        heat += 0.13f * cosf(ny * 18.0f - t * 5.2f);
        heat += 0.08f * sinf((nx + ny) * 21.0f + t * 9.0f);
        heat += 0.18f * (0.42f - ny);
        heat += 0.08f * progress;
        if (fabsf(nx) < 0.09f && ny < 0.55f) {
          heat += 0.14f;
        }
        set_pixel(x, y, heat_color(clampf(heat, 0.0f, 1.15f)));
      } else if (density > -0.10f && frand01() < 0.024f + progress * 0.042f) {
        set_pixel(x, y, frand01() < 0.35f ? PAL_RED : PAL_MAGENTA);
      }
    }
  }

  {
    float shock_progress = clampf((progress - 0.16f) / 0.84f, 0.0f, 1.0f);
    float shock_cy = cy + size * 0.58f;
    float shock_radius =
        shock_progress * hypotf((float)g_fb_w * 0.62f, (float)g_fb_h * 0.72f);
    float ring_width = 2.5f + size * 0.040f + shock_progress * 4.0f;
    float wake_width = ring_width * 3.2f;

    if (shock_progress > 0.02f) {
      for (int y = 0; y < g_fb_h; ++y) {
        for (int x = 0; x < g_fb_w; ++x) {
          float dx = (float)x - cx;
          float dy = ((float)y - shock_cy) * 1.08f;
          float dist = sqrtf(dx * dx + dy * dy);
          float wave = 1.0f - fabsf(dist - shock_radius) / ring_width;
          float wake = 1.0f - fabsf(dist - (shock_radius - wake_width * 0.45f)) /
                                  wake_width;

          if (wave > 0.0f) {
            int color = wave > 0.68f ? PAL_WHITE : wave > 0.34f ? PAL_YELLOW
                                                           : PAL_RED;
            set_pixel(x, y, color);
          } else if (wake > 0.0f && dist < shock_radius && y > shock_cy - size * 0.10f &&
                     frand01() < 0.003f + wake * 0.020f) {
            set_pixel(x, y, wake > 0.45f ? PAL_YELLOW : PAL_RED);
          }
        }
      }
    }
  }

  render_pixels();
}

static void act_nuke(void) {
  white_flash(3, 38);

  for (int frame = 0; frame < 92 && !g_stop; ++frame) {
    float progress = (float)frame / 91.0f;
    float t = (float)frame * 0.09f;
    draw_nuke_frame(progress, t);
    napms(34);
  }
}

static void draw_skull_frame(float t) {
  const int width = 55;
  const int height = 40;
  ensure_pixel_buffer();
  clear_pixels(PAL_BLACK);

  int scale = max_int(1, min_int(g_fb_w / 58, g_fb_h / 44));
  scale = min_int(scale, 3);

  int art_w = width * scale;
  int art_h = height * scale;
  int ox = (g_fb_w - art_w) / 2 + (int)lroundf(sinf(t * 0.98f) * scale * 4.0f);
  int oy = (g_fb_h - art_h) / 2 +
           (int)lroundf(sinf(t * 0.92f) * cosf(t * 1.84f) * scale * 2.6f);
  float split = 2.2f + 0.9f * sinf(t * 0.9f);
  float jaw_spread = split * 0.7f + 0.7f;
  bool blink = fmodf(t * 2.5f, 1.0f) < 0.18f;
  int eye_color = blink ? PAL_WHITE : PAL_RED;

  for (int ly = 0; ly < height; ++ly) {
    for (int lx = 0; lx < width; ++lx) {
      float sx = (float)lx;
      float sy = (float)ly;
      bool left_half = sx < 27.0f;
      float half_shift = split;
      if (sy > 24.0f) {
        half_shift += jaw_spread * ((sy - 24.0f) / 16.0f);
      }

      float x = sx + (left_half ? half_shift : -half_shift);
      float y = sy - (sy > 29.0f ? 0.35f : 0.0f);
      float skull = -1.0f;
      float bone_heat = 0.0f;
      int color = PAL_CYAN;

      skull = fmaxf(skull, ellipse_field(x, y, 27.0f, 10.0f, 14.8f, 9.2f));
      skull = fmaxf(skull, ellipse_field(x, y, 27.0f, 18.1f, 18.8f, 11.2f));
      skull = fmaxf(skull, ellipse_field(x, y, 15.0f, 19.3f, 7.0f, 5.8f));
      skull = fmaxf(skull, ellipse_field(x, y, 39.0f, 19.3f, 7.0f, 5.8f));
      skull = fmaxf(skull, ellipse_field(x, y, 27.0f, 27.9f, 11.2f, 8.5f));
      skull = fmaxf(skull, ellipse_field(x, y, 18.8f, 32.0f, 7.4f, 6.3f));
      skull = fmaxf(skull, ellipse_field(x, y, 35.2f, 32.0f, 7.4f, 6.3f));

      if (skull <= 0.02f) {
        continue;
      }

      float left_eye = ellipse_field(x, y, 18.2f, 16.5f, 5.5f, 4.1f);
      float right_eye = ellipse_field(x, y, 35.8f, 16.5f, 5.5f, 4.1f);
      float cheek_left = ellipse_field(x, y, 15.0f, 23.0f, 4.4f, 3.5f);
      float cheek_right = ellipse_field(x, y, 39.0f, 23.0f, 4.4f, 3.5f);
      float mouth = ellipse_field(x, y, 27.0f, 29.0f, 10.8f, 3.0f);
      float nose = fminf(1.0f - fabsf(x - 27.0f) / 3.3f,
                         1.0f - fabsf(y - 21.0f) / 4.8f -
                             fabsf(x - 27.0f) * 0.25f);
      float crack_wave = skull_crack_center(sy, t);
      float crack_gap = skull_crack_gap(sy);
      float crack_dist = fabsf(sx - crack_wave);

      if (sy > 4.0f && sy < 35.0f && crack_dist < crack_gap) {
        continue;
      }

      if (left_eye > 0.04f || right_eye > 0.04f || cheek_left > 0.26f ||
          cheek_right > 0.26f || mouth > 0.06f || nose > 0.08f) {
        continue;
      }

      bone_heat = skull + 0.18f * cosf((x - 27.0f) * 0.31f) - y * 0.013f +
                  0.08f * sinf((x + y) * 0.18f + t);
      if (bone_heat > 0.74f) {
        color = PAL_WHITE;
      } else if (bone_heat > 0.38f) {
        color = PAL_CYAN;
      } else {
        color = PAL_BLUE;
      }

      if (sy > 25.0f && fabsf(sx - 27.0f) > 4.0f && fabsf(sx - 27.0f) < 15.0f) {
        color = bone_heat > 0.22f ? PAL_WHITE : PAL_CYAN;
      }

      if ((left_eye > -0.18f && left_eye <= 0.04f) ||
          (right_eye > -0.18f && right_eye <= 0.04f)) {
        color = PAL_MAGENTA;
      }

      if (crack_dist < crack_gap + 1.35f && sy > 5.0f && sy < 34.0f) {
        color = PAL_MAGENTA;
      }

      if (crack_dist < crack_gap + 2.20f && ((lx + ly) & 1) == 0 && sy > 7.0f &&
          sy < 33.0f) {
        color = PAL_RED;
      }

      if (nose > -0.16f && nose <= 0.08f) {
        color = PAL_RED;
      }

      fill_logical_cell(ox, oy, scale, lx, ly, color);
    }
  }

  draw_logical_span(ox, oy, scale, 6, 22, 24, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 6, 30, 32, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 8, 15, 20, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 8, 34, 39, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 11, 10, 17, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 11, 37, 44, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 13, 13, 18, eye_color);
  draw_logical_span(ox, oy, scale, 13, 36, 41, eye_color);
  draw_logical_span(ox, oy, scale, 14, 14, 18, PAL_RED);
  draw_logical_span(ox, oy, scale, 14, 36, 40, PAL_RED);
  draw_logical_span(ox, oy, scale, 17, 24, 26, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 17, 28, 30, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 19, 25, 29, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 26, 11, 23, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 26, 31, 43, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 27, 12, 23, PAL_CYAN);
  draw_logical_span(ox, oy, scale, 27, 31, 42, PAL_CYAN);
  draw_logical_span(ox, oy, scale, 28, 12, 23, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 28, 31, 42, PAL_WHITE);

  for (int tooth = 13; tooth <= 21; tooth += 2) {
    draw_logical_span(ox, oy, scale, 27, tooth, tooth, PAL_BLACK);
    draw_logical_span(ox, oy, scale, 28, tooth, tooth, PAL_BLACK);
  }

  for (int tooth = 33; tooth <= 41; tooth += 2) {
    draw_logical_span(ox, oy, scale, 27, tooth, tooth, PAL_BLACK);
    draw_logical_span(ox, oy, scale, 28, tooth, tooth, PAL_BLACK);
  }

  draw_logical_rect(ox, oy, scale, 38, 7, 8, 5, PAL_BLUE);
  draw_logical_rect(ox, oy, scale, 39, 8, 6, 3, PAL_CYAN);
  draw_logical_span(ox, oy, scale, 8, 40, 44, PAL_WHITE);
  draw_logical_span(ox, oy, scale, 10, 40, 44, PAL_WHITE);
  draw_logical_rect(ox, oy, scale, 38, 19, 8, 5, PAL_BLUE);
  draw_logical_rect(ox, oy, scale, 39, 20, 6, 3, PAL_MAGENTA);

  for (int vent = 20; vent <= 22; ++vent) {
    draw_logical_span(ox, oy, scale, vent, 39, 44,
                      (vent & 1) == 0 ? PAL_WHITE : PAL_CYAN);
  }

  fill_logical_cell(ox, oy, scale, 39, 8, PAL_WHITE);
  fill_logical_cell(ox, oy, scale, 44, 8, PAL_WHITE);
  fill_logical_cell(ox, oy, scale, 39, 22, PAL_WHITE);
  fill_logical_cell(ox, oy, scale, 44, 22, PAL_WHITE);

  for (int cable = 0; cable < 8; ++cable) {
    int y = 16 + cable * 2;
    int x0 = 25 + (cable % 3);
    int x1 = 28 + ((cable + 1) % 3);
    fill_logical_cell(ox, oy, scale, x0, y, cable & 1 ? PAL_RED : PAL_MAGENTA);
    fill_logical_cell(ox, oy, scale, x1, y + 1, cable & 1 ? PAL_WHITE : PAL_CYAN);
  }

  for (int arc = 0; arc < 3; ++arc) {
    float ay0 = 11.0f + arc * 6.2f + sinf(t * 2.1f + arc * 1.7f) * 1.2f;
    float ay1 = ay0 + 2.4f + cosf(t * 1.7f + arc) * 1.1f;
    float c0 = skull_crack_center(ay0, t);
    float c1 = skull_crack_center(ay1, t);
    float g0 = skull_crack_gap(ay0) + 0.9f;
    float g1 = skull_crack_gap(ay1) + 0.9f;
    float x0 = c0 - g0 - 0.9f;
    float x1 = c1 + g1 + 0.9f;
    float dx = x1 - x0;
    float dy = ay1 - ay0;
    float len = hypotf(dx, dy);
    float nx = len > 0.0f ? -dy / len : 0.0f;
    float ny = len > 0.0f ? dx / len : 0.0f;
    int steps = 12 + arc * 3;

    for (int i = 0; i < steps; ++i) {
      float u0 = (float)i / (float)steps;
      float u1 = (float)(i + 1) / (float)steps;
      float amp0 =
          sinf(u0 * 9.424777f + t * 6.5f + arc * 1.3f) * (1.3f + arc * 0.15f);
      float amp1 =
          sinf(u1 * 9.424777f + t * 6.5f + arc * 1.3f) * (1.3f + arc * 0.15f);
      float px0 = lerpf(x0, x1, u0) + nx * amp0;
      float py0 = lerpf(ay0, ay1, u0) + ny * amp0 * 0.55f;
      float px1 = lerpf(x0, x1, u1) + nx * amp1;
      float py1 = lerpf(ay0, ay1, u1) + ny * amp1 * 0.55f;
      int arc_color = (i & 1) == 0 ? PAL_WHITE : PAL_CYAN;

      draw_logical_line(ox, oy, scale, px0, py0, px1, py1, arc_color);
      if ((i % 3) == 1) {
        fill_logical_cell(ox, oy, scale, (int)lroundf(px1), (int)lroundf(py1),
                          PAL_MAGENTA);
      }
    }
  }

  for (int spark = 0; spark < 20; ++spark) {
    float phase = t * 8.0f + spark * 1.37f;
    float sy = 9.5f + fmodf(phase * 2.7f + spark * 0.9f, 23.0f);
    float crack_x = skull_crack_center(sy, t);
    float gap = skull_crack_gap(sy);
    float dir = (spark & 1) ? -1.0f : 1.0f;
    float sx = crack_x + dir * (gap + 0.2f + fabsf(sinf(phase)) * 0.8f);
    int trail = 2 + (spark % 3);

    for (int step = 0; step < trail; ++step) {
      float px = sx + dir * step * (0.7f + 0.15f * (spark % 2));
      float py = sy - step * (0.55f + 0.10f * (spark % 3));
      int spark_color = step == 0 ? PAL_WHITE : step == 1 ? PAL_YELLOW : PAL_RED;
      fill_logical_cell(ox, oy, scale, (int)lroundf(px), (int)lroundf(py),
                        spark_color);
      if (step == 0 && frand01() < 0.55f) {
        fill_logical_cell(ox, oy, scale, (int)lroundf(px),
                          (int)lroundf(py + 1.0f), PAL_MAGENTA);
      }
    }
  }

  fill_logical_cell(ox, oy, scale, 15, 9, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 16, 10, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 17, 12, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 18, 13, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 14, 20, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 15, 21, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 16, 22, PAL_BLACK);
  fill_logical_cell(ox, oy, scale, 13, 19, PAL_RED);
  fill_logical_cell(ox, oy, scale, 14, 21, PAL_MAGENTA);
  fill_logical_cell(ox, oy, scale, 17, 23, PAL_RED);

  for (int i = 0; i < 18; ++i) {
    int y = oy + (7 + i) * scale;
    int left_x = ox - (3 + (i % 2)) * scale;
    int right_x = ox + art_w + (2 + (i % 3 == 0)) * scale;
    int color = (i + (int)(t * 6.0f)) % 3 == 0 ? PAL_CYAN : PAL_MAGENTA;
    fill_rect_px(left_x, y, scale, scale, color);
    fill_rect_px(right_x, y + (i % 2) * scale, scale, scale, PAL_BLUE);
  }

  {
    static const char *caption = "SYSTEM REND";
    int caption_scale = 1;
    int caption_w = text_width_pixels(caption, caption_scale);
    int caption_x = max_int(0, (g_fb_w - caption_w) / 2);
    int caption_y = max_int(0, g_fb_h - 10);
    int caption_color = blink ? PAL_WHITE : ((int)(t * 4.0f) & 1) ? PAL_RED : PAL_MAGENTA;

    if (caption_w <= g_fb_w) {
      draw_text_pixels(caption, caption_x, caption_y, caption_scale, caption_color);
    }
  }

  render_pixels();
}

static void act_skull(void) {
  for (int frame = 0; frame < 132 && !g_stop; ++frame) {
    float t = (float)frame * 0.11f;
    draw_skull_frame(t);
    napms(42);
  }
}

static void act_void_collapse(void) {
  ensure_pixel_buffer();

  size_t count = (size_t)g_fb_w * (size_t)g_fb_h;
  Pixel *snapshot = malloc(count * sizeof(*snapshot));
  if (snapshot == NULL) {
    die("allocation failed");
  }

  memcpy(snapshot, g_pixels, count * sizeof(*snapshot));

  float cx = (float)g_fb_w * 0.5f;
  float cy = (float)g_fb_h * 0.5f;

  for (int frame = 0; frame < 18 && !g_stop; ++frame) {
    float progress = (float)frame / 17.0f;
    float collapse = powf(1.0f - progress, 2.2f);

    clear_pixels(PAL_BLACK);

    for (int y = 0; y < g_fb_h; ++y) {
      for (int x = 0; x < g_fb_w; ++x) {
        int color = snapshot[(size_t)y * (size_t)g_fb_w + (size_t)x].color;
        if (color == PAL_BLACK) {
          continue;
        }

        float dx = (float)x - cx;
        float dy = (float)y - cy;
        float swirl = sinf(dy * 0.08f + progress * 11.0f) * progress * 2.8f;
        int nx = (int)lroundf(cx + dx * collapse + swirl);
        int ny = (int)lroundf(cy + dy * collapse * collapse);
        int out_color = progress > 0.70f && frand01() < 0.36f ? PAL_WHITE : color;

        set_pixel(nx, ny, out_color);
        if (progress > 0.34f && frand01() < 0.02f + progress * 0.06f) {
          set_pixel(nx + (rand() % 3 - 1), ny + (rand() % 3 - 1), PAL_MAGENTA);
        }
      }
    }

    render_pixels();
    napms(26);
  }

  clear_pixels(PAL_BLACK);
  render_pixels();
  napms(48);
  free(snapshot);
}

static void draw_void_frame(int frame) {
  static const char *title = "SYSTEM DELETED";
  static const char *prompt_top = "ANY KEY";
  static const char *prompt_mid = "REBORN";
  static const char *prompt_bottom = "ENTER ENDS";

  ensure_pixel_buffer();
  clear_pixels(PAL_BLACK);

  int title_scale = max_int(1, min_int(g_fb_w / 90, g_fb_h / 20));
  int prompt_scale = 1;
  int shadow = max_int(1, title_scale / 2);
  int title_w = text_width_pixels(title, title_scale);
  int prompt_top_w = text_width_pixels(prompt_top, prompt_scale);
  int prompt_mid_w = text_width_pixels(prompt_mid, prompt_scale);
  int prompt_bottom_w = text_width_pixels(prompt_bottom, prompt_scale);
  int title_x = (g_fb_w - title_w) / 2;
  int title_y = max_int(4, g_fb_h / 3 - (7 * title_scale) / 2);
  int prompt_top_x = max_int(0, (g_fb_w - prompt_top_w) / 2);
  int prompt_mid_x = max_int(0, (g_fb_w - prompt_mid_w) / 2);
  int prompt_bottom_x = max_int(0, (g_fb_w - prompt_bottom_w) / 2);
  int prompt_top_y = max_int(0, g_fb_h - 25);
  int prompt_mid_y = max_int(0, g_fb_h - 17);
  int prompt_bottom_y = max_int(0, g_fb_h - 9);
  int shadow_color = (frame / 3) % 2 == 0 ? PAL_RED : PAL_MAGENTA;

  draw_text_pixels(title, title_x + shadow, title_y + shadow, title_scale,
                   shadow_color);
  draw_text_pixels(title, title_x, title_y, title_scale, PAL_WHITE);

  draw_text_pixels(prompt_top, prompt_top_x, prompt_top_y, prompt_scale, PAL_WHITE);
  draw_text_pixels(prompt_mid, prompt_mid_x, prompt_mid_y, prompt_scale,
                   (frame / 5) % 2 == 0 ? PAL_WHITE : PAL_RED);
  draw_text_pixels(prompt_bottom, prompt_bottom_x, prompt_bottom_y, prompt_scale,
                   (frame / 4) % 2 == 0 ? PAL_RED : PAL_MAGENTA);

  render_pixels();
}

static bool act_void(void) {
  flushinp();
  act_void_collapse();
  timeout(90);

  for (int frame = 0; !g_stop; ++frame) {
    draw_void_frame(frame);
    int ch = getch();
    if (ch != ERR) {
      timeout(0);
      return !is_enter_key(ch);
    }
  }

  timeout(0);
  return false;
}

int main(void) {
  setlocale(LC_ALL, "");

  srand((unsigned int)time(NULL));
  signal(SIGINT, handle_signal);
  signal(SIGTERM, handle_signal);
  atexit(cleanup_terminal);

  initscr();
  noecho();
  cbreak();
  keypad(stdscr, TRUE);
  curs_set(0);
  nodelay(stdscr, TRUE);

  init_color_pairs();

  while (!g_stop) {
    act_glitch_rain();
    if (g_stop) {
      break;
    }

    act_nuke();
    if (g_stop) {
      break;
    }

    act_skull();
    if (g_stop) {
      break;
    }

    if (!act_void()) {
      break;
    }
  }

  return 0;
}
