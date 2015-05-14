import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math.*;

public class FlowController1 extends Thread{

	private AnalogOut analogOutu1;
	private AnalogIn analogInYraw1;
	private int prio;
	public double v1, P1, I1, yref1, yold1, y1;
	private final double K = 0.21, Ti = 0.06, Tr =0.06, yMin=0.0, yMax=10.0;
	public double u1, yraw1;
	private Regul regul;
        private long startTime;
        private double ref1;      
        private long time,time0;
        private final long h =10;

	public FlowController1(int prio){
		this.prio = prio;

		try {
			analogOutu1 = new AnalogOut(31);
			analogInYraw1 = new AnalogIn(35);

			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}
			
			yref1 = 0.5; 
			yold1 = 0.0;
			P1 = 0.0;
			I1 = 0.0;
			v1  =0.0;
			y1=0.0;
			
	}

	public void run(){
		long duration;
		long t = System.currentTimeMillis();
		startTime = t;
		
		while(true){
			time0 = System.currentTimeMillis();
                        
			  
			try {
				u1 = flowCon();
				//actuate(u2);
			         analogOutu1.set(u1);
		
                              
			} catch(Exception e) {
				System.out.println("Error in communication with process");
			}

                         
		        // sleep
			t = t+h ;
			duration = t - System.currentTimeMillis();
			if(duration>0){
				try {
					sleep(duration);
				} catch (InterruptedException x) {
					System.out.println("Error in thread, sleep funtion");
				}				
			}
                         time =  System.currentTimeMillis()- time0 ;
                 	
			
		}
                
	}

	public void setRegul(Regul r) {
		regul = r;
	}

	public synchronized void setRef(double yref1){
		this.yref1=yref1/10;
	}
        public synchronized double getControlSignalU1(){
		return u1;
	}

	private synchronized double flowCon() {

		
		try{
			yraw1 = analogInYraw1.get();
			
		} catch (Exception e){
			System.out.println("Unable to receive data from port yraw1");
		}
               	
		
                
		y1 = Math.sqrt(Math.max((yraw1-yMin),0)/(yMax-yMin));
		
             //  System.out.println("FlowRef1 : " + yref1);
            //    System.out.println("Flow Measure 1: " + y2);
//		v2 = 0.0;
                
//		P2 = -K*(y2 -yref2);
//		v2 = v2+P2;
//		v2 = v2 + I2;
//		u2 = v2;
                P1=K *(yref1 - y1);
                u1 = P1 + I1;
                v1=u1;

		if(u1 <= 0.0){
			u1 = 0.0;
		} else if (u1 >= 1.0){
			u1 = 1.0;
		}
           
		// update state
		I1 = I1 + (h*K/Ti*(yref1-y1))/1000 + (h*(1/Tr)*(u1-v1))/1000;
		yold1 = y1;
             //   System.out.println("Control Signal rescale :" +u2 ); 
		// rescale output
		return u1*10;
	}
	private void actuate(double u1){
		try {
			analogOutu1.set(u1);
		} catch (IOChannelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
