
public class QPGENController {
	
		double[] u;
		
		static{
			System.loadLibrary("myjniQP");
		}
		
			public synchronized double[] calculateOutputQPGEN(double [] numbers) {
			
			    u=controlSignalQPGEN(numbers); 
			    return u;
		  }
		
		public native double[] controlSignalQPGEN(double [] data);
		
	}


