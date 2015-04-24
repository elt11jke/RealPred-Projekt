import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;

public class Regul extends Thread {
	public static final int CVXGEN = 0;
	public static final int QPGEN = 1;

	private static final double H =0.05;
	
	private AnalogIn analogInY1; 
	private AnalogIn analogInY2;
	private AnalogIn analogInY3;
	private AnalogIn analogInY4;
	
	private AnalogIn analogInYRaw1;
	private AnalogIn analogInYRaw2;
	
	
	private double h1;
	private double h2;
	private double h3;
	private double h4;
	
	private double [] dataToSend = new double[6];
	
	private long timeSolCVX;
	
	private AnalogOut analogOutu1;
	private AnalogOut analogOutu2;
	
	private MPCController mpc=new MPCController();
	double u1;
	double u2;
	
	private ReferenceGenerator referenceGenerator;
	private OpCom opcom;
	
	private int priority;
	private boolean WeShouldRun = true;
	private long starttime;
	private Semaphore mutex; // used for synchronization at shut-down
	
	private ModeMonitor modeMon;
	
	double tank1Ref,tank2Ref;
	double[] solution;
	
	//Parameters PI flowController
	double K = 0.21;
	double Ti = 0.06;
	double Tr = Ti;
	double  h = 0.01;
	
	double yMin = 0.0;  // nominal min venturi pressure
    double yMax = 10.0; // nominal max venturi pressure
    
    double y1 ;
    double yref1 ;  // necessary in order not to miscalibrate
    double yold1 ;
    double P1 ;
    double I1 ;
    double v1 ;
    double yRaw1;
    
    double y2 ;
    double yref2 ;  // necessary in order not to miscalibrate
    double yold2 ;
    double P2 ;
    double I2 ;
    double v2 ;
    double yRaw2;
	
	
	
	// Inner monitor class
	class ModeMonitor {
		private int mode;
		
		// Synchronized access methods
		public synchronized void setMode(int newMode) {
			mode = newMode;
			
		}
		
		public synchronized int getMode() {
			return mode;
		}
	}
	
	public Regul(int pri) {
		
		priority = pri;
		mutex = new Semaphore(1);
		
		//Two PI regulators
		// flowController1
		
		    this.y1 = 0.0;
		    thidurations.yref1 = 0.5;  // necessary in order not to miscalibrate
		    this.yold1 = 0.0;
		    this.P1 = 0.0;
		    this.I1 = 0.0;
		    this.v1  =0.0;
		    
		 // flowController2
		    this.y2 = 0.0;
		    this.yref2 = 0.5;  // necessary in order not to miscalibrate
		    this.yold2 = 0.0;
		    this.P2 = 0.0;
		    this.I2 = 0.0;
		    this.v2  =0.0;
		
		 
        /*
		//Connecting the channels to the real tank process
		try {
			
			analogInY1 = new AnalogIn(31);
			analogInY2 = new AnalogIn(33);
			analogInY3 = new AnalogIn(30);
			analogInY4 = new AnalogIn(32);
			
			
			analogInYRaw1 = new AnalogIn(35);
			analogInYRaw2= new AnalogIn(34);
			
			
			analogOutu1 = new AnalogOut(31);
			analogOutu2= new AnalogOut(30);
			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}
		*/
		
		
		modeMon = new ModeMonitor();
	}
	
	public void setOpCom(OpCom opcom) {
		// Written by you
		this.opcom=opcom;
		
	}
	
	public void setRefGen(ReferenceGenerator referenceGenerator){
		// Written by you
		this.referenceGenerator=referenceGenerator;
		
	}
	
	// Called in every sample in order to send plot data to OpCom
	private void sendDataToOpCom(double yref1,double yref2, double y1,double y2, double u1,double u2) {
		double x = (double)(System.currentTimeMillis() - starttime) / 1000.0;
		DoublePoint dp1 = new DoublePoint(x,u1);
		DoublePoint dp2 = new DoublePoint(x,u2);
		
		PlotData pd1 = new PlotData(x,yref1,y1);
		PlotData pd2 = new PlotData(x,yref2,y2);
		
		opcom.putControlU1DataPoint(dp1);
		opcom.putControlU2DataPoint(dp2);
		opcom.putMeasurementTank1DataPoint(pd1);
		opcom.putMeasurementTank2DataPoint(pd2);
		
		//opcom.putControlU2DataPoint(dp);
		//opcom.putMeasurementTank2DataPoint(pd);
	}
	
	
	
	public void setCVXGENMode(){
		// Written by you
		modeMon.setMode(CVXGEN);
		
	}
	
	public void setQPGENMode(){
		// Written by you
		modeMonduration.setMode(QPGEN);
	}
	
	
	public int getMode(){
		// Written by you	
	 return	modeMon.getMode();
	 
	}
	
	// Called from OpCom when shutting down
	public synchronized void shutDown() {
		WeShouldRun = false;
		mutex.take();
		//try {
			//analogOut.set(0.0);int
		//} catch (IOChannelException x) {
		//}
	}
	
	private double limit(double v, double min, double max) {
		if (v < min) {
			v = min;
		} else if (v > max) {
			v = max;
		}
		return v;
	}
	
