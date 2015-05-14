
import javax.swing.*;
import javax.swing.event.*;
import java.awt.*;
import java.awt.event.*;
import se.lth.control.*;

public class ReferenceGenerator extends Thread {
	private static final int SQWAVE=0, MANUAL=1;
	private final int priority;
	
	private double amplitude;
	private double period;
	private double sign = -1.0;
	private double ref;
	private double manual1;
	private double manual2;
	private int mode = SQWAVE;
	private boolean premature, ampChanged, periodChanged;
	
	private class RefGUI {
		private BoxPanel guiPanel = new BoxPanel(BoxPanel.VERTICAL);
		private JPanel sliderPanel = new JPanel();
		private JPanel paramsLabelPanel1 = new JPanel();
		private JPanel paramsLabelPanel2 = new JPanel();
		
		private JPanel paramsFieldPanel = new JPanel();
		private BoxPanel paramsPanel = new BoxPanel(BoxPanel.HORIZONTAL);
		private BoxPanel parAndButtonPanel = new BoxPanel(BoxPanel.VERTICAL);
		private BoxPanel buttonsPanel = new BoxPanel(BoxPanel.VERTICAL);
		private JPanel downPanel = new JPanel();
		
		private DoubleField paramsAmpField = new DoubleField(7,5);
		private DoubleField paramsPeriodField = new DoubleField(7,5);
		private JButton paramsButton = new JButton("Apply");
		private JRadioButton sqButton = new JRadioButton("Square Wave");
		private JRadioButton manButton = new JRadioButton("Manual");
		private JSlider sliderRef1 = new JSlider(JSlider.VERTICAL,0,20,0);
		private JSlider sliderRef2 = new JSlider(JSlider.VERTICAL,0,20,0);
		
		
		public RefGUI(double amp, double h) {
			MainFrame.showLoading();
			/*
			paramsLabelPanel.setLayout(new GridLayout(0,1));
			paramsLabelPanel.add(new JLabel("Amp: "));
			paramsLabelPanel.add(new JLabel("Period: "));
			
			paramsFieldPanel.setLayout(new GridLayout(0,1));
			paramsFieldPanel.add(paramsAmpField); 
			paramsFieldPanel.add(paramsPeriodField);   
			paramsPanel.add(paramsLabelPanel);
			paramsPanel.addGlue();
			paramsPanel.add(paramsFieldPanel);
			paramsPanel.addFixed(10);
			paramsAmpField.setValue(amp);
			paramsAmpField.setMaximum(10.0);
			paramsAmpField.setMinimum(0.0);
			paramsPeriodField.setValue(h);
			paramsPeriodField.setMinimum(0.0);
			
			parAndButtonPanel.setBorder(BorderFactory.createEtchedBorder());
			parAndButtonPanel.addFixed(10);
			parAndButtonPanel.add(paramsPanel);
			paramsPanel.addFixed(10);
			parAndButtonPanel.add(paramsButton);
			paramsButton.setEnabled(false);
			
			buttonsPanel.setBorder(BorderFactory.createEtchedBorder());
			buttonsPanel.add(sqButton);
			buttonsPanel.addFixed(10);
			buttonsPanel.add(manButton);
			ButtonGroup group = new ButtonGroup();
			group.add(sqButton);
			group.add(manButton);
			manButton.setSelected(true);
			
			paramsAmpField.setEditable(false);
			paramsPeriodField.setEditable(false);
			
			*/
			
			paramsLabelPanel1.add(new JLabel("Tank 1 Ref  "));
			paramsLabelPanel2.add(new JLabel("Tank 2 Ref  "));
			
		
			
			
			downPanel.setLayout(new BorderLayout());
			downPanel.add(paramsLabelPanel1, BorderLayout.WEST);
			downPanel.add(paramsLabelPanel2, BorderLayout.EAST);
			
			
			sliderRef1.setPaintTicks(true);
			sliderRef1.setEnabled(true);
			sliderRef1.setMajorTickSpacing(5); 
			sliderRef1.setMinorTickSpacing(2); 
			sliderRef1.setLabelTable(sliderRef1.createStandardLabels(10)); 
			sliderRef1.setPaintLabels(true);
			
			
			
			
			sliderRef2.setPaintTicks(true);
			sliderRef2.setEnabled(true);
			sliderRef2.setMajorTickSpacing(5); 
			sliderRef2.setMinorTickSpacing(2); 
			sliderRef2.setLabelTable(sliderRef1.createStandardLabels(10)); 
			sliderRef2.setPaintLabels(true);
			
			sliderPanel.setBorder(BorderFactory.createEtchedBorder());
			sliderPanel.add(sliderRef1);
			sliderPanel.add(sliderRef2);
			
			guiPanel.add(sliderPanel);
			guiPanel.addGlue();
			guiPanel.add(downPanel);
			
			/*
			paramsAmpField.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					ampChanged = true;
					paramsButton.setEnabled(true);
				}
			});
			paramsPeriodField.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					periodChanged = true;
					paramsButton.setEnabled(true);
				}
			});  
			paramsButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					if (ampChanged) {
						amplitude = paramsAmpField.getValue();
						ampChanged = false;
						setRef(sign * amplitude);
					}
					if (periodChanged) {
						period = paramsPeriodField.getValue()*1000.0/2.0;
						periodChanged = false;
						wakeUpThread();
					}
					paramsButton.setEnabled(false);
				}
			});
			sqButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					setSqMode();
					paramsAmpField.setEditable(true);
					paramsPeriodField.setEditable(true);
					sliderRef1.setEnabled(false);
					sliderRef2.setEnabled(false);
				}
			});
			manButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					setManMode();
					paramsAmpField.setEditable(false);
					paramsPeriodField.setEditable(false);
					sliderRef1.setEnabled(true);
					sliderRef2.setEnabled(true);
				}
			});
			*/
			sliderRef1.addChangeListener(new ChangeListener() { 
				public void stateChanged(ChangeEvent e) { 
					if (!sliderRef1.getValueIsAdjusting()) { 
						setManual1(sliderRef1.getValue()); 
		
					} 
				} 
			}); 
			
			sliderRef2.addChangeListener(new ChangeListener() { 
				public void stateChanged(ChangeEvent e) { 
					if (!sliderRef2.getValueIsAdjusting()) { 
						setManual2(sliderRef2.getValue()); 
					} 
				} 
			});
			
			MainFrame.setPanel(guiPanel,"RefGen");
		}
	}
	
