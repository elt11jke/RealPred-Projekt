import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math.*;

public class FlowController1 implements Runnable{

	private AnalogOut analogOutU1;
	private AnalogIn analogInY1;
	private double v1, P1, I1, uref1, yold1, y;
	private final double K = 0.21, h = 0.01, Ti = 0.06, Tr = 0.06, yMin=0.0, yMax=17.0;
	public double u1, y1;

	public FlowController1(){

		try {
			analogInY1 = new AnalogIn(35);
			analogOutU1 = new AnalogOut(31);

			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}
			y1 = 0.0;
			uref1 = 0.5; 
			yold1 = 0.0;
			P1 = 0.0;
			I1 = 0.0;
			v1  =0.0;
			y=0.0;
			u1=0.0;
	}

	public void run(){
		long startTime;
		long duration;
		
		while(true){
			startTime = System.currentTimeMillis();
			try {
				u1 = flowCon();
				actuate();
			} catch(Exception e) {
				System.out.println("Error in communication with process");
			}
			duration = (long)(1000*h) - System.currentTimeMillis() - startTime;
			if(duration>0){
				try {
					Thread.sleep(duration);
				} catch (InterruptedException x) {
					System.out.println("Error in thread, sleep funtion");
				}				
			}
		}
	}

	public void changeRef(double uref1){
		this.uref1=uref1;
	}

	private double flowCon() {

		double u;
		try{
			y1 = analogInY1.get();
		} catch (Exception e){
			System.out.println("Unable to receive data from port");
		}	
		uref1 = uref1/10;
		y = Math.sqrt(Math.max((y1-yMin),0)/(yMax-yMin));

		v1 = 0.0;
		P1 = -K*y;
		v1 = v1+P1;
		v1 = v1 + I1;
		u = v1;

		if(uref1 <= 0.0){
			u = 0.0;
		} else if (uref1 >= 1.0){
			u = 1.0;
		}

		// update state
		I1 = I1 + h*K/Ti*(uref1-y) + h*(1/Tr)*(u-v1);
		yold1 = y1;

		// rescale output
		return 10*u;
	}
	private void actuate(){
		try {
			analogOutU1.set(u1);
		} catch (IOChannelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}


	
}
