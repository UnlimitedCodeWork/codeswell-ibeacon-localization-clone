/* boxmuller.c
 Implements the Polar form of the Box-Muller Transformation
 
 (c) Copyright 1994, Everett F. Carter Jr.
 Permission is granted by the author to use
 this software for any application provided this
 copyright notice is preserved.
 
 Found here: http://www.taygeta.com/random/gaussian.html
 Minor modifications for use in the iOS environment by Andrew Craze
 
 */

#include <math.h>


extern double drand48();         /* drand48() is uniform in 0..1 */


float box_muller(float m, float s)	/* normal random variate generator */
{				        /* mean m, standard deviation s */
	float x1, x2, w, y1;
	static float y2;
	static int use_last = 0;
    
	if (use_last)		        /* use value from previous call */
	{
		y1 = y2;
		use_last = 0;
	}
	else
	{
		do {
			x1 = 2.0 * (float)drand48() - 1.0;
			x2 = 2.0 * (float)drand48() - 1.0;
			w = x1 * x1 + x2 * x2;
		} while ( w >= 1.0 );
        
		w = sqrt( (-2.0 * log( w ) ) / w );
		y1 = x1 * w;
		y2 = x2 * w;
		use_last = 1;
	}
    
	return( m + y1 * s );
}
