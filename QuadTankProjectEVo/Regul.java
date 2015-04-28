

import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import java.lang.Math.*;
import Jama.*;

public class Regul extends Thread {

	public static final int CVXGEN = 0, QPGEN = 1;
	private static final double h =0.05;
	
	private AnalogIn analogInH1, analogInH2, analogInH3, analogInH4;
	private AnalogOut analogOutu1, analogOutu2;
	
	private double h1, h2, u1, u2, tank1Ref, tank2Ref, y1LP, y2LP, y1LP1, y2LP1, y1LP2, y2LP2;
	private long timeSolCVX, startTime;
	private int priority;
	private boolean WeShouldRun = true;
	private double[] dataToSend, solution;

	private double[][] A0 = {{0.9708,0.0,0.2466,0.0,0.1126,0.0072}, {0.0,0.9689,0.0,0.4032,0.0108,0.1061}, {0.0,0.0,0.7495,0.0,0.0,0.0482}, {0.0,0.0,0.0,0.5898,0.0381,0.0}, {0.0,0.0,0.0,0.0,1.0,0.0}, {0.0,0.0,0.0,0.0,0.0,1.0}}; 
	private double[][] B0 = {{0.1126, 0.0072},{0.0108, 0.1061}, {0.0, 0.0482}, {0.0381, 0.}, {0.0, 0.0}, {0.0, 0.0}};
	private double[][] C0 = {{0.5, 0.0, 0.0, 0.0, 0.0, 0.0}, {0.0, 0.5, 0.0, 0.0, 0.0, 0.0}};
	private double[][] W0 = new double[6][6];
	private double[][] V0 = new double[2][2];
	private double[][] P0 = new double[6][6];
	private double[][] K0 = new double[6][2];
	private double[][] states0 = new double[6][1];
	private double[][] measurements0 = new double[2][1];
	private Matrix measurements;	

	//Instances
	private Semaphore mutex; // used for synchronization at shut-down
	private MPCController mpc;
	private ModeMonitor modeMon;
	private FlowController1 fc1;
	private FlowController2 fc2;
	private OpCom opcom;
	private ReferenceGenerator referenceGenerator;


	
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
		mpc = new MPCController();
		modeMon = new ModeMonitor();
		dataToSend = new double[6];

		try {
		        analogInH1= new AnalogIn(31);
			analogInH2= new AnalogIn(33); 			
		} catch (IOChannelException e) { 
			System.out.print("Error: IOChannelException: ");
			System.out.println(e.getMessage());
		}    

		for(int i=0; i<6; i++) {
			W0[i][i] = 1.0;
		}

		for(int i=0; i<2; i++) {
			V0[i][i] = 0.1;
		}

		for(int i=0;i<6; i++) {
			P0[i][i] = 1.0;
		}

		y1LP1 = 0; y1LP2 = 0; y2LP1 = 0; y2LP2 = 0;
	}



	public void run() {
		long duration;

		setPriority(priority);
		mutex.take();

		Matrix A = new Matrix(A0);
		Matrix B = new Matrix(B0);
		Matrix C = new Matrix(C0);
		Matrix W = new Matrix(W0);
		Matrix V = new Matrix(V0);
		Matrix P = new Matrix(P0);
		Matrix K = new Matrix(K0);
		Matrix states = new Matrix(states0);

		dataToSend[0] = 0;
		dataToSend[1] = 0;
		dataToSend[2] = 0;
		dataToSend[3] = 0;
		dataToSend[4] = 0;
		dataToSend[5] = 0;
		solution = mpc.calculateOutput(dataToSend);
				
		while (WeShouldRun) {
			startTime = System.currentTimeMillis();
			
			switch (modeMon.getMode()) {
				case CVXGEN: {
						        
					tank1Ref = referenceGenerator.getRef1();
					tank2Ref = referenceGenerator.getRef2();
					
					try{
						h1 = analogInH1.get();
						h2 = analogInH2.get();
					} catch (Exception e){
						System.out.println("Unable to receive data from port");
					}	
					
					y1LP =0.25*(4*y1LP1 - y1LP2 + h1);
					y1LP2 = y1LP1; y1LP1 = y1LP; 
					
					y2LP = (1/9)*(12*y2LP1 - 4*y2LP2 + h2);
					y2LP2 = y2LP1; y2LP1 = y2LP;

					measurements0[0][0] = y1LP;
					measurements0[1][0] = y2LP;
					measurements = new Matrix(measurements0);
				
					P = A.transpose().times(P).times(A).minus(A.transpose().times(P).times(C).times((C.transpose().times(P).times(C).plus(V)).inverse()).times(B.transpose().times(P).times(A))).plus(W);	
					K = (B.transpose().times(P).times(B).plus(V)).inverse().times(B.transpose()).times(P).times(A);		
					states = A.times(states).minus(K.times(measurements.minus(C.times(states))));			

					dataToSend[0] = states.get(0,0);
					dataToSend[1] = states.get(1,0);
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
				
		            		sendDataToOpCom(tank1Ref,tank2Ref,states.get(0,0),states.get(1,0),fc1.u1,fc2.u2);
		           
		            
					break;
				}
			
				case QPGEN: {
					 
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


	public void setFlowController1(FlowController1 fc1) {
		// Implemented before
		this.fc1=fc1;
		
	}


	public void setFlowController2(FlowController2 fc2) {
		// Implemented before
		this.fc2=fc2;
		
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
