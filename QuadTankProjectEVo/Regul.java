import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;

public class Regul extends Thread {
	public static final int CVXGEN = 0, QPGEN = 1;
	private static final double h =0.05;
	
	private AnalogIn analogInY1, analogInY2, analogInY3, analogInY4;
	private AnalogOut analogOutu1, analogOutu2;
	
	private double h1, h2, h3, h4, u1, u2, tank1Ref, tank2Ref, y1, uref1, yold1, P1, I1, v1, y2, uref2, yold2, P2, I2, v2;
	private long timeSolCVX;
	private int priority;
	private boolean WeShouldRun = true;

	private double[] dataToSend, solution;
	
	//Semaphore
	private Semaphore mutex; // used for synchronization at shut-down
	//Instances
	private MPCController mpc;
	private ModeMonitor modeMon;
	private FlowController1 fc1;
	private FlowController2 fc2;	
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
	private OpCom opcom;
	private ReferenceGenerator referenceGenerator;
	
	

	public Regul(int pri) {
		
		priority = pri;
		mutex = new Semaphore(1);
		mpc=new MPCController();
		fc1 = new FlowController1();
		fc2 = new FLowController2();
		modeMon = new ModeMonitor();
		dataToSend = new double[6]
	}
	public void run() {
		long duration;
		long startTime;

		setPriority(priority);
		mutex.take();

		while (WeShouldRun) {
			startTime = System.currentTimeMillis();
			
			switch (modeMon.getMode()) {
				case CVXGEN: {
					 
					// Code for the CVXGEN mode. 
					// Written by you.
					// Should include resetting the controllers
					// Should include a call to sendDataToOpCom
		        
					tank1Ref=referenceGenerator.getRef1();
					tank2Ref=referenceGenerator.getRef2();
				
					dataToSend[0] = 0;
					dataToSend[1] = 0;
					dataToSend[2] = 0;
					dataToSend[3] = 0;
					dataToSend[4] = tank1Ref;
					dataToSend[5] = tank2Ref;
				
					timeSolCVX = System.currentTimeMillis();
					solution = mpc.calculateOutput(dataToSend);
					timeSolCVX= System.currentTimeMillis()-timeSolCVX;
					System.out.println(timeSolCVX);
				
					//Test
					System.out.println(solution[0]);
					System.out.ptrintln(solution[1]); 
				
		            sendDataToOpCom(tank1Ref,tank2Ref,0,0,u1,u2);
		            
		            /*uncomment to test in the real process
		            
		               sendDataToOpCom(tank1Ref,tank2Ref,y1,y2,u1,u2);
		               
		            */
		            
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
			

			duration = (long)(1000*h) - System.currentTimeMillis() - startTime;
			if(duration>0){
				try {
					Thread.sleep(duration);
				} catch (InterruptedException x) {
					System.out.println("Error in thread, sleep funtion");
				}				
			}
		
		}
		mutex.give();
		
	}
	public void setOpCom(OpCom opcom) {
		// Implemented before
		this.opcom=opcom;
		
	}
	public void setRefGen(ReferenceGenerator referenceGenerator){
		// Implemented before
		this.referenceGenerator=referenceGenerator;
		
	}
	public void setCVXGENMode(){
		modeMon.setMode(CVXGEN);
		System.out.println("CVXGEN mode");	
	}
	public void setQPGENMode(){
		modeMonduration.setMode(QPGEN);
		System.out.println("QPGEN mode");
	}
	// Called from OpCom when shutting down
	public synchronized void shutDown() {
		WeShouldRun = false;
		mutex.take();
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
	
	private double limit(double v, double min, double max) {
		if (v < min) {
			v = min;
		} else if (v > max) {
			v = max;
		}
		return v;
	}
	private int getMode(){
	 return	modeMon.getMode();
	}
}
