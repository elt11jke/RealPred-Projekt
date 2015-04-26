
public class MPCController {
	double[] u;
	
	static{
		System.loadLibrary("/h/d7/z/tfy11mal/Documents/FRTNO1/RealPred-Projekt/QuadTankProjectEVo/libmyjni.so");
	}
	

	public synchronized double[] calculateOutput(double [] numbers) {
		
		    u=controlSignalCVXGEN(numbers); 
		    return u;
	  }
	
	public native double[] controlSignalCVXGEN(double [] data);
	
}