	public double flowController1(double yref1) {
		
		
			    double u;
				   
				//% extract raw inputs
			    /*
				try {
					yRaw1 = analogInYRaw1.get() ;
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				this.yref1 = yref1;

				//rescale input
				yref1 = yref1/10;

				//venturi pressure to flow
				y1 = Math.sqrt(Math.max((yRaw1-yMin),0)/(yMax-yMin));
                 */
				//calculate output
				v1 = 0.0;
				P1 = -K*y1;
				v1 = v1+P1;
				v1 = v1 + I1;
				u = v1;

				if (yref1 <= 0.0){
				    u = 0.0;
				}
				else if (yref1 >= 1.0){
				    u = 1.0;
				}
				

				// update state
				I1 = I1 + H*K/Ti*(yref1-y1) + H*(1/Tr)*(u-v1);
				yold1 = y1;

				//rescale output
				u = 10*u;
	        	return u;
		
	}
	public double flowController2(double yref2) {
		
			    double u;
				// extract raw inputs
			    /*
				try {
					yRaw2 = analogInYRaw2.get() ;
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				this.yref2 = yref2;

				//rescale input
				yref2 = yref2/10;

				//venturi pressure to flow
				y2 = Math.sqrt(Math.max((yRaw2-yMin),0)/(yMax-yMin));
                */
				//calculate output
				v2 = 0.0;
				P2 = -K*y2;
				v2 = v2+P2;
				v2 = v2 + I2;
				u = v2;

				if (yref2 <= 0.0){
				    u = 0.0;
				}
				else if (yref2 >= 1.0){
				    u = 1.0;
				}
				

				// update state
				I2 = I2 + H*K/Ti*(yref2-y2) + H*(1/Tr)*(u-v2);
				yold2 = y2;

				//rescale output
				u = 10*u;
	        	return u;
	}
	
	
	public void run() {
		long duration;
		long t = System.currentTimeMillis();
		starttime = t;
		
		setPriority(priority);
		mutex.take();
		while (WeShouldRun) {
			
			switch (modeMon.getMode()) {
			case CVXGEN: {
				 
				// Code for the CVXGEN mode. 
				// Written by you.
				// Should include resetting the controllers
				// Should include a call to sendDataToOpCom
				
				/*
				 try {
						h1 = analogInY1.get();
						h2 = analogInY2.get();
						h3 = analogInY3.get();
						h4 = analogInY4.get();
						
					} catch (IOChannelException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					
					*/
            
				tank1Ref=referenceGenerator.getRef1();
				tank2Ref=referenceGenerator.getRef2();
				
				dataToSend[0] = 0;
				dataToSend[1] = 0;
				dataToSend[2]t = 0;
				dataToSend[3] = 0;
				dataToSend[4] = tank1Ref;
				dataToSend[5] = tank2Ref;
				
				
				timeSolCVX = System.currentTimeMillis();
				solution = mpc.calculateOutput(dataToSend);
				timeSolCVX= System.currentTimeMillis()-timeSolCVX;
				System.out.println(timeSolCVX);
				
				
				
				//u1=flowController1(solution[0]);
				//u2=flowController2(solution[1]);
				
				/*Putting the outputs to the pumps
				 
				try {
					analogOutu1.set(u1);
					analogOutu2.set(u2);
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				*/
				
				
				 System.out.println(solution[0]);
				 System.out.ptrintln(solution[1]);
				
                 sendDataToOpCom(tank1Ref,tank2Ref,0,0,u1,u2);
                
                /*uncomment to test in the real process
                
                   sendDataToOpCom(tank1Ref,tank2Ref,y1,y2,u1,u2);
                   
                */
                
				System.out.println("CVXGEN mode");
				break;
			}
			
			case QPGEN: {
				// Code for the QPGEN mode
				// Written by you.
				// Should include a call to sendDataToOpCom
				 
				/*
				try {
					synchronized(outer){
						
					    angleRef = outer.limit(outer.calculateOutput(analogInAngle.get(), referenceGenerator.getRef()),-10,10);
					}
					angle = analogInAngle.get();
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}t
				
				
			  synchronized(inner){
				motorVolt=inner.limit(inner.calculateOutput(angle, angleRef),-10,10 ) ;
				
				try {
					analogOut.set(motorVolt);
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				inner.updateState(motorVolt);
				}
			  */
				System.out.println("QPGEN");
				// tank1Ref=referenceGenerator.getRef();
				
				//sendDataToOpCom(tank1Ref,0,0);
				break;
			}
			/*
			case BALL: {
				// Code for tthe BALL mode
				// Written by you.
				// Should include a call to sendDataToOpCom 
				
		t 		
				positionRef = referenceGenerator.getRef();
				/*
				try {
					position = analogInPosition.get();
				} catch (IOChannelException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
			    synchronized(inner){
				    synchronized(outer){
				    	angleRef=outer.limit(outer.calculateOutput(position, positionRef),-10,10 ) ;
				
				    	motorVolt= inner.limit(inner.calculateOutput(angle, angleRef),-10, 10);
				
				    	try {
				    		analogOut.set(motorVolt);
				    	} catch (IOChannelException e) {
				    		/t/ TODO Auto-generated catch block
				    		e.printStackTrace();
				    	}
				
				   		outer.updateState(angleRef);
					}
				inner.updateState(motorVolt);
				
			    }
			    
				sendDataToOpCom(positionRef,position,angleRef);
				break;
				
			}
			*/
			default: {
				System.out.println("Error: Illegal mode.");
				break;
		 	}
			}
			
			// sleep
			t = t + ((long) H * 1000);
			duration = t - System.currentTimeMillis();
			if (duration > 0) {
				try {
					sleep(duration);
				} catch (InterruptedException x) {
				}
			}
		
		}
		mutex.give();
		
	}
   
	
}
