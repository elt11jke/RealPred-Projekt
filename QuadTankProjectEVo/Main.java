 import javax.swing.*;


  public class Main { 
    public static void main(String[] argv) { 

      final int regulPriority = 9; 
      final int refGenPriority = 6; 
      final int plotterPriority = 7; 
      final int fcPriority = 8;
      
      FlowController1 fc1 = new FlowController1(fcPriority);
      FlowController2 fc2 = new FlowController2(fcPriority);
      ReferenceGenerator refgen = new ReferenceGenerator(refGenPriority); 
      Regul regul = new Regul(regulPriority); 
      final  OpCom opcom = new OpCom(plotterPriority); 

      regul.setOpCom(opcom); 
      regul.setRefGen(refgen);
      regul.setFlowController1(fc1);
      regul.setFlowController2(fc2);
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
      fc1.run();
      fc2.run();
    } 
    
    
  }