	public ReferenceGenerator(int refGenPriority) {
		priority = refGenPriority;
		amplitude = 4.0;
		period = 20.0*1000.0/2.0;
		manual1 = 0.0;
		manual2= 0.0;
		ref = amplitude * sign;
		new RefGUI(4.0, 20.0);
	}
	
	private synchronized void wakeUpThread() {
		premature = true;
		notify();
	}
	
	private synchronized void sleepLight(long duration) throws InterruptedException {
		premature = false;
		wait(duration);
	}
	
	private synchronized void setRef(double newRef) {
		ref = newRef;
	}
	
	private synchronized void setManual1(double newManual) {
		manual1 = newManual;
	}
	private synchronized void setManual2(double newManual) {
		manual2 = newManual;
	}
	
	
	private synchronized void setSqMode() {
		mode = SQWAVE;
	}
	
	private synchronized void setManMode() {
		mode = MANUAL;
	}
	
	public synchronized double getRef1() 
	{
		//return (mode == SQWAVE) ? ref : manual;
		return manual1;
	}
	
	public synchronized double getRef2() 
	{
		//return (mode == SQWAVE) ? ref : manual;
		return manual2;
	}
	/*
	public void run() {
		long h = (long) period;
		long duration;
		long t = System.currentTimeMillis();
		
		setPriority(priority);
		
		try {
			while (!isInterrupted()) {
				synchronized (this) {
					sign = - sign;
					ref = amplitude * sign;
				}
				t = t + h;
				duration = t - System.currentTimeMillis();
				if (duration > 0) {
					sleepLight(duration);
					if (premature) {
						// Woken up prematurely since the period was changed
						h = (long) period;
						// Reset t
						t = System.currentTimeMillis();
						// Keep current sign 
						sign = - sign;
					}
				}
			}
		} catch (InterruptedException e) {
			// Requested to stop
		}
	}
	*/
}
