 import javax.swing.*;


  public class Main { 
    public static void main(String[] argv) { 

      final int regulPriority = 8; 
      final int refGenPriority = 6; 
      final int plotterPriority = 7; 

      ReferenceGenerator refgen = new ReferenceGenerator(refGenPriority); 
      Regul regul = new Regul(regulPriority); 
      final  OpCom opcom = new OpCom(plotterPriority); 

      regul.setOpCom(opcom); 
     regul.setRefGen(refgen);
 
      opcom.setRegul(regul); 

      Runnable initializeGUI = new Runnable(){
	public void run(){
          opcom.initializeGUI();
          opcom.start();
	}
      };
      try{
        SwingUtilities.invokeAndWait(initializeGUI);
      }catch(Exception e){
        return;
      }

      refgen.start(); 
      regul.start(); 
    } 
    
    
  }
