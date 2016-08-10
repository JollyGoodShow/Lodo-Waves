package waves

import "github.com/lord/lodo/core"
import "time"

const (
	n_x = 35					// Lights in x-direction
	n_y = 43					// Lights in y-direction
	dt = 0.1					// Duration of time step [s]
	c = 1.5						// A constant (defines wave speed) [m/s]
	c2 = c*c*dt*dt				// Used in later calculations
	dx = 0.1					// Approximate distance between lights [m]
	dy = 0.1					// ""                                   ""
)

func Run(board *core.Board) {
	board.refreshSensors()
	board.SetVerticleMode(true)
	timeOut := time.Now().Add(time.Duration(60)*time.Second)
	
	//Create three 2D arrays to store the values of the wave function, "u"
	//at each point on the board, at three times (to calc 2nd derivative)
	uPrev := make([][]float64, n_x+1)
	uCurrent := make([][]float64, n_x+1)
	uNext := make([][]float64, n_x+1)
	for i := range u_prev {
		u_prev[i] = make([]float64, n_y+1)
		u_current[i] = make([]float64, n_y+1)
		u_next[i] = make([]float64, n_y+1)
	}
	
	for {
		core.PetDog()								// Pet dog or die
		board.RefreshSensors()			
		drawBoard(board, uCurrent)					// Pretty colors
		stepWave(uPrev, uCurrent, uNext)			// Advance the wave
		dampen(1.003, uPrev, uNext)					// "Friction"
		
		if board.CheckAnyDown() { timeout += 60 }	// Extend timeout if there's action
		if time.Now().After(time.Out) { return }	// Times out after 1 minute
		
		board.Save()
	} 
}


func drawBoard(board *core.Board, uCurrent [][]float64) {
	// Set the lights to be colorful based on the values of uCurrent
	var r, g, b int
	var alpha float64
	//colors := make([]core.Color, 35+43) //Left off here
	
	for x := 1; x < 36; x++ {
		for y := 1; y < 44; y++ {
		
			r = getRed(uCurrent[x][y])
			g = getGreen(uCurrent[x][y])
			b = getBlue(uCurrent[x][y])
			alpha = getAlpha(uCurrent[x][y])
			
			color := core.MakeColorAlpha(r, g, b, alpha)
			board.DrawPixel(x, y, color)
		}
	}
}

func round(a float64) int {			// Round a positive float to nearest integer
	if float64(int(a)) + 0.5 - a < 0 {
		return int(a) + 1
	} else {
		return int(a)
	}
}

func getRed(a float64) int {			// Determine how much red to be used
	if a > -40 && a < 20 {
		return 0
	} else if a < -60 || a > 40 {
		return 31
	} else if a < -40 {
		return round( -1.55*(a + 40))
	} else if a > 20 {
		return round( 1.55*(a - 20))
	}
	return 0
}

 func getGreen(a float64) int {			// Determine how much green to be used
	if a < -20 || a > 60 {
		return 0
	} else if a < 0 {
		return round( 1.55*(a + 20))
	} else if a > 40 {
		return round( -1.55*(a - 40) + 31)
	}
	return 31
}

func getBlue(a float64) int {			// Determine how much blue to be used
	if a < 0 {
		return 31
	} else if a < 20 {
		return round(31 - 1.55*a)
	}
	return 0
}

func getAlpha(a float64) float64 {		// Determine brightness -- waves dim at troughs
	if a > 0 {
		return 1.0
	} else if a > -70 {
		return 0.0143*(a + 70)
	}
	return 0
}


func stepWave(uPrev [][]float64, uCurrent [][]float64, uNext [][]float64) {
	// Applies an approximation to the wave equation to propogate the wave
	for i := 1; i < n_x-1; i++ {
		for j := 1; j < n_y-1; j++ {
			var innerDifference1 float64 = (uCurrent[i-1][j]-2*uCurrent[i][j]+uCurrent[i+1][j])/(dx*dx);
			var innerDifference2 float64 = (uCurrent[i][j-1]-2*uCurrent[i][j]+uCurrent[i][j+1])/(dy*dy);
			uNext[i][j] = C2*(innerDifference1 + innerDifference2) + 2*uCurrent[i][j] - uPrev[i][j] + (dt*dt)*force(i, j);
		}
	}
	// Copies uCurrent into uPrev, and uNext into uCurrent
	for i := 1; i < n_x-1; i++ {
		for j := 1; j < n_y-1; j++ {
			uPrev[i][j] = uCurrent[i][j];
			uCurrent[i][j] = uNext[i][j];
		}
	} 
}

func force(i int,j int) float64 {
	// ***** UNFINISHED *****
	//Stepping on a square causes a force on the membrane
	//Not quite sure how to implement fully
	return - i - j - 3.14
}

func dampen(amount float64, uPrev [][]float64, uCurrent [][]float64) {		//Optionally causes the wave to decay
	// amount > 1.000 (unless you like crashing your system)
	for i:=0; i<n_x-1; i++ {
		for j:=0; j<n_y-1; j++ {
			uPrev[i][j] /= amount;
			uCurrent[i][j] /= amount;
		}
	}
}
