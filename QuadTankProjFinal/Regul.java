import se.lth.control.DoubleField;
import se.lth.control.DoublePoint;
import se.lth.control.realtime.AnalogIn;
import se.lth.control.realtime.AnalogOut;
import se.lth.control.realtime.IOChannelException;
import se.lth.control.realtime.Semaphore;
import Jama.*;


public class Regul extends Thread {

	public static final int CVXGEN = 0, QPGEN = 1;
	private static final long H = 500;
	
	private AnalogIn analogInH1, analogInH2, analogInH3, analogInH4;
	private AnalogOut analogOutu1, analogOutu2;
	
	private double h1, h2, u1, u2, tank1Ref, tank2Ref, y1LP, y2LP, y1LP1, y2LP1, y1LP2, y2LP2, yk1,yk2;
	private long timeSolCVX, starttime;
	private int priority;
	private boolean WeShouldRun = true;
	private double[] dataToSend, solution,solution1;


        
	private double[][] A0 = {{0.9708,0.0,0.2466,0.0,0.1126,0.0072}, {0.0,0.9689,0.0,0.4032,0.0108,0.1061}, {0.0,0.0,0.7495,0.0,0.0,0.0482}, {0.0,0.0,0.0,0.5898,0.0381,0.0}, {0.0,0.0,0.0,0.0,1.0,0.0}, {0.0,0.0,0.0,0.0,0.0,1.0}}; 
	private double[][] B0 = {{0.1126, 0.0072},{0.0108, 0.1061}, {0.0, 0.0482}, {0.0381, 0.}, {0.0, 0.0}, {0.0, 0.0}};
	private double[][] C0 = {{0.5, 0.0, 0.0, 0.0, 0.0, 0.0}, {0.0, 0.5, 0.0, 0.0, 0.0, 0.0}};
	private double[][] W0 = new double[6][6];
	private double[][] V0 = new double[2][2];
	private double[][] P0 = {{0.0,1.0,0.0,0.0,0.0,0.0},{0.0,0.0,1.0,0.0,0.0,0.0},{0.0,0.0,1.0,0.0,0.0,0.0},{0.0,0.0,0.0,1.0,0.0,0.0},{0.0,0.0,0.0,0.0,1.0,0.0},{0.0,0.0,0.0,0.0,0.0,1.0}};
	private double[][] K0 = {{0.0,0.0},{0.0,0.0},{0.0,0.0},{0.0,0.0},{0.0,0.0},{0.0,0.0}};
	private double[][] Y_est0 = new double[2][1];
	private double[][] states0 = {{0.0},{0.0},{0.0},{0.0},{1.0},{1.0}};
	private double[][] measurements0 = new double[2][1];
	private double[][] inputU0 = new double[2][1];
	
	

	//Instances
	private Semaphore mutex; // used for synchronization at shut-down     
	private ModeMonitor modeMon;
	private FlowController1 fc1;
	private FlowController2 fc2;
	private OpCom opcom;
	private ReferenceGenerator referenceGenerator;
	
	private CVXGENController cvx = new CVXGENController();
	private QPGENController qp = new QPGENController();
      
        private long time, time0;
        
	
	

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
		dataToSend = new double[8];	
		 
