import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;

public class Regul extends Thread {

	public static final int CVXGEN = 0, QPGEN = 1;
	private static final double H =0.05;
	
	private AnalogIn analogInH1, analogInH2, analogInH3, analogInH4;
	private AnalogOut analogOutu1, analogOutu2;
	
	private double h1, h2, u1, u2, tank1Ref, tank2Ref, y1LP, y2LP, y1LP1, y2LP1, y1LP2, y2LP2;
	private long timeSolCVX, starttime;
	private int priority;
	private boolean WeShouldRun = true;
	private double[] dataToSend, solution;

	//Instances
	private Semaphore mutex; // used for synchronization at shut-down     
	private ModeMonitor modeMon;
	private FlowController1 fc1;
	private FlowController2 fc2;
	private OpCom opcom;
	private ReferenceGenerator referenceGenerator;
	
	private CVXGENController cvx = new CVXGENController();
	private QPGENController qp = new QPGENController();
	
	

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
		modeMon = new ModeMonitor();
		dataToSend = new double[6];	
		 
		try {
		        analogInH1= new AnalogIn(31);
			analogInH2= new AnalogIn(33); 			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}   

		y1LP1 = 0; y1LP2 = 0; y2LP1 = 0; y2LP2 = 0;
	}
	
	public void setOpCom(OpCom opcom) {
		this.opcom=opcom;	
	}
	
	public void setRefGen(ReferenceGenerator referenceGenerator){
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
	}
	
	
	
	public void setCVXGENMode(){
		modeMon.setMode(CVXGEN);
		
	}
	
	public void setQPGENMode(){
		modeMon.setMode(QPGEN);
	}
	
	
	public int getMode(){
		 return	modeMon.getMode();
	 
	}
	
	// Called from OpCom when shutting down
	public synchronized void shutDown() {
		WeShouldRun = false;
		mutex.take();
	}
	
	private double limit(double v, double min, double max) {
		if (v < min) {
			v = min;
		} else if (v > max) {
			v = max;
		}
		return v;
	}
	
	public void setFlowController1(FlowController1 fc1) {
		this.fc1=fc1;
		
	}


	public void setFlowController2(FlowController2 fc2) {
		this.fc2=fc2;
		
	}
	
	public void run() {
		long duration;
		long t = System.currentTimeMillis();
		starttime = t;
		setPriority(priority);
		mutex.take();

		dataToSend[0] = 0;
		dataToSend[1] = 0;
		dataToSend[2] = 0;
		dataToSend[3] = 0;
		dataToSend[4] = tank1Ref;
		dataToSend[5] = tank2Ref;
		
		while (WeShouldRun) {
			
			switch (modeMon.getMode()) {
			case CVXGEN: {
				System.out.println("CVXGEN mode");

				try{
					h1 = analogInH1.get();
					h2 = analogInH2.get();
				} catch (Exception e){
					System.out.println("Unable to receive data from port");
				}
            
				tank1Ref=referenceGenerator.getRef1();
				tank2Ref=referenceGenerator.getRef2();
				
				y1LP =0.25*(4*y1LP1 - y1LP2 + h1);
				y1LP2 = y1LP1; y1LP1 = y1LP; 
					
				y2LP = (1/9)*(12*y2LP1 - 4*y2LP2 + h2);
				y2LP2 = y2LP1; y2LP1 = y2LP;

				dataToSend[0] = y1LP;
				dataToSend[1] = y2LP;
				dataToSend[2] = 0;
				dataToSend[3] = 0;
				dataToSend[4] = tank1Ref;
				dataToSend[5] = tank2Ref;

				timeSolCVX = System.currentTimeMillis();
				solution = cvx.calculateOutputCVX(dataToSend);
				timeSolCVX= System.currentTimeMillis()-timeSolCVX;
				System.out.println(timeSolCVX);
				
				//Test
				System.out.println(solution[0]);
				System.out.println(solution[1]);

				//Actuate
				fc1.changeRef(solution[0]);
				fc2.changeRef(solution[1]);
				
		            	sendDataToOpCom(tank1Ref,tank2Ref,y1LP,y2LP,fc1.u1,fc2.u2);
				break;
			}
			
			case QPGEN: {
				System.out.println("QPGEN");

				try{
					h1 = analogInH1.get();
					h2 = analogInH2.get();
				} catch (Exception e){
					System.out.println("Unable to receive data from port");
				}
	
				tank1Ref=referenceGenerator.getRef1();
				tank2Ref=referenceGenerator.getRef2();
				
				y1LP =0.25*(4*y1LP1 - y1LP2 + h1);
				y1LP2 = y1LP1; y1LP1 = y1LP; 
					
				y2LP = (1/9)*(12*y2LP1 - 4*y2LP2 + h2);
				y2LP2 = y2LP1; y2LP1 = y2LP;

				dataToSend[0] = y1LP;
				dataToSend[1] = y2LP;
				dataToSend[2] = 0;
				dataToSend[3] = 0;
				dataToSend[4] = tank1Ref;
				dataToSend[5] = tank2Ref;
				
				timeSolCVX = System.currentTimeMillis();
				solution = qp.calculateOutputQPGEN(dataToSend);
				timeSolCVX= System.currentTimeMillis()-timeSolCVX;
				System.out.println("time :" +timeSolCVX);
								
				//Test
				System.out.println(solution[0]);
				System.out.println(solution[1]);

				//Actuate
				fc1.changeRef(solution[0]);
				fc2.changeRef(solution[1]);
				
		            	sendDataToOpCom(tank1Ref,tank2Ref,y1LP,y2LP,fc1.u1,fc2.u2);
				break;
			}
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
