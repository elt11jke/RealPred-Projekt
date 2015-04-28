
public class MPCController {
	double[] u;
	
	static{
		System.loadLibrary("myjni");
	}
	

	public synchronized double[] calculateOutput(double [] numbers) {
		
		    u=controlSignalCVXGEN(numbers); 
		    return u;
	  }
	
	public native double[] controlSignalCVXGEN(double [] data);
	
}
