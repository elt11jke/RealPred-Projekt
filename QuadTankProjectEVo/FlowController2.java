import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math.*;

public class FlowController2 implements Runnable{

	private AnalogOut analogOutU2;
	private AnalogIn analogInY2;
	private double v2, P2, y2, I2, u2, uref2, yold2, y;
	private final double K = 0.21, h = 0.01, Ti = 0.06, Tr = 0.06, yMin=0.0, yMax=17.0;

	public FlowController2(){

		try {
			analogInY2 = new AnalogIn(34);
			analogOutU2 = new AnalogOut(30);

			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}
			y2 = 0.0;
			uref2 = 0.5; 
			yold2 = 0.0;
			P2 = 0.0;
			I2 = 0.0;
			v2 =0.0;
			y=0.0;
			u2=0.0;
	}

	public void run(){
		long startTime;
		long duration;
		
		while(true){
			startTime = System.currentTimeMillis();
			try {
				u2 = flowCon();
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

	public void changeRef(double uref2){
		this.uref2=uref2;
	}

	private double flowCon() {

		double u;
		try{
			y2 = analogInY2.get();
		} catch (Exception e){
			System.out.println("Unable to receive data from port");
		}	
		uref2 = uref2/10;
		y = Math.sqrt(Math.max((y2-yMin),0)/(yMax-yMin));

		v2 = 0.0;
		P2 = -K*y;
		v2 = v2+P2;
		v2 = v2 + I2;
		u = v2;

		if(uref2 <= 0.0){
			u = 0.0;
		} else if (uref2 >= 1.0){
			u = 1.0;
		}

		// update state
		I2 = I2 + h*K/Ti*(uref2-y) + h*(1/Tr)*(u-v2);
		yold2 = y2;

		// rescale output
		return 10*u;
	}
	private void actuate(){
		try {
			analogOutU2.set(u2);
		} catch (IOChannelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