		try {
		        analogInH1= new AnalogIn(31);
			analogInH2= new AnalogIn(33); 	
                        //analogOutu1= new AnalogOut(31);
                	//analogOutu2= new AnalogOut(30);
         		
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
		
                fc1.shutDown();
                fc2.shutDown();
                
                
 	        
                   try{
                    fc1.setRef(0.0);
					fc2.setRef(0.0);
					
				} catch (Exception e){
					System.out.println("Unable to receive data from port");
				}
                
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
	
	public void run() { //throws MatlabConnectionException, MatlabInvocationException {
		long duration;
		long t = System.currentTimeMillis();
		starttime = t;
		setPriority(priority);
		mutex.take(); 
                
                Matrix A      = new Matrix(A0);
		Matrix B      = new Matrix(B0);
		Matrix C      = new Matrix(C0);
		Matrix W      = new Matrix(W0);
		Matrix V      = new Matrix(V0);
		Matrix P      = new Matrix(P0);
		Matrix K      = new Matrix(K0);
		Matrix states = new Matrix(states0);
		Matrix Y_est  = new Matrix(Y_est0);
		Matrix inputU = new Matrix(inputU0);
		Matrix measurements = new Matrix(measurements0);

		
             
		
    
		dataToSend[0] = 0;
		dataToSend[1] = 0;
		dataToSend[2] = 0;
		dataToSend[3] = 0;   
		dataToSend[4] = 1;
		dataToSend[5] = 1;
                dataToSend[6] = tank1Ref;
		dataToSend[7] = tank2Ref;
		solution = cvx.calculateOutputCVX(dataToSend);
   

		while (WeShouldRun) {
			time0 =System.currentTimeMillis();
			//switch (QPGEN){
			switch (modeMon.getMode()) {
			case CVXGEN: {
                                
				System.out.println("CVXGEN mode");

				try{
					h1 = analogInH1.get();
					h2 = analogInH2.get();
				} catch (Exception e){
					System.out.println("Unable to receive data from port h1 h2");
				}
                                if(h1<0){
 				   h1=0;
                                 }
                                 if(h2<0){
 				   h2=0;
                                 }
				tank1Ref=referenceGenerator.getRef1();
				tank2Ref=referenceGenerator.getRef2();
				//fc1.setRef(tank1Ref);
				//fc2.setRef(tank2Ref);

				
                                y1LP1 = h1*0.1 + (1-0.1)*y1LP1;	
                                y2LP1 = h2*0.1 + (1-0.1)*y2LP1;


                                


               
				

				measurements0[0][0] = y1LP;
				measurements0[1][0] = y2LP;
				measurements = new Matrix(measurements0);



                                /*Current Estimated Measured Output*/
 			        /*Y_est = C.times(states);

                                      
				/* Update Kalman Gain*/
                                 /*K = A.times(P).times(C.transpose()).times((C.times(P).times(C.transpose()).plus(V)).inverse());	
	
                                /*Update Predicted States Covariance*/
				/*P = A.times(P).times(A.transpose()).minus(A.times(P).times(C.transpose()).times((C.times(P).times(C.transpose()).plus(V)).inverse()).times(C.times(P).times(A.transpose()))).plus(W);
                                 	
				
	                       
				dataToSend[0] = states.get(0,0); 
				dataToSend[1] = states.get(1,0); 
				dataToSend[2] = 0;               
				dataToSend[3] = 0;               
				dataToSend[4] = states.get(4,0); 
				dataToSend[5] = states.get(5,0);
				*/




                               

                                dataToSend[0] = 2*y1LP1; 

				dataToSend[1] = 2*y2LP1; 

				dataToSend[2] = 0;               

				dataToSend[3] = 0;               

				//dataToSend[4] = 0.1; 

				//dataToSend[5] = 0.1;
                      		dataToSend[4] = tank1Ref;
				dataToSend[5] = tank2Ref;
				
				//Test
				System.out.println("REF1 : " + tank1Ref);
				System.out.println("REF2 : " + tank2Ref);

				System.out.println("h1 from LP " + (2*y1LP1));
				System.out.println("h2 from LP " + (2*y2LP1));


                      
				timeSolCVX = System.currentTimeMillis();
				solution = cvx.calculateOutputCVX(dataToSend);
                               
				timeSolCVX= System.currentTimeMillis()-timeSolCVX;
				System.out.println(timeSolCVX);

				//Actuate
				
                                fc1.setRef((solution[0]+2.9901));
                                //System.out.println(" REF: " + tank2Ref);
				fc2.setRef((solution[1]+3.2));
                               
				
				
				
				
				System.out.println("CVXGEN u1 " + solution[0]);
				System.out.println("CVXGEN u2 " + solution[1]);

  				 
                                

                                /* try {
       				  analogOutu1.set(solution[0]);
                	          analogOutu2.set(solution[1]);	

					
      			        } catch (Exception e) {
        				System.out.println(e);
                                }*/

				// Update States
                                /*
				inputU0[0][0] = solution[0];
				inputU0[1][0] = solution[1];
				inputU = new Matrix(inputU0);				 				
				states = A.times(states).plus(B.times(inputU)).plus(K.times(measurements.minus(Y_est)));
                                   */
		            	//sendDataToOpCom(fc2.yref2,fc2.I2,fc2.y2,fc2.P2,fc1.getControlSignalU1(),fc2.getControlSignalU2());
				sendDataToOpCom(tank1Ref,tank2Ref,2*y1LP1,2*y2LP1,fc1.getControlSignalU1(),fc2.getControlSignalU2());
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
				
				  if(h1<0){
 				   h1=0;
                                 }
                                 if(h2<0){
 				   h2=0;
                                 }
				System.out.println("Rawh1 " +  2*h1);
				System.out.println("Rawh2 "  + 2*h2);

				tank1Ref=referenceGenerator.getRef1();
				tank2Ref=referenceGenerator.getRef2();
				
                                y1LP1 = h1*0.1 + (1-0.1)*y1LP1;	
                                y2LP1 = h2*0.1 + (1-0.1)*y2LP1;
				//y1LP1 = h1;
				//y2LP2 = h2;
                               /*
                                measurements.set(0,0,(y1LP1));
				measurements.set(1,0,(y2LP1));

				
                                /*Current Estimated Measured Output*/
 			        /*
                                Y_est = C.times(states);
				System.out.println("Y_hat1 :" + 2*Y_est.get(0,0));
				System.out.println("Y_hat2 :" + 2*Y_est.get(1,0));
				System.out.println("Y_hat5 :" + states.get(4,0));
                                System.out.println("Y_hat6 :" + states.get(5,0));

                          
				/* Update Kalman Gain*/
                               // K = A.times(P).times(C.transpose()).times((C.times(P).times(C.transpose()).plus(V)).inverse());
				

                                /*Update Predicted States Covariance*/
				/*P = A.times(P).times(A.transpose()).minus(A.times(P).times(C.transpose()).times((C.times(P).times(C.transpose()).plus(V)).inverse()).times(C.times(P).times(A.transpose()))).plus(W);
                                 					
	                        
				dataToSend[0] = 2*states.get(0,0); 

				dataToSend[1] = 2*states.get(1,0); 

				dataToSend[2] = 0;               

				dataToSend[3] = 0;               

				dataToSend[4] = states.get(4,0); 

				dataToSend[5] = states.get(5,0);*/
                   		

				dataToSend[0] =2*y1LP1;
				dataToSend[1] =2*y2LP1;
				dataToSend[2] = 0;
				dataToSend[3] = 0;
                                dataToSend[4] = 0.1;
				dataToSend[5] = 0.1;
                                
				dataToSend[6] = tank1Ref;
				dataToSend[7] = tank2Ref;

				//Test
				System.out.println("REF1 : " + tank1Ref);
				System.out.println("REF2 : " + tank2Ref);

				System.out.println("h1 from LP " + (2*y1LP1));
				System.out.println("h2 from LP " + (2*y2LP1));
                                

				timeSolCVX = System.currentTimeMillis();
				solution = qp.calculateOutputQPGEN(dataToSend);
				timeSolCVX= System.currentTimeMillis()-timeSolCVX;
				System.out.println("time :" +timeSolCVX);
								
				//Test
				System.out.println("U1 "+solution[0]);
				System.out.println("U2 " +solution[1]);
                                
				//Actuate
				fc1.setRef((solution[0]+2.9901));
       			        fc2.setRef((solution[1]+4.35));
                                  /*try {
       				  analogOutu1.set(solution[0]);
                	          analogOutu2.set(solution[1]);	

					
      			        } catch (Exception e) {
        				System.out.println(e);
                                }*/

				// Update States
                                /*
				inputU.set(0,0,fc1.getControlSignalU1());
				inputU.set(1,0,fc2.getControlSignalU2());

				System.out.println("Controlled Input1: " + inputU.get(0,0));
				System.out.println("Controlled Input2: " + inputU.get(1,0));

				states = A.times(states).plus(B.times(inputU)).plus(K.times(measurements.minus(Y_est)));
                                */

				
 
	            	sendDataToOpCom(tank1Ref,tank2Ref,2*y1LP1,2*y2LP1,fc1.getControlSignalU1(),fc2.getControlSignalU2());
				break;
			}
			default: {
				System.out.println("Error: Illegal mode.");
				break;
			}
			}
			
			// sleep
                        // System.out.println("t :" + t);
			t = t+H;
                        // System.out.println("t :" + t);
			duration = t - System.currentTimeMillis();
			// System.out.println("Duration :" + duration);
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

