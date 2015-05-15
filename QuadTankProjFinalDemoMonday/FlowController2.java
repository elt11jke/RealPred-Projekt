import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math.*;

public class FlowController2 extends Thread{

	private AnalogOut analogOutu2;
	private AnalogIn analogInYraw2;
	private int prio;
	public double v2, P2, I2, yref2, yold2, y2;
	private final double K = 0.21, Ti = 0.06, Tr =0.06, yMin=0.0, yMax=10.0;
	public double u2, yraw2;
	private Regul regul;
        private long startTime;
        private double ref2;      
        private long time,time0;
        private final long h =10;

	public FlowController2(int prio){
		this.prio = prio;

		try {
			analogOutu2 = new AnalogOut(30);
			analogInYraw2 = new AnalogIn(34);

			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}
			
			yref2 = 0.5; 
			yold2 = 0.0;
			P2 = 0.0;
			I2 = 0.0;
			v2  =0.0;
			y2=0.0;
			
	}

	public void run(){
		long duration;
		long t = System.currentTimeMillis();
		startTime = t;
		
		while(true){
			time0 = System.currentTimeMillis();
                        
			  
			try {
				u2 = flowCon();
				//actuate(u2);
			         analogOutu2.set(u2);
		
                              
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
        public synchronized void shutDown(){
               actuate(0.0);
       } 

	public synchronized void setRef(double yref2){
		this.yref2=yref2/10;
	}
        public synchronized double getControlSignalU2(){
		return u2;
	}

	private synchronized double flowCon() {

		
		try{
			yraw2 = analogInYraw2.get();
			
		} catch (Exception e){
			System.out.println("Unable to receive data from port yraw2");
		}
               	
		
                
		y2 = Math.sqrt(Math.max((yraw2-yMin),0)/(yMax-yMin));
		
              // System.out.println("FlowRef2 : " + yref2);
            //    System.out.println("Flow Measure 2: " + y2);
//		v2 = 0.0;
                
//		P2 = -K*(y2 -yref2);
//		v2 = v2+P2;
//		v2 = v2 + I2;
//		u2 = v2;
               
                P2=K *(yref2 - y2);
                u2 = P2 + I2;
                v2=u2;

		if(u2 <= 0.0){
			u2 = 0.0;
		} else if (u2 >= 1.0){
			u2 = 1.0;
		}
           
		// update state
		I2 = I2 + (h*K/Ti*(yref2-y2))/1000 + (h*(1/Tr)*(u2-v2))/1000;
		yold2 = y2;
             //   System.out.println("Control Signal rescale :" +u2 ); 
		// rescale output
		return u2*10;
	}
	private void actuate(double u2){
		try {
			analogOutu2.set(u2);
		} catch (IOChannelException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
