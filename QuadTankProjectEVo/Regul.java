import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math;

public class Regul extends Thread {
	public static final int CVXGEN = 0, QPGEN = 1;
	private static final double h =0.05;
	
	private AnalogIn analogInY1, analogInY2, analogInY3, analogInY4;
	private AnalogOut analogOutu1, analogOutu2;
	
	private double h1, h2, h3, h4, u1, u2, tank1Ref, tank2Ref, y1, uref1, yold1, P1, I1, v1, y2, uref2, yold2, P2, I2, v2, y1LP, y2LP, y1LP1, y2LP1, y1LP2, y2LP2;
	private long timeSolCVX, startTime;
	private int priority;
	private boolean WeShouldRun = true;

	private double[] dataToSend, solution;
	private int[][] W0 = new int[6][6];
	private int[][] V0 = new int[2][2];
	private int[][] P0 = new int[6][6];
	private double[][] K0 = new int[6][2];
	private double[][] A0 = new int[6][6];
	private double[][] B0 = new int[6][2];
	private double[][] C0 = new int[2][6];
	private double[] states0 = new double[6];
	private double[] measurements0 = new double[2];
	private Matrix measurements;	
	private double tank1, tank2;
	
	

	
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
		fc2 = new FlowController2();
		modeMon = new ModeMonitor();
		dataToSend = new double[6];
	}
	public void run() {
		long duration;

		setPriority(priority);
		mutex.take();
		fc1.run();
		fc2.run();

		dataToSend[0] = 0;
		dataToSend[1] = 0;
		dataToSend[2] = 0;
		dataToSend[3] = 0;
		dataToSend[4] = 0;
		dataToSend[5] = 0;
		solution = mpc.calculateOutput(dataToSend);

		for(int i=1; i<7; i++) {
			W0[i][i] = 1;
		}

		for(int i=1; i<3; i++) {
			V0[i][i] = 0.1;
		}

		for(int i=1;i<7; i++) {
			P0[i][i] = 1;
		}

		A0 = {{0.9708,0.,0.2466,0.,0.1126,0.0072}, {0.,0.9689,0.,0.4032,0.0108,0.1061}, {0.,0.,0.7495,0.,0.,0.0482}, {0.,0.,0.,0.5898,0.0381,0.}, {0.,0.,0.,0.,1.,0.}, {0.,0.,0.,0.,0.,1.}}; 
		B0 = {{0.1126, 0.0072},{0.0108, 0.1061}, {0., 0.0482}, {0.0381, 0.}, {0., 0.}, {0., 0.}};
		C0 = {{0.5, 0., 0., 0., 0., 0.}, {0., 0.5, 0., 0., 0., 0.}};

		Matrix W = new Matrix(W0);
		Matrix V = new Matrix(V0);
		Matrix P = new Matrix(P0);
		Matrix A = new Matrix(A0);
		Matrix B = new Matrix(B0);
		Matrix C = new Matrix(C0);
		Matrix states = new Matrix(states0);

		y1LP1 = 0; y1LP2 = 0; y2LP1 = 0; y2LP2 = 0;
		
		 		
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

					y1LP =0.25*(4*y1LP1 - y1LP2 + fc1.y1);
					y1LP2 = y1LP1; y1LP1 = y1LP; 
					
					y2LP = (1/9)*(12*y2LP1 - 4*y2LP2 + fc2.y2);
					y2LP2 = y2LP1; y2LP1 = y2LP;

					measurements0 = {y1LP, y2LP};
					measurements = new Matrix(measurements0);
				
					P = A.transpose().times(P).times(A).minus(A.transpose().times(P).times(C).times((C.transpose().times(P).times(C).plus(V)).inverse()).times(B.transpose.times(P).times(A)).plus(W);	
					K = (B.transpose().times(P).times(B).plus(V)).inverse().times(B.transpose()).times(P).times(A);		
					states = A.times(states).minus(K.times(measurements.minus(C.times(states))));			

					dataToSend[0] = states[1];
					dataToSend[1] = states[2];
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
					System.out.println(solution[1]);


					//Actuate
					fc1.changeRef(solution[0]);
					fc2.changeRef(solution[1]);
				
		            		sendDataToOpCom(tank1Ref,tank2Ref,states[1],states[2],fc1.u1,fc2.u2);
		           
		            
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
				
			}
			duration = (long)(1000*h) - System.currentTimeMillis() - startTime;
			if(duration>0){
				try {
					Thread.sleep(duration);
				} catch (InterruptedException x) {
					System.out.println("Error in thread, sleep funtion");
				}				
			}
			mutex.give();
		}
			
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
		modeMon.setMode(QPGEN);
		System.out.println("QPGEN mode");
	}
	// Called from OpCom when shutting down
	public synchronized void shutDown() {
		WeShouldRun = false;
		mutex.take();
	}
	public int getMode(){
	 return	modeMon.getMode();
	}
	// Called in every sample in order to send plot data to OpCom
	private void sendDataToOpCom(double yref1,double yref2, double y1,double y2, double u1,double u2) {
		double x = (double)(System.currentTimeMillis() - startTime) / 1000.0;
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
}
