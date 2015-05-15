
public class CVXGENController {
	double[] u;
	
	static{
		System.loadLibrary("myjniCVX");
	}
	
		public synchronized double[] calculateOutputCVX(double [] numbers) {
		
		    u=controlSignalCVXGEN(numbers); 
		    return u;
	  }
	
	public native double[] controlSignalCVXGEN(double [] data);
	
}
