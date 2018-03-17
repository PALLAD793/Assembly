#include <allegro.h>
#include <stdlib.h>
#include <time.h>
#include "BezierCurve.h"

int main()
{
    srand( time( NULL ));
    allegro_init();
    install_keyboard();
    int X=800, Y=600;
    int x0=0, y0=0, x1=0, y1=0, x2=0, y2=0, x3=0, y3=0, x4=0, y4=0;
    double deltaT = 0.0001;

    set_gfx_mode( GFX_AUTODETECT_WINDOWED, X, Y, 0, 0 );

    BITMAP * obraz = create_bitmap(X, Y);

    if(!obraz)
    {
        set_gfx_mode( GFX_TEXT, 0, 0, 0, 0);
        allegro_message( "Nie mozna zaladowac obrazu!");
        allegro_exit();
        return 1;
    }

    while( 1 )
    {

        if( key[ KEY_ESC ])
        {
            destroy_bitmap(obraz);
            allegro_exit();
            return 0;
        }
        else
        {
	    int color =  rand()%192;
            clear_to_color( obraz, color );
            x0 = rand() % X;
            y0 = rand() % Y;
            x1 = rand() % X;
            y1 = rand() % Y;
            x2 = rand() % X;
            y2 = rand() % Y;
            x3 = rand() % X;
            y3 = rand() % Y;
            x4 = rand() % X;
            y4 = rand() % Y;
	   // int temp;
	   /* if(x4 < x3) {temp=x4; x4=x3; x3=temp;}
	    if(x3 < x2) {temp=x3; x3=x2; x2=temp;}
	    if(x2 < x1) {temp=x2; x2=x1; x1=temp;}
	    if(x1 < x0) {temp=x1; x1=x0; x0=temp;}
	    if(x4 < x3) {temp=x4; x4=x3; x3=temp;}
	    if(x3 < x2) {temp=x3; x3=x2; x2=temp;}
	    if(x2 < x1) {temp=x2; x2=x1; x1=temp;}
	    if(x4 < x3) {temp=x4; x4=x3; x3=temp;}
	    if(x3 < x2) {temp=x3; x3=x2; x2=temp;}
	    if(x4 < x3) {temp=x4; x4=x3; x3=temp;}*/
	
	    int textColor = 5*(255 - color) % 256;

            textprintf_ex( obraz, font, 5, 5, makecol(textColor, 0, textColor), -1, "P0: %d %d", x0, y0 );
            textprintf_ex( obraz, font, 5, 15, makecol(textColor, 0, textColor), -1, "P1: %d %d", x1, y1 );
            textprintf_ex( obraz, font, 5, 25, makecol(textColor, 0, textColor), -1, "P2: %d %d", x2, y2 );
            textprintf_ex( obraz, font, 5, 35, makecol(textColor, 0, textColor), -1, "P3: %d %d", x3, y3 );
            textprintf_ex( obraz, font, 5, 45, makecol(textColor, 0, textColor), -1, "P4: %d %d", x4, y4 );

	    BezierCurve( obraz->line, obraz->w, obraz->h, x0, y0, x1, y1, x2, y2, x3, y3, x4, y4, deltaT, textColor/2 );

            blit(obraz, screen, 0, 0, 0, 0, obraz->w, obraz->h);

            readkey();
        }

    }
  //  BezierCurve( obraz->line, obraz->w, obraz->h, x0, y0, x1, y1, x2, y2, x3, y3, x4, y4 );

 //   textout_ex( screen, font, "PENIS!", 10, 10, makecol(0, 0, 0), -1 );

    allegro_exit();
    return 0;
}
