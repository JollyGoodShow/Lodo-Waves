# Lodo-Waves

In order to run the code inside of lodo_wave.pde, you must have processing 2.x or 3.x installed. You can install quickly for free at https://processing.org/download/

Once installed, copy-paste the code into a new Processing window and press the play button to run.

This is a prototype for the wave or dancefloor mode for lodo as Chris envisioned it. Mouse clicking and movement would be replaced with changes in pressure voltage readings, but the logic behind the code should be the same. I wrote it in Processing because it's easy to create graphics such as these, and it's a fairly readable language (Java plus extra).

The heart of the program is a numerical approximation to the wave equation in 2D:
  U(x,y,t) is a function which lies on a surface S, spanning from x [0,a] and y [0,b]
  The output of U at event (x,y,t) represents the displacement of the wave from equillibrium at that place and time. From Newton's laws, a surface who's tension behaves like springs will create a wave satisfying the following equation:
    Utt = c^2(Uxx + Uyy) + f(x,y,t)
  Where Utt is the second derivative of U with respect to time, and Uxx and Uyy are the second derivatives of U with respect to x and y, respectively. f(x,y,t) represents any external forces that might be acting on the surface. c is a constant which is surface dependant, and specifies the speed of the wave through the medium.
  
  
